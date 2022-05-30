
import Foundation

public typealias APIModule = (APICenter) -> Void

public class ModuleSalt{
}

public func startTattoo(_ scope: APICenter = mainCenter, modules: APIModule...) {
    modules.forEach { (module) in
        module(scope)
    }
}
