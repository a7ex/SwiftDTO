//
//  DTO_Globals.swift
//
//  Automatically created by SwiftDTO.
//

// DO NOT EDIT THIS FILE!
// This file was automatically generated from an xcmodel file (CoreData XML Scheme)
// Please edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public typealias JSOBJ = [String: Any]
public typealias JSARR = [JSOBJ]

public protocol PrettyJson {
    func jsonString(paddingPrefix prefix: String, printNulls: Bool) -> String
}

public protocol DictionaryConvertible: PrettyJson {
    var jsobjRepresentation: JSOBJ { get }
}

public protocol JSOBJSerializable {
    init?(jsonData: JSOBJ?)
}

struct DTODiagnostics {

    // set the following boolean to false to also get diagnostic console output
    // for keys, which exits in the DTO, but not in the JSON
    // Since that is more often the case, the default for 'onlyShowAdditionKeys' is true
    static let onlyShowAdditionKeys = true

    /// If in DEBUG mode we call this in order to list differences between
    /// the expected JSON and the actually received JSON
    /// If there are any, print the differences into the console
    static func analize(jsonData: JSOBJ, expectedKeys: Set<String>, inClassWithName clsName: String) {
        let allKeys = Set(jsonData.keys)
        let additionalKeys = allKeys.subtracting(expectedKeys)

        let missingKeys = onlyShowAdditionKeys ? Set<String>(): expectedKeys.subtracting(allKeys)
        if missingKeys.isEmpty, additionalKeys.isEmpty { return }
        print("\n-------------------\nConradDTO debug data for \"\(clsName)\":")
        if !missingKeys.isEmpty { print("Missing in JSON: \(missingKeys)") }
        if !additionalKeys.isEmpty { print("Missing in code: \(additionalKeys)") }
        print("-------------------\n")
    }

    static func unknownEnumCase(_ enumCase: String?, inEnum enumName: String) {
        print("\n-------------------\nConradDTO debug data: Missing case \"\(enumCase ?? "<empty enumCase>")\" in Enum: \"\(enumName)\":")
        print("-------------------\n")
    }
}

/**
 Try to convert an Any value to a NSDate object

 Try to convert the input to a String, Int or Double and call the corresponding date creator

 - parameter dateObj: Any representing a date in either String or Timestamp

 - returns: NSDate object corresponding to input
 */
func dateFromAny(_ dateObj: Any?) -> Date? {
    let helper = ConversionHelper()
    if let date = dateObj as? Date { return date }
    if let inputString = dateObj as? String { return helper.dateFromString(inputString) }
    if let doubleVal = dateObj as? Double { return helper.dateFromDouble(doubleVal) }
    if let intVal = dateObj as? Int { return helper.dateFromLong(intVal) }
    if let parseDate = dateObj as? JSOBJ { return helper.dateFromParse(parseDate) }
    return nil
}

/**
 Convert an NSDate object to a string representing a date in ISO 8601 format (default)

 - parameter dateObj: NSDate object
 - parameter format: Format string for date (default is ISO 8601 format)

 - returns: String representing a date in the chosen format (default: ISO 8601)
 */
func stringFromDate(_ dateObj: Date, withFormat format: String="yyyy-MM-dd'T'HH:mm:ss.sZZZZZ") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: dateObj)
}

/**
 Parsing a String is a bit more complicated, because if a property of type string is e.g. "true"
 it will appear as boolean after NSJSONSerialization and so "jsonObject as? String" will be nil.
 Thanks to automatic type casting if the string is "true", "false" or "1" or "2.3"

 - parameter jsonObject: Any or nil (one value in the dictionary, which NSJSONSerialization produces)

 - returns: String or nil
 */
func stringFromAny(_ jsonObject:Any?) -> String? {
    if let val = jsonObject as? String { return val }
    if let val = jsonObject as? Bool { return String(describing: val) }
    if let val = jsonObject as? Int { return String(describing: val) }
    if let val = jsonObject as? Double { return String(describing: val) }
    return nil
}

/**
 Try to convert an Any value to a Bool

 - parameter jsonObject: Any or nil (one value in the dictionary, which NSJSONSerialization produces)

 - returns: String or nil
 */
func boolFromAny(_ jsonObject: Any?) -> Bool? {
    if let val = jsonObject as? Bool { return val }
    if let val = jsonObject as? String {
        switch val.lowercased() {
        case "true", "yes": return true
        case "false", "no": return false
        default: return nil
        }
    }
    if let val = jsonObject as? Int { return val != 0 }
    if let val = jsonObject as? Double { return val != 0 }
    return nil
}

/**
 Try to convert an Any value to an Int
 
 Unfortunately some backends send Ints or Doubles as Strings
 or, in the current case,
 Parse Cloud functions do that :-(
 So we need to "force" Ints, if any possible.
 Sure we could do that by overloading the value(forKeyPath) method
 but overloading doesn't do much else than two differently named functions
 would do, performance wise, instead overloading just helps to write less, "cleaner", code
 But this is automated code anyway... nobody should need to read and understand it :-)

 - parameter jsonObject: Any or nil (one value in the dictionary, which NSJSONSerialization produces)

 - returns: Int or nil
 */
func intFromAny(_ jsonObject: Any?) -> Int? {
    if let val = jsonObject as? Int { return val }
    if let val = jsonObject as? Double {
        return val.integerValue
    }
    if let val = jsonObject as? String {
        let fmt = NumberFormatter()
        if let numValue = fmt.number(from: val) {
        return numValue.intValue
        }
        fmt.locale = Locale(identifier: "de_DE") // a locale, which uses ',' as float delimiter
        if let numValue = fmt.number(from: val) {
            return numValue.intValue
        }
    }
    return nil
}

/**
 Try to convert an Any value to a Double

 Unfortunately some backends send Ints or Doubles as Strings
 or, in the current case,
 Parse Cloud functions do that :-(
 So we need to "force" Double, if any possible.
 Sure we could do that by overloading the value(forKeyPath) method
 but overloading doesn't do much else than two differently named functions
 would do, performance wise, instead overloading just helps to write less, "cleaner", code
 But this is automated code anyway... nobody should need to read and understand it :-)

 - parameter jsonObject: Any or nil (one value in the dictionary, which NSJSONSerialization produces)

 - returns: Int or nil
 */
func doubleFromAny(_ jsonObject: Any?) -> Double? {
    if let val = jsonObject as? Double { return val }
    if let val = jsonObject as? Int { return Double(val) }
    if let val = jsonObject as? String {
        let fmt = NumberFormatter()
        if let numValue = fmt.number(from: val) {
            return numValue.doubleValue
        }
        fmt.locale = Locale(identifier: "en_US") // a locale, which uses '.' as float delimiter
        if let numValue = fmt.number(from: val) {
            return numValue.doubleValue
        }
        fmt.locale = Locale(identifier: "de_DE") // a locale, which uses ',' as float delimiter
        if let numValue = fmt.number(from: val) {
            return numValue.doubleValue
        }
    }
    return nil
}

extension Double {
    var integerValue: Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}

struct ConversionHelper {
    /**
     Try to convert a string representing a date to a NSDate object

     Start with ISO 8601 format, then our "Conrad German date format", then a timestamp
     
     - parameter dateString: String representing a date in ISO 8601 format
     
     - returns: NSDate object corresponding to input string
     */
    fileprivate func dateFromString(_ dateString: String?) -> Date? {
        guard let inputString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SZZZZZ"
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ssZZZZZ"
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        dateFormatter.dateFormat = "yyyy'-'MM'-'ddZZZZZ"
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd"
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        dateFormatter.dateFormat = "dd'-'MM'-'yyyy"
        if let retVal = dateFormatter.date(from: inputString) { return retVal }
        if let doubleVal = Double(inputString) { return dateFromDouble(doubleVal) }
        if let intVal = Int(inputString) { return dateFromLong(intVal) }
        return nil
    }

    fileprivate func dateFromDouble(_ timestamp: Double?) -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: (timestamp/1000.0))
    }

    fileprivate func dateFromLong(_ timestamp: Int?) -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    fileprivate func dateFromParse(_ parsedate: JSOBJ?) -> Date? {
        guard let parsedate = parsedate else {
            return nil
        }
//        "__type": "Date",
//        "iso": "2017-07-04T00:00:00.000Z"
        return dateFromString(parsedate["iso"] as? String)
    }
}

/// Helper struct to parse input to DTO object of array of DTO objects
/// Input can be either Data or String or [String: Any] or [Any]
/// Thus you can parse a network response (data or string), a json string
/// or any Dictionary ([String: Any]) or any Array

public protocol DTOParsing {
    func parse<T: JSOBJSerializable>(_ data: Any) throws -> T
    func parse<T: JSOBJSerializable>(_ data: Any) throws  -> [T]
}

public struct DTOParser: DTOParsing {

    public init() {}

    /// Parse a single DTO Object
    ///
    /// - Parameter data: Data, String, Dictionary or Array
    /// - Returns: DTO object
    /// - Throws: NSError
    public func parse<T: JSOBJSerializable>(_ data: Any) throws -> T {
        let obj = try decodeData(data)
        guard let dto = T(jsonData: obj as? JSOBJ) else {
            throw createError(with: -19, message: "Object not mappable")
        }
        return dto
    }

    /// Parse an array of DTO objects
    ///
    /// - Parameter data: Data, String, Dictionary or Array
    /// - Returns: array of DTOs
    /// - Throws: NSError
    public func parse<T: JSOBJSerializable>(_ data: Any) throws  -> [T] {
        let obj = try decodeData(data)
        guard let array = obj as? [Any] else {
            throw createError(with: -19, message: "Object not mappable")
        }
        return array.flatMap { T(jsonData: $0 as? JSOBJ) }
    }

    // MARK: - Private interface

    private func decodeData(_ input: Any) throws -> Any {
        if let dict = input as? [String: Any] { return dict }
        if let arr = input as? [Any] { return arr }

        let defaultError = createError(with: -18, message: "No vaid data to decode to JSON!")
        guard let data = input as? Data ?? (input as? String)?.data(using: .utf8) else { throw defaultError }

        let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions())
        return json
    }

    private func createError(with code: Int, message: String) -> NSError {
        return NSError(domain: "com.farbflash.DTOParser", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}
