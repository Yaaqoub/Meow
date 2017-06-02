@_exported import MongoKitten

/// Something that can represent itself as a String (key)
public protocol KeyRepresentable : Hashable {
    
    /// The BSON key string for the key
    var keyString: String { get }
    
}

/// Used to define all keys in a Model.
///
/// This is normally implemented by an enum in the code that is generated by Meow.
/// You normally do not need to implement this protocol yourself.
public protocol ModelKey : KeyRepresentable {
    
    /// The type of the variable that this key represents in the model
    var type: Any.Type { get }
    
    /// All keys belonging to the model
    static var all: Set<Self> { get }
    
}

/// Used to define partial values for a model.
///
/// This is normally implemented by a struct in the code that is generated by Meow.
/// You normally do not need to implement this protocol yourself.
///
/// The value structs can be used for default or partial values, or updates
public protocol ModelValues : SerializableToDocument {
    
    /// Initialize a new, empty value struct.
    init()
    
}

extension String : KeyRepresentable {
    public var keyString: String {
        return self
    }
}

/// Makes an ObjectId able to represent a Key
extension ObjectId : KeyRepresentable {
    public var keyString: String {
        return hexString
    }
}

/// Something with an ObjectId
public protocol Identifyable {
    var databaseIdentifier: ObjectId { get }
}

/// Indicates why a save was requested
enum SaveReason {
    case manual
    case `deinit`
    case autosave
    case exit
    case referenced
}

/// `BaseModel` is the base protocol that every model conforms to.
///
/// Models are not expected to conform directly to `BaseModel`. They state conformance to `Model`, which inherits from
/// `BaseModel`. The actual implementation of the protocol is usually handled in an extension generated by Sourcery/Meow.
///
/// The reason `Model` is split up into `Model` and `BaseModel`, is that `Model` has associated type requirements.
/// This currently makes it impossible to use `Model` as a concrete type, e.g. function argument or array type, without
/// making the function generic.
///
/// When possible, model methods are added to the `BaseModel` protocol, and not the `Model` protocol. 
public protocol BaseModel : class, SerializableToDocument, Convertible, Identifyable {
    /// The collection this entity resides in
    static var collection: MongoKitten.Collection { get }
    
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    /// Note that, if the model has not been changed, the update may not actually get pushed to the database.
    func willSave() throws
    
    /// Will be called when the Model has been saved.
    ///
    /// - parameter wasUpdated: If the save operation actually updated the database
    func didSave(wasUpdated: Bool) throws
    
    /// The database identifier. You do **NOT** need to add this yourself. It will be implemented for you using Sourcery.
    var _id: ObjectId { get set }
    
    /// A list of all dot-notated keys that are a reference to a model and their referenced type
    ///
    /// - parameter previousModels: The previous models chain is used to prevent infinite recursion. Whenever `recursiveKeysWithReferences` is queried, all types found will also be queried for their `recursiveKeysWithReferences` recursively.
    /// - throws: When the recursion triggers a higher-level model that has been accessed earlier in the chain
    static func recursiveKeysWithReferences(chainedFrom previousModels: [BaseModel.Type]) throws -> [(String, BaseModel.Type)]
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    func willDelete() throws
    
    /// Will be called when the Model is deleted. At this point, it is no longer in the database and saves will no longer work because the ObjectId is invalidated.
    func didDelete() throws
    
    /// Instantiates this BaseModel from a primitive
    init(newFrom source: BSON.Primitive) throws
    
    /// Validates an update document
    static func validateUpdate(with document: Document) throws
    
    /// Updates a model with a Document, overriding its own properties with those from the document
    func update(with document: Document) throws
    
    /// All keys present in this model. Implemented in a protocol extension
    static var allRawKeys: [(String, Any.Type)] { get }
    
    /// Forwards the save operation to all directly referenced objects
    func saveReferences() throws
}

extension BaseModel {
    public var databaseIdentifier: ObjectId { return _id }
}

/// When implemented, indicated that this is a model that resides at the lowest level of a collection, as a separate entity.
///
/// Embeddables will have a generated Virtual variant of itself for the type safe queries
public protocol Model : class, BaseModel, Hashable {
    associatedtype Key : ModelKey = String
    associatedtype VirtualInstance : VirtualModelInstance
    associatedtype Values : ModelValues
    typealias QueryBuilder = (VirtualInstance) throws -> (Query)
}

extension Model {
    public static var allRawKeys: [(String, Any.Type)] {
        return Key.all.map { return ($0.keyString, $0.type) }
    }
    
    /// Makes the model hashable, thus unique, thus usable in a Dictionary
    public var hashValue: Int {
        return _id.hashValue
    }
    
    /// Make a type-safe query for this model
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func makeQuery(_ closure: QueryBuilder) rethrows -> Query {
        return try closure(VirtualInstance(keyPrefix: "", isReference: false))
    }
    
    /// A list of all dot-notated keys that are a reference to a model and their referenced type
    ///
    /// - parameter previousModels: The previous models chain is used to prevent infinite recursion. Whenever `recursiveKeysWithReferences` is queried, all types found will also be queried for their `recursiveKeysWithReferences` recursively.
    /// - throws: When the recursion triggers a higher-level model that has been accessed earlier in the chain
    public static func recursiveKeysWithReferences(chainedFrom previousModels: [BaseModel.Type]) throws -> [(String, BaseModel.Type)] {
        let directKeys: [(String, BaseModel.Type)] = try Self.Key.all.flatMap { key in
            guard let type = key.type as? BaseModel.Type else {
                return nil
            }
            
            for previousType in previousModels where type == previousType {
                throw Meow.Error.infiniteRecursiveReference(from: Self.self, to: type)
            }
            
            return (key.keyString, type)
        }
        
        var indirectKeys = [(String, BaseModel.Type)]()
        
        for (prefix, type) in directKeys {
            for (key, type) in try type.recursiveKeysWithReferences(chainedFrom: previousModels + [Self.self]) {
                indirectKeys.append((prefix + "." + key, type))
            }
        }
        
        return directKeys + indirectKeys
    }
    
    /// Remove all instances matching the query.
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func remove(limitedTo limit: Int? = nil, _ query: QueryBuilder) throws {
        try self.remove(makeQuery(query), limitedTo: limit)
    }
    
    /// Performs a find operation using a type-safe query.
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func find(sortedBy sort: [Key : SortOrder]? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100, _ query: QueryBuilder) throws -> AnySequence<Self> {
        return try find(makeQuery(query), sortedBy: sort?.makeSort(), skipping: skip, limitedTo: limit, withBatchSize: batchSize)
    }
    
    /// Performs a findOne operation using a type-safe query.
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func findOne(sortedBy sort: [Key : SortOrder]? = nil, _ query: QueryBuilder) throws -> Self? {
        return try findOne(makeQuery(query), sortedBy: sort?.makeSort())
    }
    
    /// Performs a findOne operation using a type-safe query.
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func count(_ query: QueryBuilder) throws -> Int {
        return try count(makeQuery(query))
    }
}

extension Dictionary where Key : KeyRepresentable, Value == SortOrder {
    public func makeSort() -> Sort {
        var sort = Sort()
        
        for (key, order) in self {
            sort[key.keyString] = order
        }
        
        return sort
    }
}

extension BaseModel {
    /// Provides `Equatable` conformance. Just calls `===` because two instances pointing to the same model cannot exist.
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs._id == rhs._id
    }
}

public extension BaseModel {
    /// Will be called before saving the Model. Throwing from here will prevent the model from saving.
    public func willSave() throws {}
    
    /// Will be called when the Model has been saved to the database.
    public func didSave(wasUpdated: Bool) throws {}
    
    /// Will be called when the Model will be deleted. Throwing from here will prevent the model from being deleted.
    public func willDelete() throws {}
    
    /// Will be called when the Model is deleted. At this point, it is no longer in the database and saves will no longer work because the ObjectId is invalidated.
    public func didDelete() throws {}
}


/// Implementes basic CRUD functionality for the object
extension BaseModel {
    /// Converts BaseModel to another KittenCore Type using lossy conversion
    public func convert<DT>(to type: DT.Type) -> DT.SupportedValue? where DT : DataType {
        return self.serialize().convert(to: type)
    }
    
    /// Counts the amount of objects matching the query
    public static func count(_ filter: Query? = nil, limitedTo limit: Int? = nil, skipping skip: Int? = nil) throws -> Int {
        let prepared = try BaseModelHelper<Self>.prepareQuery(filter, skipping: skip, limitedTo: limit)
        
        switch prepared {
        case .aggregate(var pipeline):
            pipeline.append(.count(insertedAtKey: "_meowCount"))
            guard let count = Int(try Self.collection.aggregate(pipeline, options: [.cursorOptions(["batchSize": 1])]).next()?["_meowCount"]) else {
                throw MongoError.internalInconsistency
            }
            
            return count
        case .find(let query, _, let skip, let limit, _):
            return try collection.count(query, limitedTo: limit, skipping: skip)
        }
    }
    
    /// Removes this object from the database
    ///
    /// Before deleting, `willDelete()` is called. `willDelete()` can throw to prevent the deletion.
    /// When the deletion is complete, `didDelete()` is called.
    public func delete() throws {
        try self.willDelete()
        Meow.pool.invalidate(self._id)
        try Self.collection.remove("_id" == self._id)
        try self.didDelete()
    }
    
    /// Returns the first object matching the query
    public static func findOne(_ query: Query? = nil, sortedBy sort: Sort? = nil) throws -> Self? {
        // We don't reuse find here because that one does not have proper error reporting
        return try Self.find(query, sortedBy: sort, limitedTo: 1, withBatchSize: 1).makeIterator().next()
    }
    
    internal func save(force: Bool = false, reason: SaveReason) throws {
        guard force || !Meow.pool.isGhost(self) else {
            return
        }
        
        try self.willSave()
        
        let document = self.serialize()
        
        if reason != .deinit {
            Meow.pool.pool(self)
        }
        
        let hash = document.meowHash
        
        guard force || hash != Meow.pool.existingHash(for: self) else {
            Meow.log("Not saving \(self) because it is unchanged")
            try self.didSave(wasUpdated: false)
            return
        }
        
        try self.saveReferences()
        
        Meow.log("Saving \(self)")
        
        try Self.collection.update("_id" == self._id,
                                   to: document,
                                   upserting: true
        )
        
        Meow.pool.updateHash(for: self, with: hash)
        
        try self.didSave(wasUpdated: true)
    }
    
    /// Saves this object to the database
    ///
    /// - parameter force: Defaults to `false`. If set to true, the object is saved even if it has not been changed.
    public func save(force: Bool = false) throws {
        try self.save(force: force, reason: .manual)
    }
    
    /// Removes all entities matching the query
    /// Errors that happen during deletion will be collected and a `Meow.error.deletingMultiple` will be thrown if errors occurred
    ///
    /// - parameter query: The query to apply to the remove operation
    /// - parameter limit: The maximum number of objects to remove
    public static func remove(_ query: Query? = nil, limitedTo limit: Int? = nil) throws {
        var errors = [(ObjectId, Error)]()
        for instance in try self.find(query, limitedTo: limit) {
            do {
                try instance.delete()
            } catch {
                errors.append((instance._id, error))
            }
        }
        
        guard errors.count == 0 else {
            throw Meow.Error.deletingMultiple(errors: errors)
        }
    }
    
    /// Returns all objects matching the query
    ///
    /// - parameter query: The query to compare the database entities with
    /// - parameter sort: The order to sort the entities by
    public static func find(_ query: Query? = nil, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100, allowOptimizing: Bool = true) throws -> AnySequence<Self> {
        
        // Query optimisations
        if allowOptimizing && sort == nil && skip == nil, let aqt = query?.aqt {
            if case .valEquals("_id", let val) = aqt {
                // Meow only supports ObjectId as _id, so if it isn't an ObjectId we can safely return an empty result
                guard let val = val as? ObjectId else {
                    return AnySequence([])
                }
                
                // we have this id in memory, so return that
                if let instance: Self = Meow.pool.getPooledInstance(withIdentifier: val) {
                    return AnySequence([instance])
                }
            }
        }
        
        let prepared = try BaseModelHelper<Self>.prepareQuery(query, sortedBy: sort, skipping: skip, limitedTo: limit)
        let result = try BaseModelHelper<Self>.runPreparedQuery(prepared, batchSize: batchSize)
                
        return AnySequence(try result.flatMap { document in
            do {
                return try Self.instantiateIfNeeded(document)
            } catch {
                Meow.log("Initializing from document failed: \(error)")
                assertionFailure("Could not initialize \(Self.self) from document\n_id: \(ObjectId(document["_id"])?.hexString ?? document["_id"] ?? "unknown")\nError: \(error)\n")
                return nil
            }
        })
    }
    
    /// Intantiates this instance if needed, or pulls the existing entity from memory when able
    public static func instantiateIfNeeded(_ document: Document) throws -> Self {
        return try Meow.pool.instantiateIfNeeded(type: Self.self, document: document)
    }
    
    /// Performs a type-erased find operation, so you can perform a `find` when you dynamically receive a BaseModel.Type.
    public static func genericFind(_ query: Query? = nil, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100, allowOptimizing: Bool = true) throws -> AnySequence<BaseModel> {
        return AnySequence(try self.find(query, sortedBy: sort, skipping: skip, limitedTo: limit, withBatchSize: batchSize, allowOptimizing: allowOptimizing).lazy.map { $0 as BaseModel })
    }
}

extension Model {
    /// Performs a projected find
    ///
    /// - parameter query: The MongoKitten query to perform
    /// - parameter including: The set of keys to include in the returned values. The rest (except _id) will be nil.
    /// - parameter sort: MongoKitten sort
    /// - parameter limit: The maximum number of results to return
    /// - parameter batchSize: The amount of documents to fetch from MongoDB at once
    public static func findPartial(_ query: Query? = nil, including: Set<Self.Key>, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100) throws -> Cursor<Self.Values> {
        let projection = Document(dictionaryElements: including.map { ($0.keyString, Int32(1)) })
        
        let prepared = try Helper<Self>.prepareQuery(query, sortedBy: sort, projecting: Projection(projection), skipping: skip, limitedTo: limit)
        let result = try Helper<Self>.runPreparedQuery(prepared, batchSize: batchSize)
        
        return try result.flatMap { document in
            do {
                return try Self.Values(restoring: document, key: "")
            } catch {
                Meow.log("Initializing values from document failed: \(error)")
                assertionFailure()
                return nil
            }
        }

    }
    
    /// Performs a find operation using a type-safe query.
    ///
    /// For more information about type safe queries, see the guide and the documentation on the types whose name start with `Virtual`.
    public static func findPartial(including: Set<Self.Key>, sortedBy sort: Sort? = nil, skipping skip: Int? = nil, limitedTo limit: Int? = nil, withBatchSize batchSize: Int = 100, _ query: QueryBuilder) throws -> Cursor<Self.Values> {
        return try findPartial(makeQuery(query), including: including, sortedBy: sort, skipping: skip, limitedTo: limit, withBatchSize: batchSize)
    }
}

extension Model {
    
    /// Looks up all models that refer to this model, and returns it as a set of collection-key combinations
    /// Currently only works for top-level references (references inside structs are not supported currently)
    public static func referencingProperties() -> [(type: BaseModel.Type, keys: [String])] {
        var properties: [(BaseModel.Type, [String])] = []
        
        // First, we'll get all BaseModel types, and then find every Key that refers to Self
        for model in Meow.types.flatMap({ $0 as? BaseModel.Type }) {
            for (key, keyType) in model.allRawKeys where keyType == Self.self || keyType == Array<Self>.self || keyType == Set<Self>.self {
                properties.append((model, [key]))
            }
        }
        
        // Now, reduce these so the result only contains one entry per type
        return properties.reduce([]) { result, entry in
            if let existingIndex = result.index(where: { $0.0 == entry.0 }) {
                var result = result
                result[existingIndex].keys += entry.1
                return result
            } else {
                return result + [entry]
            }
        }
    }
    
    /// Counts the number of properties that reference this instance. Supports propeties listed by referencingProperties.
    /// Note that this may execute a large amount of queries on your database and may be a costly operation, especially
    /// if the references are not indexed.
    ///
    /// Note that if one model contains multiple references (in separate properties) to this model, it is still counted as one.
    ///
    /// - returns: The amount of models that refer to this model
    public func referenceCount() throws -> Int {
        var count = 0
        for (model, keys) in Self.referencingProperties() {
            count += try model.count(keys.map{ $0 == self._id }.reduce(Query(), ||))
        }
        return count
    }
    
    /// Returns all model instances that refer to this instance. Supports propeties listed by referencingProperties.
    /// Note that this may execute a large amount of queries on your database and may be a costly operation, especially
    /// if the references are not indexed.
    public func referencingModels() throws -> AnySequence<BaseModel> {
        var sequences = [AnySequence<BaseModel>]()
        
        for (model, keys) in Self.referencingProperties() {
            sequences.append(try model.genericFind(keys.map{ $0 == self._id }.reduce(Query(), ||)))
        }
        
        return AnySequence(sequences.joined())
    }
    
}
