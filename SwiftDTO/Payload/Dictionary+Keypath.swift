//
//  Dictionary+Keypath.swift
//  ParseTester
//
//  Created by Alex Apprime on 20.05.17.
//  Copyright © 2017 apprime. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
    func value(forKeyPath keyPath: String) -> Any? {
        guard !keyPath.isEmpty else { return nil }
        let keys = keyPath.components(separatedBy: ".")
        guard let firstKey = keys.first,
            let val = self[firstKey] else { return nil }
        if keys.count > 1 {
            if let arr = val as? [Any],
                let index = Int(keys[1]),
                index > -1,
                index < arr.count {
                if keys.count > 2 {
                    let newKey = keys.suffix(from: 2).joined(separator: ".")
                    return (arr[index] as? [String: Any])?.value(forKeyPath: newKey)
                } else {
                    return arr[index]
                }
            } else if let dict = val as? [String: Any] {
                let newKey = keys.suffix(from: 1).joined(separator: ".")
                return dict.value(forKeyPath: newKey)
            } else {
                return nil
            }
        }
        return val
    }
}
