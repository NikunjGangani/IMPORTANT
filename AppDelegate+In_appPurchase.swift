
AppDelegate

var isflgRestore = Bool()
var isToGetPrice = Bool()
var identifer = String()
var controllerOpen = UIViewController()
var request = SKProductsRequest()


import UIKit
import StoreKit

extension AppDelegate: SKProductsRequestDelegate,SKPaymentTransactionObserver,SKRequestDelegate {
    
    func productPurchase(productIdentifier:NSString, flgRestore:Bool, toGetPrice:Bool, controller:UIViewController) {
        isToGetPrice = toGetPrice
        controllerOpen = controller
        identifer = productIdentifier as String
        isflgRestore = flgRestore
        let productsRequest:SKProductsRequest = SKProductsRequest(productIdentifiers: Set([productIdentifier as String]))
        productsRequest.delegate = self;
        productsRequest.start();
    }
    
    
    func setDataForInAppPurchase(transcationIdetifier:NSString) {
        Utils.saveData(transcationIdetifier, forKey:Config.LifeTimeProductId)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:Config.NC_INAPP_PURCHASE), object: Config.LifeTimeProductId)
    }
    
    func isApplicationUpgraded() -> Bool {
        
        if ((Utils.getDataForKey(Config.LifeTimeProductId)) != nil)  {
            return true
        }
        return false
    }
    
    // MARK:- SKProductsRequest
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        //only need price
        if isToGetPrice && response.products.count > 0 {
            isToGetPrice = false
            let validProduct: SKProduct = response.products[0] as SKProduct
            let price = validProduct.localizedPrice //localizedFormattedPrice(response.products.first)
            UserDefaults.standard.set(price, forKey: Config.UD_IAP_PRICE)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: Config.NC_IAP_PRICE), object: price)
            return
        }
        
        let count : Int = response.products.count
        if (count > 0) {
            let validProduct: SKProduct = response.products[0] as SKProduct
            if (validProduct.productIdentifier ==  identifer) {
                
                SKPaymentQueue.default().add(self)
                if (isflgRestore) {
                    SKPaymentQueue.default().restoreCompletedTransactions()
                } else {
                    let payment = SKPayment(product: validProduct)
                    SKPaymentQueue.default().add(payment)
                }
                
            } else {
                print(validProduct.productIdentifier)
            }
        } else {
            print(response.invalidProductIdentifiers)
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans:SKPaymentTransaction = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    print("In App Payment Success")
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    self.setDataForInAppPurchase(transcationIdetifier: transaction.payment.productIdentifier as NSString)
                    
                    break
                case .failed:
                    
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                    let alert = UIAlertController(title: "", message: "Payment failed", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {(action:UIAlertAction!) in
                    }))
                    controllerOpen.present(alert, animated: true, completion: nil)
                    
                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                     self.setDataForInAppPurchase(transcationIdetifier: transaction.payment.productIdentifier as NSString)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Error Fetching product information");
    }

    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
       print("Error Fetching product information\(error.localizedDescription)");
    }
    
}

extension SKProduct {
    
    var localizedPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = priceLocale
        return formatter.string(from: price)
    }
    
}
