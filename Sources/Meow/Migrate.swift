import MongoKitten
import Foundation

extension Meow {
    /// The collection finished migrations will be stored in
    fileprivate static var migrationsCollection: MongoKitten.Collection { return Meow.database["meow_migrations"] }
    
    /// Perform a migration
    public static func migrate(_ description: String, on model: BaseModel.Type, migration: (Migrator) throws -> ()) throws {
        if let migrator = try Migrator("\(model.collection.name) - \(description)", on: model) {
            try migrator.execute(migration)
        } else {
            print("🐈 Migration \"\(description)\" not needed")
        }
    }
}

/// An instance of `Migrator` handles a single migration. It is responsible for the actual database updating,
/// and it generates the migration plan.
///
/// You do not create instances of `Migrator` yourself. When you want to perform a migration, call
/// `Meow.migrate(...)`. The closure you pass to the `migrate(...)` method will be called with an instance of `Migrator`
/// if the migration is necessary.
public final class Migrator {
    
    /// The migration description - must be unique but human readable
    ///
    /// The description is used, together with the target collection name, as `_id` field in the migrations collection
    /// to identify the migration.
    public private(set) var description: String
    
    /// The model type this migration affects
    public private(set) var model: BaseModel.Type
    
    /// A single migration step
    private enum Step {
        case update(Document)
        case map([(Document) throws -> Document]) // an array for minification purposes so maps can be chained
        
        /// Executes the migration step on the given model
        func execute(on model: BaseModel.Type) throws {
            switch self {
            case .update(let update):
                try model.collection.update(to: update, multiple: true)
            case .map(let transforms):
                var pendingUpdates: [(filter: Query, to: Document, upserting: Bool, multiple: Bool)] = []
                
                func processPending() throws {
                    try model.collection.update(bulk: pendingUpdates)
                    pendingUpdates.removeAll(keepingCapacity: true)
                }
                
                for document in try model.collection.find() {
                    var current = document
                    for transform in transforms {
                        current = try transform(current)
                    }
                    pendingUpdates.append((filter: "_id" == document["_id"], to: current, upserting: false, multiple: false))
                    
                    if pendingUpdates.count > 100 {
                        try processPending()
                    }
                }
                
                try processPending()
            }
        }
    }
    
    /// The migration plan with all the steps
    private var plan = [Step]()
    
    /// Initializes a new migration. Returns nil if the migration has already been performed
    fileprivate init?(_ description: String, on model: BaseModel.Type) throws {
        if try Meow.migrationsCollection.count("_id" == description) > 0 {
            return nil
        }
        
        self.description = description
        self.model = model
    }
    
    /// Executes the migration. If there are no models of the given type, the migration will be skipped.
    fileprivate func execute(_ migration: (Migrator) throws -> ()) throws {
        guard try model.collection.count() > 0 else {
            print("🐈 Skipping migration \"\(description)\"")
            try Meow.migrationsCollection.insert([
                "_id": description,
                "date": Date(),
                "duration": "skipped"
                ])
            return
        }
        
        print("🐈 Starting migration \"\(description)\"")
        
        let start = Date()
        try migration(self) // generates the plan
        try runPlan()
        let end = Date()
        
        let duration = end.timeIntervalSince(start)
        
        try Meow.migrationsCollection.insert([
            "_id": description,
            "date": Date(),
            "duration": duration
            ])
        
        print("🐈 Migration \"\(description)\" finished in \(duration)s")
    }
    
    /// Runs the migration plan.
    private func runPlan() throws {
        for step in plan {
            try  step.execute(on: model)
        }
    }
    
    /// Adds a migration step, and tries to combine it with existing steps
    private func addStep(_ step: Step) {
        guard let last = plan.last else {
            plan.append(step)
            return
        }
        
        switch (last, step) {
        // TODO: Nondestructively combine update steps
        case (.map(let transforms1), .map(let transforms2)):
            plan[plan.endIndex-1] = .map(transforms1 + transforms2)
        default: plan.append(step)
        }
    }
    
    /// Rename a property
    ///
    /// This function performs a `$rename` operation on the collection using the literal names you provide.
    /// This means that, with the default naming rules enabled, if you want to rename a property `myProperty` to
    /// `myNewProperty`, your call to `rename(...)` would look like this:
    ///
    /// `migrate.rename("my_property", to: "my_new_property")`
    ///
    /// - parameter property: The old name (in the Document) of the property
    /// - parameter newName: The new name (in the Document) of the property
    public func rename(_ property: String, to newName: String) {
        addStep(.update(["$rename": [property: newName]]))
    }
    
    /// Transform the entire model, on Document level.
    ///
    /// You may use this function to make any adaptions you like on the actual stored documents of your Model.
    /// This provides maximum flexibility.
    ///
    /// - parameter transform: A closure that will be executed on every model document in the database. The returned document from this closure replaces the existing document in the database.
    public func map(_ transform: @escaping (Document) throws -> (Document)) {
        addStep(.map([transform]))
    }
    
    /// Transform a single property, on Primitive level
    ///
    /// You may use this function, for example, if you have changed the data type of a property.
    ///
    /// - parameter property: The name (in the database) of the property you want to transform
    /// - parameter transform: A closure that will be executed for every instance in the database
    public func map(_ property: String, _ transform: @escaping (BSON.Primitive?) throws -> (BSON.Primitive?)) {
        addStep(.map([{ document in
            var document = document
            document[property] = try transform(document[property])
            return document
            }]))
    }
    
    /// Remove a property from the model
    ///
    /// - parameter property: The database name of the property to remove
    public func remove(_ property: String) {
        addStep(.update(["$unset": [property: ""]]))
    }
}
