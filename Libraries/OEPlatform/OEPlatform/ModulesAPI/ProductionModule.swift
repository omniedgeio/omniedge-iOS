
import Foundation
import Tattoo


public protocol ProductionModule {
    func addProductionServices(_ scope: APICenter)
}

private class ProductionModuleSalt {
}

public extension APICenter {
    func registerModule<Module>(_ type: Module.Type,
                                _ block: @escaping (APICenter) -> Module) {
        singleton(type, self) { scope -> AnyObject in
            let result = block(scope)
            if let module = result as? ProductionModule {
                module.addProductionServices(scope)
            }
            return result as AnyObject
        }
    }
}
