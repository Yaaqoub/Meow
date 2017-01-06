//
//  VirtualVariable.swift
//  Puss
//
//  Created by Robbert Brandsma on 06-01-17.
//
//

import Foundation
import MongoKitten

public protocol VirtualVariable {
    var name: String { get }
}

public protocol VirtualComparable : VirtualVariable {}

public func ==(lhs: VirtualVariable, rhs: ValueConvertible) -> Query {
    return lhs.name == rhs
}

// sourcery: compareType=String
public struct VirtualString : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
    
    public func contains(_ other: String, options: NSRegularExpression.Options = []) -> Query {
        return Query(aqt: .contains(key: self.name, val: other, options: options))
    }
    
    public func hasPrefix(_ other: String) -> Query {
        return Query(aqt: .startsWith(key: self.name, val: other))
    }
    
    public func hasSuffix(_ other: String) -> Query {
        return Query(aqt: .endsWith(key: self.name, val: other))
    }
}

// sourcery: compareType=ObjectId
public struct VirtualObjectId : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=PussNumber
public struct VirtualNumber : VirtualComparable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=Date
public struct VirtualDate : VirtualComparable {
    public var name: String
    public init(name: String) { self.name = name }
}

// sourcery: compareType=Data
public struct VirtualData : VirtualVariable {
    public var name: String
    public init(name: String) { self.name = name }
}

public struct VirtualReference<T, D, R : Reference<T, D>> {
    public var name: String
    public init(name: String, type: Reference<T, D>.Type) {
        self.name = name
    }
    
    public static func ==(lhs: VirtualReference<T,D,R>, rhs: T) -> MongoKitten.Query {
        return lhs.name == rhs.id
    }
}

public protocol PussNumber : ValueConvertible {}
extension Int : PussNumber {}
extension Int32 : PussNumber {}
extension Int64 : PussNumber {}
extension Double : PussNumber {}
