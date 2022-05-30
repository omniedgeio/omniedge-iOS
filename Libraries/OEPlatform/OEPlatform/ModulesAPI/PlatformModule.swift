
import Foundation
import Tattoo

public extension APICenter {

    func addSalt() {
    }

    func setupPlatformRouting() {
        registerService(RoutingManager.self, RoutingManagerImpl.init)
    }

    func notificationCenter() -> NotificationCenter {
        getService(NotificationCenter.self)
    }

    func setupPlatformNotificationCenter() {
        registerService(NotificationCenter.self, { NotificationCenter.default })
    }

    func userDefaults() -> UserDefaults {
        getService(UserDefaults.self)
    }

    func setupPlatformUserDefaults() {
        registerService(UserDefaults.self, { UserDefaults.standard })
    }
}
