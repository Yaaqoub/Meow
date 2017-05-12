// Generated using Sourcery 0.6.0 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT


import MongoKitten
import BSON
import Foundation


extension ObjectId : Serializable {
    /// Tries to initialize a ObjectId from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(ObjectId(source), keyForError: "primitive ObjectId")
	}

    /// Serializes the ObjectId into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension String : Serializable {
    /// Tries to initialize a String from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(String(source), keyForError: "primitive String")
	}

    /// Serializes the String into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Int : Serializable {
    /// Tries to initialize a Int from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Int(source), keyForError: "primitive Int")
	}

    /// Serializes the Int into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Int32 : Serializable {
    /// Tries to initialize a Int32 from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Int32(source), keyForError: "primitive Int32")
	}

    /// Serializes the Int32 into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Bool : Serializable {
    /// Tries to initialize a Bool from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Bool(source), keyForError: "primitive Bool")
	}

    /// Serializes the Bool into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Document : Serializable {
    /// Tries to initialize a Document from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Document(source), keyForError: "primitive Document")
	}

    /// Serializes the Document into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Double : Serializable {
    /// Tries to initialize a Double from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Double(source), keyForError: "primitive Double")
	}

    /// Serializes the Double into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Data : Serializable {
    /// Tries to initialize a Data from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Data(source), keyForError: "primitive Data")
	}

    /// Serializes the Data into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Binary : Serializable {
    /// Tries to initialize a Binary from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Binary(source), keyForError: "primitive Binary")
	}

    /// Serializes the Binary into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension Date : Serializable {
    /// Tries to initialize a Date from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(Date(source), keyForError: "primitive Date")
	}

    /// Serializes the Date into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
extension RegularExpression : Serializable {
    /// Tries to initialize a RegularExpression from a BSON Primitive
    ///
    /// - parameter source: The BSON primitive
    /// - throws: When the primitive is of the wrong type
	public init(restoring source: Primitive) throws {
		self = try Meow.Helpers.requireValue(RegularExpression(source), keyForError: "primitive RegularExpression")
	}

    /// Serializes the RegularExpression into a BSON primitive
    ///
    /// It just returns `self`
	public func serialize() -> BSON.Primitive {
		return self
	}
}
	
