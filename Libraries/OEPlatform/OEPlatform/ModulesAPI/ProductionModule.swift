//
//  ProductionModule.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-04-26.
//

import Foundation
import Tattoo

/// An interface for production modules to add their services to the scope
public protocol ProductionModule {
    /// Called by the app in the module initialization phase to add the required services to the scope.
    func addProductionServices(_ scope: Scope)
}

public extension Scope {
    /// Registers a module implementation and calls the `addProductionServices` function if it's implemented.
    ///
    /// Usually the bootstrap logic in the app will call this.
    func registerModule<Module>(_ type: Module.Type,
                                _ block: @escaping (Scope) -> Module) {
        singleton(type, self) { scope -> AnyObject in
            let result = block(scope)
            if let module = result as? ProductionModule {
                module.addProductionServices(scope)
            }
            return result as AnyObject
        }
    }
}
