//
//  String+COAdditions.swift
//  conradkiosk
//
//  Created by Alex da Franca on 08/12/14.
//  Copyright (c) 2014 Conrad Electronics SE. All rights reserved.
//

import Foundation

extension String {

    func substring(start: Int, end: Int) -> String {
        let strLength = characters.count
        let startPos = start < 0 ? characters.count + start: start
        guard startPos < strLength else { return "" }
        let endPos = end < 0 ? characters.count + end: end
        guard endPos >= Int(startPos) else { return "" }
        return self[index(startIndex, offsetBy: Int(startPos))..<index(startIndex, offsetBy: min(endPos, characters.count))]
    }

    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return substring(to: index(startIndex, offsetBy: 1)).uppercased() + substring(from: index(startIndex, offsetBy: 1))
    }
}
