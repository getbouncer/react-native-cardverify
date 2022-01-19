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
    var styleDictionary: NSDictionary?
    
    override init() {
        super.init()
    }
    
    @objc class func requiresMainQueueSetup() -> Bool {
        return true
    }

    @objc func awaitReady(
        _ resolve: RCTPromiseResolveBlock,
        _ reject: RCTPromiseRejectBlock
    ) -> Void {
        resolve([true])
    }

    @objc func isSupportedAsync(
        _ resolve: RCTPromiseResolveBlock,
        _ reject: RCTPromiseRejectBlock
    ) -> Void {
        if true {
            resolve([Bouncer.isCompatible])
        } else {
            reject(nil, nil, nil)
        }
    }

    @objc func setiOSVerifyViewStyle(_ styleDictionary: NSDictionary) {
        self.styleDictionary = styleDictionary
    }

    @objc func downloadModels() {
        Bouncer.downloadModelsIfNotCached()
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
          let vc = RNCardVerifyViewController(
            userId: "",
            lastFour: lastFour,
            bin: requiredIin as String?,
            viewStyle: self.styleDictionary
          )
          vc.verifyCardDelegate = self
          topViewController?.present(vc, animated: true, completion: nil)
        } else {
          let vc = RNCardVerifyAddViewController(
            userId: "",
            viewStyle: self.styleDictionary
          )
          vc.cardAddDelegate = self
          topViewController?.present(vc, animated: true, completion: nil)
        }
      }
    }
    
    func getTopViewController() -> UIViewController? {
      guard var topViewController = UIApplication.shared.keyWindow?.rootViewController else {
        return nil
      }

      while let nextViewController = topViewController.presentedViewController {
        topViewController = nextViewController
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
    }

    func userDidPressManualCardAdd(_ viewController: UIViewController) {
        if let topViewController = getTopViewController() {
            topViewController.dismiss(animated: true, completion: nil)
        }

        if let resolve = resolve {
            resolve(["action": "skipped"])
        }

        resolve = nil
    }
    
    func fraudModelResultsVerifyCardAdd(viewController: UIViewController, creditCard: CreditCard, encryptedPayload: String?, extraData: [String: Any]) {
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
