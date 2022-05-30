public func get<Service>(_ qualifier: APIQualifier,
                         _ type: Service.Type,
                         _ scope: APICenter = mainCenter ) -> Service {
    return scope.ink(qualifier: qualifier, type: type, scope: scope)
}

public func get<Service>(_ type: Service.Type, _ scope: APICenter = mainCenter) -> Service {
    return get(TypeQualifier(type: type), type, scope)
}

public func get<Service: Configurable>(_ qualifier: APIQualifier,
                                       _ type: Service.Type,
                                       _ configuration: Service.Configuration,
                                       _ scope: APICenter = mainCenter) -> Service {
    return scope.ink(qualifier: qualifier, type: type, configuration: configuration, scope: scope)
}

public func get<Service: Configurable>(_ type: Service.Type,
                                       _ configuration: Service.Configuration,
                                       _ scope: APICenter = mainCenter) -> Service {
    return get(TypeQualifier(type: type), type, configuration, scope)
}

public func apifactory<Service>(_ qualifier: APIQualifier,
                             _ type: Service.Type,
                             _ scope: APICenter,
                             _ factoryClosure: @escaping FactoryClosure,
                             _ file: String = #file,
                             _ function: String = #function,
                             _ line: Int = #line) {
    scope.apifactory(qualifier: qualifier, type: type, factoryClosure: factoryClosure, file: file, function: function, line: line)
}

public func factory<Service>(_ type: Service.Type,
                             _ scope: APICenter,
                             _ factoryClosure: @escaping FactoryClosure,
                             _ file: String = #file,
                             _ function: String = #function,
                             _ line: Int = #line) {
    apifactory(TypeQualifier(type: type), type, scope, factoryClosure, file, function, line)
}

public func singleton<Service>(_ qualifier: APIQualifier,
                               _ type: Service.Type,
                               _ scope: APICenter,
                               _ factoryClosure: @escaping FactoryClosure,
                               _ lazyLoad: Bool = true,
                               _ file: String = #file,
                               _ function: String = #function,
                               _ line: Int = #line) {
    scope.singleton(qualifier: qualifier, type: type, factoryClosure: factoryClosure, lazyLoad: lazyLoad, file: file, function: function, line: line)
}

public func singleton<Service>(_ type: Service.Type,
                               _ scope: APICenter,
                               _ factoryClosure: @escaping FactoryClosure,
                               _ lazyLoad: Bool = true,
                               _ file: String = #file,
                               _ function: String = #function,
                               _ line: Int = #line) {
    singleton(TypeQualifier(type: type), type, scope, factoryClosure, lazyLoad, file, function, line)
}
