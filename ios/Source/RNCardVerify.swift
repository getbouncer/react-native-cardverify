//
//  RCTCardVerify.swift
//  RNCardVerify
//
//  Created by Jaime Park on 7/12/21.
//

import CardVerify
import Foundation
import UIKit

@available(iOS 11.2, *)
@objc(RNCardVerify)
class RNCardVerify: NSObject {
    var resolve: RCTPromiseResolveBlock?

    override init() {
        super.init()
    }
    
    @objc class func requiresMainQueueSetup() -> Bool {
        return true
    }
    
    @objc func isSupportedAsync(
        _ resolve: RCTPromiseResolveBlock,
        _ reject: RCTPromiseRejectBlock
    ) -> Void {
        if Bouncer.isCompatible() {
            resolve([Bouncer.isCompatible])
        } else {
            reject(nil, nil, nil)
        }
    }

    @objc func scan(
        _ requiredIin: NSString?,
        _ requiredLastFour: NSString?,
        _ skipVerificationOnModelDownloadFailure: Bool,
        _ resolve: @escaping RCTPromiseResolveBlock,
        _ reject: RCTPromiseRejectBlock
    ) -> Void {
        self.resolve = resolve
        
        DispatchQueue.main.async {
            let topViewController = self.getTopViewController()
            
            if let lastFour = requiredLastFour as String? {
                let vc = VerifyCardViewController(
                    userId: "",
                    lastFour: lastFour,
                    bin: requiredIin as String?
                )
                vc.verifyCardDelegate = self
                topViewController?.present(vc, animated: true, completion: nil)
            } else {
                let vc = VerifyCardAddViewController(userId: "")
                vc.cardAddDelegate = self
                topViewController?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    func getTopViewController() -> UIViewController? {
        var topViewController = UIApplication.shared.keyWindow?.rootViewController
        
        while (topViewController?.presentingViewController != nil) {
            topViewController = topViewController?.presentedViewController
        }

        return topViewController
    }
}

@available(iOS 11.2, *)
extension RNCardVerify: VerifyCardResult {

    func userCanceledVerifyCard(viewController: VerifyCardViewController) {
        if let topViewController = getTopViewController() {
            topViewController.dismiss(animated: true, completion: nil)
        }

        if let resolve = resolve {
            resolve([
                "action": "canceled",
                "canceledReason": "user_canceled"
            ])
        }
    }

    func fraudModelResultsVerifyCard(viewController: VerifyCardViewController, creditCard: CreditCard, encryptedPayload: String?, extraData: [String : Any]) {
      if let topViewController = getTopViewController() {
        topViewController.dismiss(animated: true, completion: nil)
      }

      var resolvePayload: [String: Any] = [:]
      resolvePayload["action"] = "scanned"
      resolvePayload["payload"] = {
        var payload: [String: Any] = [:]
        payload["number"] = creditCard.number
        payload["cardholderName"] = creditCard.name
        payload["expiryMonth"] = creditCard.expiryMonth
        payload["expiryYear"] = creditCard.expiryYear
        payload["payloadVersion"] = "1"
        
        if Bouncer.useLocalVerificationOnly {
          payload["isCardValid"] = extraData["isCardValid"]
          payload["cardValidationFailureReason"] = extraData["validationFailureReason"]
        } else {
          payload["verificationPayload"] = encryptedPayload
        }
        return payload
      }()

      if let resolve = self.resolve {
        resolve(resolvePayload)
      }
    }
}

@available(iOS 11.2, *)
extension RNCardVerify: VerifyCardAddResult {
    func userDidCancelCardAdd(_ viewController: UIViewController) {
        if let topViewController = getTopViewController() {
            topViewController.dismiss(animated: true, completion: nil)
        }

        if let resolve = resolve {
            resolve([
                "action": "canceled",
                "canceledReason": "user_canceled"
            ])
        }
    }

    func userDidScanCardAdd(_ viewController: UIViewController, creditCard: CreditCard) {
      if let topViewController = getTopViewController() {
        topViewController.dismiss(animated: true, completion: nil)
      }

      var resolvePayload: [String: Any] = [:]
      resolvePayload["action"] = "scanned"
      resolvePayload["payload"] = {
        var payload: [String: Any] = [:]
        payload["number"] = creditCard.number
        payload["cardholderName"] = creditCard.name
        payload["expiryMonth"] = creditCard.expiryMonth
        payload["expiryYear"] = creditCard.expiryYear
        payload["payloadVersion"] = "1"

        if Bouncer.useLocalVerificationOnly {
          payload["isCardValid"] = extraData["isCardValid"]
          payload["cardValidationFailureReason"] = extraData["validationFailureReason"]
        } else {
          payload["verificationPayload"] = encryptedPayload
        }
        return payload
      }()

      if let resolve = self.resolve {
        resolve(resolvePayload)
      }
    }

    func userDidPressManualCardAdd(_ viewController: UIViewController) {
        if let topViewController = getTopViewController() {
            topViewController.dismiss(animated: true, completion: nil)
        }

        if let resolve = resolve {
            resolve(["action": "skipped"])
        }
    }
}
