//
//  DefaultNavigationFactory.swift
//  SHPlatform
//
//  Created by Shinnar, Gil(AWF) on 2021-03-24.
//

import UIKit

final class DefaultNavigationFactory: NavigationFactory {
    func makeNavigationController() -> UINavigationController {
        let result = UINavigationController()
        result.navigationBar.prefersLargeTitles = true
        return result
    }
}
