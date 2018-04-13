import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var router: Router!

    var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = UIColor.white
        window.makeKeyAndVisible()
        return window
    }()

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let storage = AppKeyValueStorage()
        router = Router(window: window!,
                        storage: storage)
        router.start()
        return true
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {

        return router.handleOpen(url: url,
                          options: options)

    }
}
