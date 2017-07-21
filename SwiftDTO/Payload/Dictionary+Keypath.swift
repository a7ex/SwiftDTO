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
    func arrayValue(forKeyPath keyPath: String) -> [Any]? {
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
                    return (arr[index] as? [String: Any])?.arrayValue(forKeyPath: newKey)
                } else {
                    return forceArray(for: arr[index])
                }
            } else if let dict = val as? [String: Any] {
                let newKey = keys.suffix(from: 1).joined(separator: ".")
                return dict.arrayValue(forKeyPath: newKey)
            } else {
                return nil
            }
        }
        return forceArray(for: val)
    }
    private func forceArray(for obj: Any?) -> [Any]? {
        guard let obj = obj else { return nil }
        guard let arrObj = obj as? [Any] else { return [obj] }
        return arrObj
    }
}

extension Dictionary where Key == String, Value == Any {
    mutating func setValue(_ value: Any, forKeyPath keyPath: String) {
        guard !keyPath.isEmpty else { return }
        let keys = keyPath.components(separatedBy: ".")
        if keys.count > 1 {
            var subdict: [String: Any]
            if let val = self[keys.first!] as? [String: Any] {
                subdict = val
            } else {
                subdict = [String: Any]()
            }
            let newKey = keys.suffix(from: 1).joined(separator: ".")
            subdict.setValue(value, forKeyPath: newKey)
            self[keys.first!] = subdict
        } else {
            self[keys.first!] = value
        }
    }
}
