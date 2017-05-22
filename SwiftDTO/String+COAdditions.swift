//
//  String+COAdditions.swift
//  conradkiosk
//
//  Created by Alex da Franca on 08/12/14.
//  Copyright (c) 2014 Conrad Electronics SE. All rights reserved.
//

import Foundation

extension String {
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return substring(to: index(startIndex, offsetBy: 1)).uppercased() + substring(from: index(startIndex, offsetBy: 1))
    }
}
