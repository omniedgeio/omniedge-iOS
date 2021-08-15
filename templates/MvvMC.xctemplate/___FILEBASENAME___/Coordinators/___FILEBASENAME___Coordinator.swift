//
//  ___FILEBASENAMEASIDENTIFIER___.swift
//  ___PROJECTNAME___
//
//  Created by ___FULLUSERNAME___ on ___DATE___
//  ___COPYRIGHT___
//

import Foundation
import SHPlatform
import Tattoo

class ___FILEBASENAMEASIDENTIFIER___: Coordinator {

    private let viewModel: ___VARIABLE_productName:identifier___ViewModel
    private let router: RoutingAPI
    private let scope: Scope

    init(router: RoutingAPI, scope: Scope) {
        self.router = router
        self.scope = scope
        self.viewModel = ___VARIABLE_productName:identifier___ViewModel()
    }

    // TODO - put your coordinator logic here
}
