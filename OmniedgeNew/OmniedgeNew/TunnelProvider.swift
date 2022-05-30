//
//  TunnelProvider.swift
//  OmniedgeNew
//
//  Created by samuelsong on 2021/11/22.
//

import Foundation
import OEPlatform
import OmniedgeDylib
import Tattoo

public class TunnelProvider: TunnelAPI {
    public init(scope: APICenter) {}

    public func start(_ complete: @escaping (Error?) -> Void) {
        let config = OmniEdgeConfig()
        OmniEdgeManager.shared.start(with: config, completion: { result in
            complete(result)
        })
    }

    public func stop() {
        OmniEdgeManager.shared.stop()
    }
}
