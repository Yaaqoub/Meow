// Generated using Sourcery 0.5.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

import Puss
import Foundation


extension Preferences : ConcreteModel {
    static let pussCollection = Puss.database["preferences"]

    func pussSerialize() -> Document {
        var doc: Document = ["_id": self.id]

        
        // likesCheese: Bool (Bool)
        
        doc["likesCheese"] = self.likesCheese
        
        

        return doc
    }

    convenience init(fromDocument source: Document) throws {
        // Extract all properties
        
        // loop: likesCheese

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let likesCheeseValue: Bool = try Puss.Helpers.requireValue(source["likesCheese"], keyForError: "likesCheese")
        
        
        

        self.init(
            
        )

        
        self.likesCheese = likesCheeseValue
        
    }
}

extension User : ConcreteModel {
    static let pussCollection = Puss.database["user"]

    func pussSerialize() -> Document {
        var doc: Document = ["_id": self.id]

        
        // email: String (String)
        
        doc["email"] = self.email
        
        
        // firstName: String? (String)
        
        doc["firstName"] = self.firstName
        
        
        // lastName: String? (String)
        
        doc["lastName"] = self.lastName
        
        
        // passwordHash: Data? (Data)
        
        doc["passwordHash"] = self.passwordHash
        
        
        // registrationDate: Date (Date)
        
        doc["registrationDate"] = self.registrationDate
        
        
        // preferences: Reference<Preferences>? (Reference<Preferences>)
        
        

        return doc
    }

    convenience init(fromDocument source: Document) throws {
        // Extract all properties
        
        // loop: email

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let emailValue: String = try Puss.Helpers.requireValue(source["email"], keyForError: "email")
        
        
        
        // loop: firstName

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let firstNameValue: String? = source["firstName"]
        
        
        
        // loop: lastName

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let lastNameValue: String? = source["lastName"]
        
        
        
        // loop: passwordHash

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let passwordHashValue: Data? = source["passwordHash"]
        
        
        
        // loop: registrationDate

        
        // The property is a BSON type, so we can just extract it from the document:
        
        let registrationDateValue: Date = try Puss.Helpers.requireValue(source["registrationDate"], keyForError: "registrationDate")
        
        
        
        // loop: preferences

        

        
        

        self.init(
            
            email: emailValue
            
        )

        
        self.email = emailValue
        
        self.firstName = firstNameValue
        
        self.lastName = lastNameValue
        
        self.passwordHash = passwordHashValue
        
        self.registrationDate = registrationDateValue
        
        self.preferences = preferencesValue
        
    }
}

