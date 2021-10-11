//
//  Tattoo+Platform.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-23.
//

import Tattoo

// enhance scope with these to avoid using globals.
public extension Scope {
    func getService<Service>(_ type: Service.Type) -> Service {
        return get(type, self)
    }

    func registerService<Service>(_ type: Service.Type, _ block: @escaping (Scope) -> Service) {
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
