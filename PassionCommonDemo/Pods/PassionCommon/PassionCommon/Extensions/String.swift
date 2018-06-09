//
//  String.swift
//  PassionCommon
//
//  Created by Alaa Al-Zaibak on 1.03.2018.
//  Copyright © 2018 Alaa Al-Zaibak. All rights reserved.
//

import UIKit

extension String {
    func htmlToAttributedString() -> NSAttributedString {
        if let data = self.data(using: String.Encoding.utf8) {
            let string = try? NSAttributedString(data: data,
                                                 options: [NSAttributedString.DocumentReadingOptionKey.documentType:NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue],
                                                 documentAttributes: nil)
            return string ?? NSAttributedString()
        }
        return NSAttributedString()
    }
}
