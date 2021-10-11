public typealias FactoryClosure = (Scope) -> AnyObject

public let mainScope: Scope = MainScope(parent: nil)

public class Scope {
    fileprivate let parent: Scope?

    public init(parent: Scope? = mainScope) {
        self.parent = parent
    }

    fileprivate var classes = [String: Class]()
}

public protocol Configurable {
    associatedtype Configuration
    func configure(configuration: Configuration)
}

extension Scope {

    fileprivate func warnDuplicatedRegistrationIfExist<Service>(_ qualifier: Qualifier, _ type: Service.Type, _ function: String, _ file: String, _ line: Int) {
        if classes.keys.contains(qualifier.value) {
            // swiftlint:disable:next line_length
            print("⚠️⚠️⚠️ The \(type) has already been registered in this Scope, this behavior will override the existing value. Please carefully review your code at \(function) \(file):\(line)! ⚠️⚠️⚠️")
        }
    }

    internal func factory<Service>(qualifier: Qualifier,
                                   type: Service.Type,
                                   factoryClosure: @escaping FactoryClosure,
                                   file: String = #file,
                                   function: String = #function,
                                   line: Int = #line ) {
        warnDuplicatedRegistrationIfExist(qualifier, type, function, file, line)
        classes[qualifier.value] = Class(singleton: false,
                                         factoryClosure: factoryClosure,
                                         instance: nil,
                                         file: file,
                                         function: function,
                                         line: line)
    }

    internal func singleton<Service>(qualifier: Qualifier,
                                     type: Service.Type,
                                     factoryClosure: @escaping FactoryClosure,
                                     lazyLoad: Bool = true,
                                     file: String = #file,
                                     function: String = #function,
                                     line: Int = #line ) {
        warnDuplicatedRegistrationIfExist(qualifier, type, function, file, line)
        classes[qualifier.value] = Class(singleton: true,
                                         factoryClosure: factoryClosure,
                                         instance: lazyLoad ?  nil : factoryClosure(self),
                                         file: file,
                                         function: function,
                                         line: line)
    }

    internal func ink<Service>(qualifier: Qualifier,
                               type: Service.Type,
                               scope: Scope) -> Service {
        guard var clazz = classes[qualifier.value] else {
            guard let service = parent?.ink(qualifier: qualifier, type: type, scope: scope) else {
                fatalError("\(qualifier.value) is not registered, please make sure to setup it before calling resolve.")
            }
            return service
        }
        if clazz.singleton {
            // Singleton mode
            if clazz.instance == nil {
                clazz.instance = clazz.factoryClosure(scope)
                classes[qualifier.value] = clazz
            }
            guard let service = clazz.instance as? Service else {
                // swiftlint:disable:next line_length
                fatalError("Can't force cast \(String(describing: clazz.instance.self)) to \(type), please check your implementation of function \(clazz.function) at \(clazz.file) line:\(clazz.line).")
            }
            return service
        } else {
            // Factory mode
            guard let service = clazz.factoryClosure(scope) as? Service else {
                // swiftlint:disable:next line_length
                fatalError("The factory closure didn't return a valid intance of \(type), please check your implementation of function \(clazz.function) at \(clazz.file) line:\(clazz.line).")
            }
            return service
        }
    }
}

struct Class {
    let singleton: Bool
    let factoryClosure: FactoryClosure
    var instance: AnyObject?
    let file: String
    let function: String
    let line: Int
}

extension Scope {
    internal func ink<Service: Configurable>(qualifier: Qualifier,
                                             type: Service.Type,
                                             configuration: Service.Configuration,
                                             scope: Scope) -> Service {
        let service = ink(qualifier: qualifier, type: type, scope: scope)
        service.configure(configuration: configuration)
        return service
    }
}

private class MainScope: Scope {
}
