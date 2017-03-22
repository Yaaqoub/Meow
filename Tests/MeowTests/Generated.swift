// Generated using Sourcery 0.5.9 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import Foundation
import Meow



  func meowReinstantiateObjectIdArray(from source: Primitive?) throws -> [ObjectId]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> ObjectId in
          return try Meow.Helpers.requireValue(ObjectId(rawValue), keyForError: "index \(index) on array of ObjectId")
      }
  }


  func meowReinstantiateStringArray(from source: Primitive?) throws -> [String]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> String in
          return try Meow.Helpers.requireValue(String(rawValue), keyForError: "index \(index) on array of String")
      }
  }


  func meowReinstantiateIntArray(from source: Primitive?) throws -> [Int]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int in
          return try Meow.Helpers.requireValue(Int(rawValue), keyForError: "index \(index) on array of Int")
      }
  }


  func meowReinstantiateInt32Array(from source: Primitive?) throws -> [Int32]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Int32 in
          return try Meow.Helpers.requireValue(Int32(rawValue), keyForError: "index \(index) on array of Int32")
      }
  }


  func meowReinstantiateBoolArray(from source: Primitive?) throws -> [Bool]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Bool in
          return try Meow.Helpers.requireValue(Bool(rawValue), keyForError: "index \(index) on array of Bool")
      }
  }


  func meowReinstantiateDocumentArray(from source: Primitive?) throws -> [Document]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Document in
          return try Meow.Helpers.requireValue(Document(rawValue), keyForError: "index \(index) on array of Document")
      }
  }


  func meowReinstantiateDoubleArray(from source: Primitive?) throws -> [Double]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Double in
          return try Meow.Helpers.requireValue(Double(rawValue), keyForError: "index \(index) on array of Double")
      }
  }


  func meowReinstantiateDataArray(from source: Primitive?) throws -> [Data]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Data in
          return try Meow.Helpers.requireValue(Data(rawValue), keyForError: "index \(index) on array of Data")
      }
  }


  func meowReinstantiateBinaryArray(from source: Primitive?) throws -> [Binary]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Binary in
          return try Meow.Helpers.requireValue(Binary(rawValue), keyForError: "index \(index) on array of Binary")
      }
  }


  func meowReinstantiateDateArray(from source: Primitive?) throws -> [Date]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> Date in
          return try Meow.Helpers.requireValue(Date(rawValue), keyForError: "index \(index) on array of Date")
      }
  }


  func meowReinstantiateRegularExpressionArray(from source: Primitive?) throws -> [RegularExpression]? {
      guard let document = Document(source) else {
        return nil
      }

      return try document.map { index, rawValue -> RegularExpression in
          return try Meow.Helpers.requireValue(RegularExpression(rawValue), keyForError: "index \(index) on array of RegularExpression")
      }
  }

      // Struct or Class extension
      extension User : ConcreteSerializable {
      // sourcery:inline:User.Meow
      // sourcery:end


        convenience init?(meowValue: Primitive?) throws {
          guard let document = Document(meowValue) else {
            return nil
          }
          try self.init(meowDocument: document)
        }

        func meowSerialize() -> Document {
          var document = Document()
          
            document["_id"] = self._id 
            document["username"] = self.username 
            document["password"] = self.password 
            document["age"] = self.age 
            document["gender"] = self.gender?.meowSerialize() 
            document["details"] = self.details?.meowSerialize() 
            document["preferences"] = self.preferences.map { $0.meowSerialize() } 
            document["extraPreferences"] = self.extraPreferences?.map { $0.meowSerialize() } 
          return document
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Document {
          // TODO: re-evaluate references
            return self.meowSerialize()
        }

        struct VirtualInstance {
          var keyPrefix: String

          
             /// _id: ObjectId
              var _id: VirtualObjectId { return VirtualObjectId(name: keyPrefix + "_id") } 
             /// username: String
              var username: VirtualString { return VirtualString(name: keyPrefix + "username") } 
             /// password: String
              var password: VirtualString { return VirtualString(name: keyPrefix + "password") } 
             /// age: Int?
              var age: VirtualNumber { return VirtualNumber(name: keyPrefix + "age") } 
             /// gender: Gender?
              var gender: Gender.VirtualInstance { return Gender.VirtualInstance(keyPrefix: keyPrefix + "gender") } 
             /// details: Details?
             
             /// preferences: [Preference]
             
             /// extraPreferences: [Preference]?
             

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        } // end VirtualInstance

        enum Key : String {          
            case _id          
            case username          
            case password          
            case age          
            case gender          
            case details          
            case preferences          
            case extraPreferences          


        }

      } // end struct or class extension of User
  
        extension User : ConcreteModel {
          static let meowCollection: MongoKitten.Collection = Meow.database["user"]
          var meowReferencesWithValue: ReferenceValues { return [] }

          static func find(_ closure: ((VirtualInstance) -> (Query))) throws -> CollectionSlice<User> {
            let query = closure(VirtualInstance())
            return try self.find(query)
          }

          static func findOne(_ closure: ((VirtualInstance) -> (Query))) throws -> User? {
            let query = closure(VirtualInstance())
            return try self.findOne(query)
          }

          static func count(_ closure: ((VirtualInstance) -> (Query))) throws -> Int {
            let query = closure(VirtualInstance())
            return try self.count(query)
          }

          static func createIndex(named name: String? = nil, withParameters closure: ((VirtualInstance, IndexSubject) -> ())) throws {
            let indexSubject = IndexSubject()
            closure(VirtualInstance(), indexSubject)

            try meowCollection.createIndexes([(name: name ?? "", parameters: indexSubject.makeIndexParameters())])
          }
        }
      
    func meowReinstantiateUserArray(from source: Primitive?) throws -> [User]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> User in
            return try Meow.Helpers.requireValue(User(meowValue: rawValue), keyForError: "index \(index) on array of User")
        }
    }
  
      // Enum extension
      extension Gender : ConcreteSingleValueSerializable {
        /// Creates a `Gender` from a BSON Primtive
        init(meowValue: Primitive?) throws {
          
            let rawValue = try Meow.Helpers.requireValue(String(meowValue), keyForError: "enum Gender")
            switch rawValue {
               case "male": self = .male
               case "female": self = .female
              
              default: throw Meow.Error.enumCaseNotFound(enum: "Gender", name: rawValue)
            }
          
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
          return self.meowSerialize()
        }

        func meowSerialize() -> Primitive {
          
            switch self {
               case .male: return "male"
               case .female: return "female"
              
            }
          
        }

        struct VirtualInstance {
          /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
          static func ==(lhs: VirtualInstance, rhs: Gender?) -> Query {
            return lhs.keyPrefix == rhs?.meowSerialize()
          }

          var keyPrefix: String

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        }
      }
    
    func meowReinstantiateGenderArray(from source: Primitive?) throws -> [Gender]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> Gender in
            return try Meow.Helpers.requireValue(Gender(meowValue: rawValue), keyForError: "index \(index) on array of Gender")
        }
    }
  
      // Struct or Class extension
      extension Details : ConcreteSerializable {
      
      init(meowDocument source: Document) throws {        
          self.firstName = String(source["firstName"])  /* String? */ 
          self.lastName = String(source["lastName"])  /* String? */ 
          self.address = try meowDeserializeTupleOfstreetNameStringAndnumberIntAndcityStringAndhouseGenderGender(source["address"])  /* (streetName: String?, number: Int, city: String, houseGender: Gender)? */ 
      }
      


         init?(meowValue: Primitive?) throws {
          guard let document = Document(meowValue) else {
            return nil
          }
          try self.init(meowDocument: document)
        }

        func meowSerialize() -> Document {
          var document = Document()
          
            document["firstName"] = self.firstName 
            document["lastName"] = self.lastName 
            document["address"] = meowSerializeTupleOfstreetNameStringAndnumberIntAndcityStringAndhouseGenderGender(self.address)
          return document
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Document {
          // TODO: re-evaluate references
            return self.meowSerialize()
        }

        struct VirtualInstance {
          var keyPrefix: String

          
             /// firstName: String?
              var firstName: VirtualString { return VirtualString(name: keyPrefix + "firstName") } 
             /// lastName: String?
              var lastName: VirtualString { return VirtualString(name: keyPrefix + "lastName") } 
             /// address: (streetName: String?, number: Int, city: String, houseGender: Gender)?
             

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        } // end VirtualInstance

        enum Key : String {          
            case firstName          
            case lastName          
            case address          


        }

      } // end struct or class extension of Details
  
    func meowReinstantiateDetailsArray(from source: Primitive?) throws -> [Details]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> Details in
            return try Meow.Helpers.requireValue(Details(meowValue: rawValue), keyForError: "index \(index) on array of Details")
        }
    }
  
      // Enum extension
      extension Preference : ConcreteSingleValueSerializable {
        /// Creates a `Preference` from a BSON Primtive
        init(meowValue: Primitive?) throws {
          
            let rawValue = try Meow.Helpers.requireValue(String(meowValue), keyForError: "enum Preference")
            switch rawValue {
               case "swift": self = .swift
               case "mongodb": self = .mongodb
               case "linux": self = .linux
               case "macos": self = .macos
              
              default: throw Meow.Error.enumCaseNotFound(enum: "Preference", name: rawValue)
            }
          
        }

        func meowSerialize(resolvingReferences: Bool) throws -> Primitive {
          return self.meowSerialize()
        }

        func meowSerialize() -> Primitive {
          
            switch self {
               case .swift: return "swift"
               case .mongodb: return "mongodb"
               case .linux: return "linux"
               case .macos: return "macos"
              
            }
          
        }

        struct VirtualInstance {
          /// Compares this enum's VirtualInstance type with an actual enum case and generates a Query
          static func ==(lhs: VirtualInstance, rhs: Preference?) -> Query {
            return lhs.keyPrefix == rhs?.meowSerialize()
          }

          var keyPrefix: String

          init(keyPrefix: String = "") {
            self.keyPrefix = keyPrefix
          }
        }
      }
    
    func meowReinstantiatePreferenceArray(from source: Primitive?) throws -> [Preference]? {
        guard let document = Document(source) else {
          return nil
        }

        return try document.map { index, rawValue -> Preference in
            return try Meow.Helpers.requireValue(Preference(meowValue: rawValue), keyForError: "index \(index) on array of Preference")
        }
    }
  
    func meowSerializeTupleOfstreetNameStringAndnumberIntAndcityStringAndhouseGenderGender(_ tuple: (streetName: String?, number: Int, city: String, houseGender: Gender)?) -> Document? {
      guard let tuple = tuple else {
        return nil
      }

      return [
        
          "streetName": tuple.streetName,        
          "number": tuple.number,        
          "city": tuple.city,        
          "houseGender": tuple.houseGender,        
      ]
    }

    func meowDeserializeTupleOfstreetNameStringAndnumberIntAndcityStringAndhouseGenderGender(_ primitive: Primitive?) throws -> (streetName: String?, number: Int, city: String, houseGender: Gender)? {
      guard let document = Document(primitive) else {
        return nil
      }

      return (        
          streetName:  String(document["streetName"])  /* String? */           ,         
          number:  try Meow.Helpers.requireValue(Int(document["number"]), keyForError: "tuple element number")  /* Int */           ,         
          city:  try Meow.Helpers.requireValue(String(document["city"]), keyForError: "tuple element city")  /* String */           ,         
          houseGender:  try Meow.Helpers.requireValue(Gender(meowValue: document["houseGender"]), keyForError: "tuple element houseGender")  /* Gender */                    
      )
    }
    
// Serializables parsed: User,Gender,Details,Preference
// Tuples parsed: streetNameStringAndnumberIntAndcityStringAndhouseGenderGender