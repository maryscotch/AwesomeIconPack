import UIKit
import SwiftyStoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(1)
        
        // 10回に一回レビューアラートを表示
        let forKey = "appOpenCount"
        let appOpenCount = UserDefaults.standard.integer(forKey: forKey)
        if appOpenCount == 0 {
            UserDefaults.standard.set(1, forKey: forKey)
        } else {
            let totalCount = appOpenCount + 1
            UserDefaults.standard.set(totalCount, forKey: forKey)
        }
        
        // アプリの起動
        SwiftyStoreKit.completeTransactions(atomically: true) { products in
            for product in products {
                if product.transaction.transactionState == .purchased || product.transaction.transactionState == .restored {
                    UserDefaults.standard.set(true, forKey: "isPurchase")
                    if product.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(product.transaction)
                    }
                }
            }
        }
       
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

