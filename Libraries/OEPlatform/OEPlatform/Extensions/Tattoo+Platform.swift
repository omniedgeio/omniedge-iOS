
import Tattoo

fileprivate class APICenterSalt {
}

public extension APICenter {
    func getService<Service>(_ type: Service.Type) -> Service {
        return get(type, self)
    }

    func registerService<Service>(_ type: Service.Type, _ block: @escaping (APICenter) -> Service) {
        singleton(type, self) { scope -> AnyObject in
            return block(scope) as AnyObject
        }
    }

    func registerService<Service>(_ type: Service.Type, _ block: @escaping () -> Service) {
        singleton(type, self) { _ -> AnyObject in
            return block() as AnyObject
        }
    }
}
