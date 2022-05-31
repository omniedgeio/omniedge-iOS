
public typealias QualifierValue = String

public protocol APIQualifier {
    var value: QualifierValue { get }
}

public class StringQualifier: APIQualifier {

    public let value: QualifierValue

    public init(qualifier: String) {
        self.value = qualifier
    }
}

public class QulifierSalt{
}

public class TypeQualifier<T>: APIQualifier {

    public let value: QualifierValue

    public init(type: T.Type) {
        self.value = "\(type)"
    }
}
