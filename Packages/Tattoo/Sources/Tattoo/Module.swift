//
//  Module.swift
//  
//
//  Created by He, Junjie on 4/30/21.
//

import Foundation

public typealias Module = (Scope) -> Void

public func startTattoo(_ scope: Scope = mainScope, modules: Module...) {
    modules.forEach { (module) in
        module(scope)
    }
}
