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

    /// This is the equivalent to the Optional's 'nonEmptyString'
    /// so that we can use it interchangeble for Strings and optional Strings
    ///
    /// so instead of requiring something very common in our code like:
    /// ```swift
    /// if let unwrappedString = someOptionalString,
    ///      !unwrappedString.isEmpty {
    ///      ... do something with non empty, unwrapped 'unwrappedString'
    /// }
    /// ```
    ///
    /// we can instead just use:
    /// ```swift
    /// if let stringWithContent = someString.nonEmptyString {
    ///      ... do something with non empty 'someString'
    /// }
    /// ```
    var nonEmptyString: String? {
        if isEmpty { return nil }
        return self
    }
}
