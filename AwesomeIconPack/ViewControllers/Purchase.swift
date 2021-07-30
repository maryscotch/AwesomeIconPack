import Foundation
import SwiftyStoreKit


class Purchase {
    var successHandler: (() -> Void)?
    var errorHandler: (() -> Void)?
    var alreadyPurchasedHandler: (() -> Void)?
    var notPurchasedYetHandler: (() -> Void)?
    var priceHandler: ((String?) -> Void)?
    
    let productID = "dummy"
    
    // プロダクト情報
    func getPriceInfo() {
        SwiftyStoreKit.retrieveProductsInfo([productID]) { result in
            if let product = result.retrievedProducts.first {
                // プロダクト情報取得
                let price = product.localizedPrice!
                self.priceHandler!(price)
            } else if let invalidProductId = result.invalidProductIDs.first {
                // プロダクトID無効
                self.priceHandler!(nil)
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                self.priceHandler!(nil)
                print("Error: \(String(describing: result.error))")
            }
        }
    }
    
    func purchaseProduct() {
        SwiftyStoreKit.purchaseProduct(productID, quantity: 1, atomically: true) { result in
               switch result {
               case .success(_):
                   //購入成功
                    UserDefaults.standard.set(true, forKey: "isPurchase")
                    self.successHandler?()
               case .error(_):
                    self.errorHandler?()
               }
            }
    }
    
    func restore() {
        let isPurchase = UserDefaults.standard.bool(forKey: "isPurchase")
        if isPurchase == true {
            // 購入済み
            self.alreadyPurchasedHandler?()
        } else {
            SwiftyStoreKit.restorePurchases(atomically: false) { results in
                if results.restoreFailedPurchases.count > 0 {
                    // エラー
                    print("Restore Failed: \(results.restoreFailedPurchases)")
                    self.errorHandler?()
                } else if results.restoredPurchases.count > 0 {
                    // リストア成功
                    self.successHandler?()
                    for purchase in results.restoredPurchases {
                        if purchase.needsFinishTransaction {
                            SwiftyStoreKit.finishTransaction(purchase.transaction)
                        }
                    }
                    // 復元処理とロック解除
                    UserDefaults.standard.set(true, forKey: "isPurchase")
                    print("Restore Success: \(results.restoredPurchases)")
                }
                else {
                    // 未購入
                    self.notPurchasedYetHandler?()
                }
            }
        }
    }

}
