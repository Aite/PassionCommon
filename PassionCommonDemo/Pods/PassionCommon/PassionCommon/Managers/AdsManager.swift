//
//  AdsManager.swift
//  PassionCommon
//
//  Created by Alaa Al-Zaibak on 24.06.2017.
//  Copyright © 2018 Alaa Al-Zaibak. All rights reserved.
//

import UIKit
import GoogleMobileAds

public class AdsManager: NSObject, GADInterstitialDelegate {
    public static var shared = AdsManager()

    private var adsTimer : Timer?
    private let mainBannerDebugAdUnitId = "ca-app-pub-3940256099942544/2934735716"

    var mainBannerAddUnitId : String?
    var interstitialAddUnitId : String?

    let interstitialAdsTimeInterval = 180.0   // 3 minutes
    var interstitial : GADInterstitial?
    var _mainBanner : GADBannerView?
    var mainBanner : GADBannerView {
        if _mainBanner == nil {
            _mainBanner = GADBannerView(adSize: kGADAdSizeBanner)
            _mainBanner?.translatesAutoresizingMaskIntoConstraints = false
            loadBanner(_mainBanner!, in: nil)
        }
        return _mainBanner!
    }

    override init() {

    }

    func configure(admobAppId: String) {
        // Initialize the Google Mobile Ads SDK.
        GADMobileAds.configure(withApplicationID: admobAppId)
    }

    func loadBanner(_ bannerView: GADBannerView, in rootViewController: UIViewController?) {
        #if DEBUG
        bannerView.adUnitID = mainBannerDebugAdUnitId // test adUnitID
        #else
        bannerView.adUnitID = mainBannerAddUnitId // real adUnitID
        #endif

        if rootViewController != nil {
            bannerView.rootViewController = rootViewController!
        }

        let request = GADRequest()
        bannerView.load(request)
    }

    func addMainBanner(to view: UIView, constraitedTo bottomLayoutGuide:UIView, in rootViewController: UIViewController?) {
        if self.mainBanner.superview != nil {
            self.mainBanner.removeFromSuperview()
        }

        view.addSubview(self.mainBanner)
        view.addConstraints(
            [NSLayoutConstraint(item: self.mainBanner,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: bottomLayoutGuide,
                                attribute: .top,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: self.mainBanner,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])

        if rootViewController != nil {
            self.mainBanner.rootViewController = rootViewController!
        }
    }

    func initializeInterstitial() {
        reloadInterstitial()
    }

    func reloadInterstitial() {
        self.interstitial = createAndLoadInterstitial()
    }

    func createAndLoadInterstitial() -> GADInterstitial {
        #if DEBUG
        let interstitial = GADInterstitial(adUnitID: mainBannerDebugAdUnitId) // test adUnitID
        #else
        var interstitialAddUnitId = mainBannerDebugAdUnitId
        if self.interstitialAddUnitId != nil {
            interstitialAddUnitId = self.interstitialAddUnitId!;
        }
        let interstitial = GADInterstitial(adUnitID: interstitialAddUnitId) // real adUnitID
        #endif
        interstitial.delegate = self
        let request = GADRequest()
        interstitial.load(request)
        return interstitial
    }

    func presentPollfishView() {
        return
        //        #if DEBUG
        //            let debuggable = true
        //        #else
        //            let debuggable = false
        //        #endif
        //        let userAttributesDictionary:UserAttributesDictionary = [:]
        //
        //        /*included in Demographic Surveys*/
        //        userAttributesDictionary.setGender(GENDER(FEMALE));
        //        userAttributesDictionary.setYearOfBirth(YEAR_OF_BIRTH(_2000));
        //        userAttributesDictionary.setMaritalStatus(MARITAL_STATUS(SINGLE));
        //
        //        Pollfish.initAtPosition(Int32(PollfishPosition.PollFishPositionTopLeft.rawValue),
        //                                withPadding: 0,
        //                                andDeveloperKey: "bd7c86d4-cc8a-4df6-91c4-226a3e733bbd",
        //                                andDebuggable: debuggable,
        //                                andCustomMode: true,
        //                                andRequestUUID: "",
        //                                andUserAttributes: userAttributesDictionary)
        //
        //        Pollfish.initAtPosition(Int32(PollfishPosition.PollFishPositionTopLeft.rawValue),
        //                                withPadding: 0,
        //                                andDeveloperKey: "bd7c86d4-cc8a-4df6-91c4-226a3e733bbd" ,
        //                                andDebuggable: debuggable,
        //                                andCustomMode: true)
    }
//
//    func shouldShowAds(for testId: Int?) -> Bool {
//        return !IAPManager.shared.isProductPurchased(productId: TestsViewController.allTestsProductId)
//    }

    @available(iOS 10.0, *)
    func presentInterstitialView(withTimer timerEnabled: Bool) {
        if AdsManager.shared.interstitial?.isReady ?? false {
            if let rootController = UIApplication.shared.delegate?.window??.rootViewController {
                AdsManager.shared.interstitial?.present(fromRootViewController: rootController)
                AdsManager.shared.reloadInterstitial()
            }
        }
        if timerEnabled {
            adsTimer = Timer.scheduledTimer(withTimeInterval: interstitialAdsTimeInterval, repeats: true, block: { (timer : Timer) in
                if timer.isValid {
                    self.presentInterstitialView(withTimer: false)
                }
            })
        }
    }

    public func invalidateInterstitialTimer() {
        adsTimer?.invalidate()
        adsTimer = nil
    }
}
