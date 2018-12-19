import UIKit
import StoreKit

enum IAPHandlerAlertType {
    case disabled
    case restored
    case purchased
}

class IAPHandler: NSObject {
    static let shared = IAPHandler()

    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var iapProducts = [SKProduct]()
    var purchaseStatusBlock: ((IAPHandlerAlertType) -> Void)?

    func purchaseMyProduct(index: Int) {
        if iapProducts.isEmpty { return }

        if SKPaymentQueue.canMakePayments() {
            let product = iapProducts[index]
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            purchaseStatusBlock?(.disabled)
        }
    }

    func restorePurchase() {
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    func fetchAvailableProducts() {
        let productIdentifiers: Set<String> = Set<String>(["eu.deltasiege.stickify.coffee"])
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest.delegate = self
        productsRequest.start()
    }

}

extension IAPHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {

    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if !response.products.isEmpty {
            iapProducts = response.products
        }
    }

    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        purchaseStatusBlock?(.restored)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction: AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(trans)
                    purchaseStatusBlock?(.purchased)
                case .failed:
                    SKPaymentQueue.default().finishTransaction(trans)
                case .restored:
                    SKPaymentQueue.default().finishTransaction(trans)
                default: break
                }
            }
        }
    }

}
