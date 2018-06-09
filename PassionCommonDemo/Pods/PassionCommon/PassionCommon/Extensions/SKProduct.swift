//
//  SKProduct.swift
//  PassionCommon
//
//  Created by Alaa Al-Zaibak on 8.04.2018.
//  Copyright © 2018 Alaa Al-Zaibak. All rights reserved.
//

import StoreKit

extension SKProduct {

    var localizedPrice : String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)!
    }

}
