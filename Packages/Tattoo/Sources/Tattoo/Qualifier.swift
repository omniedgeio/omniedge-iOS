//
//  File.swift
//  
//
//  Created by He, Junjie on 3/16/21.
//

public typealias QualifierValue = String

public protocol Qualifier {
    var value: QualifierValue { get }
}

public class StringQualifier: Qualifier {

    public let value: QualifierValue

    public init(qualifier: String) {
        self.value = qualifier
    }
}

public class TypeQualifier<T>: Qualifier {

    public let value: QualifierValue

    public init(type: T.Type) {
        self.value = "\(type)"
    }
}
