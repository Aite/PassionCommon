//
//  StoreReviewManager.swift
//  PassionCommon
//
//  Created by Alaa Al-Zaibak on 2.05.2018.
//  Copyright © 2018 Alaa Al-Zaibak. All rights reserved.
//

import Foundation
import StoreKit
import Firebase

struct UserDefaultsKeys {
    static let APP_OPENED_COUNT = "APP_OPENED_COUNT"
}

class StoreReviewManager {
    public static let shared = StoreReviewManager()

    let Defaults = UserDefaults.standard
    private var isReviewRequestedInCurrentRuntime = false
    private var appName = ""
    private var appId = ""

    public func initialize(appName: String, appId: String) {
        self.appName = appName
        self.appId = appId
        self.incrementAppOpenedCount()
    }

    private func incrementAppOpenedCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }
        appOpenCount += 1
        Defaults.set(appOpenCount, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
    }

    func requestReview() {
        requestReview(nil)
    }

    func checkAndAskForReview(_ viewController: UIViewController?) { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let appOpenCount = Defaults.value(forKey: UserDefaultsKeys.APP_OPENED_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.APP_OPENED_COUNT)
            return
        }

        switch appOpenCount {
        case 3,7:
            StoreReviewManager.shared.requestReview(viewController)
            Analytics.logEvent("request_review", parameters: [
                "app_open_count" : appOpenCount as NSObject
                ])
        case _ where appOpenCount%10 == 0 :
            StoreReviewManager.shared.requestReview(viewController)
            Analytics.logEvent("request_review", parameters: [
                "app_open_count" : appOpenCount as NSObject
                ])
        default:
            break;
        }

    }

    func requestReview(_ viewController: UIViewController?) {
        guard !isReviewRequestedInCurrentRuntime else {
            return
        }
        isReviewRequestedInCurrentRuntime = true

        if #available( iOS 10.3, *) {
            SKStoreReviewController.requestReview()
        }
        else {
            if let url = URL(string: String(format:"itms-apps://itunes.apple.com/app/%@", appId)) {
                let alert = UIAlertController(title: String(format:"%@ hoşunuza gidiyor mu?", appName), message: "Uygulamayı App Store üzerinden değerlendirir misiniz?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Değerlendir", style: .default, handler: { (alertAction : UIAlertAction) in
                    if #available(iOS 10.0, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    } else {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alert.addAction(UIAlertAction(title: "Şimdi Değil", style: .cancel, handler: nil))
                viewController?.present(alert, animated: true, completion: nil)
            }
        }
    }

    fileprivate func purchasedItemsURL() -> URL {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
        return URL(fileURLWithPath: documentsDirectory).appendingPathComponent("lastReviewTime.plist")
    }

}
