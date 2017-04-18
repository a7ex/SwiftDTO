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
    
    /// If in DEBUG mode we call this in order to list differences between
    /// the expected JSON and the actually received JSON
    /// If there are any, print the differences into the console
    static func analize(jsonData: JSOBJ, expectedKeys: Set<String>, inClassWithName clsName: String) {
        let allKeys = Set(jsonData.keys)
        let additionalKeys = allKeys.subtracting(expectedKeys)
        
        // set the following boolean to false to also get diagnostic console output
        // for keys, which exits in the DTO, but not in the JSON
        // Since that is more often the case, the default for 'onlyShowAdditionKeys' is true
        let onlyShowAdditionKeys = true
        
        let missingKeys = onlyShowAdditionKeys ? Set<String>(): expectedKeys.subtracting(allKeys)
        if missingKeys.isEmpty, additionalKeys.isEmpty { return }
        print("\n-------------------\nConradDTO debug data for \"\(clsName)\":")
        if !missingKeys.isEmpty { print("Missing in JSON: \(missingKeys)") }
        if !additionalKeys.isEmpty { print("Missing in code: \(additionalKeys)") }
        print("-------------------\n")
    }
    
    static func unknownEnumCase(_ enumCase: String?, inEnum enumName: String) {
        print("\n-------------------\nConradDTO debug data: Missing case \"\(enumCase)\" in Enum: \"\(enumName)\":")
        print("-------------------\n")
    }
}

struct ConversionHelper {
    
    /**
     Try to convert an Any value to a NSDate object
     
     Try to convert the input to a String, Int or Double and call the corresponding date creator
     
     - parameter dateObj: Any representing a date in either String or Timestamp
     
     - returns: NSDate object corresponding to input
     */
    static func dateFromAny(_ dateObj: Any?) -> Date? {
        let helper = ConversionHelper()
        if let inputString = dateObj as? String { return helper.dateFromString(inputString) }
        if let doubleVal = dateObj as? Double { return helper.dateFromDouble(doubleVal) }
        if let intVal = dateObj as? Int { return helper.dateFromLong(intVal) }
        return nil
    }
    
    /**
     Convert an NSDate object to a string representing a date in ISO 8601 format (default)
     
     - parameter dateObj: NSDate object
     - parameter format: Format string for date (default is ISO 8601 format)
     
     - returns: String representing a date in the chosen format (default: ISO 8601)
     */
    static func stringFromDate(_ dateObj:Date, withFormat format: String="yyyy-MM-dd'T'HH:mm:ss.sZZZZZ") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: dateObj)
    }
    
    /**
     Parsing a String is a bit more complicated, because if a property of type string is e.g. "true" it will appear as boolean after NSJSONSerialization and so "jsonObject as? String" will be nil. Thanks to automatic type casting if the string is "true", "false" or "1" or "2.3"
     
     - parameter jsonObject: Any or nil (one value in the dictionary, which NSJSONSerialization produces)
     
     - returns: String or nil
     */
    static func stringFromAny(_ jsonObject:Any?) -> String? {
        if let val = jsonObject as? String { return val }
        if let val = jsonObject as? Bool { return String(describing: val) }
        if let val = jsonObject as? Int { return String(describing: val) }
        if let val = jsonObject as? Double { return String(describing: val) }
        return nil
    }
    
    /**
     Try to convert a string representing a date to a NSDate object
     
     Start with ISO 8601 format, then our "Conrad German date format", then a timestamp
     
     - parameter dateString: String representing a date in ISO 8601 format
     
     - returns: NSDate object corresponding to input string
     */
    private func dateFromString(_ dateString: String?) -> Date? {
        guard let inputString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.ssZZZZZ"
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
    
    private func dateFromDouble(_ timestamp: Double?) -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: (timestamp/1000.0))
    }
    
    private func dateFromLong(_ timestamp: Int?) -> Date? {
        guard let timestamp = timestamp else {
            return nil
        }
        return Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
}

/// A result enum with two cases: 'success' or 'failure'
/// The success case provides the result as associated value
/// The failure case provides an error as associated value
public enum DTOResult<T, E: Error>{
    case success(T)
    case failure(E)
    
    func flatMap<P>(_ f:(T) -> DTOResult<P, NSError>) -> DTOResult<P, NSError> {
        switch self {
        case .success(let value):
            return f(value)
        case .failure(let error):
            return DTOResult<P, NSError>.failure(error as NSError)
        }
    }
}


/// Helper struct to parse input to DTO object of array of DTO objects
/// Input can be either Data or String or [String: Any] or [Any]
/// Thus you can parse a network response (data or string), a json string
/// or any Dictionary ([String: Any]) or any Array
public struct DTOParser {
    
    
    /// Parse a single DTO Object
    ///
    /// - Parameter data: Data, String, Dictionary or Array
    /// - Returns: a DTOResult object with either the result or the error as associated value
    public func parse<T: JSOBJSerializable>(_ data: Any) -> DTOResult<T, NSError> {
        let decodedData = decodeData(data)
        return decodedData.flatMap({ (obj: Any) -> DTOResult<T, NSError> in
            guard let dto = T(jsonData: obj as? JSOBJ) else {
                return .failure(createError(with: -19, message: "Object not mappable"))
            }
            return .success(dto)
        })
    }
    
    /// Parse an array of DTO objects
    ///
    /// - Parameter data: Data, String, Dictionary or Array
    /// - Returns: a DTOResult object with either the result or the error as associated value
    public func parse<T: JSOBJSerializable>(_ data: Any) -> DTOResult<[T], NSError> {
        let decodedData = decodeData(data)
        return decodedData.flatMap({ (obj: Any) -> DTOResult<[T], NSError> in
            guard let array = obj as? [Any] else {
                return .failure(createError(with: -19, message: "Object not mappable"))
            }
            return arrayToModels(array)
        })
    }
    
    //MARK: - Private interface
    
    private func arrayToModels<T: JSOBJSerializable>(_ objects: [Any]) -> DTOResult<[T], NSError> {
        let rslt = objects.flatMap { T(jsonData: $0 as? JSOBJ) }
        return .success(rslt)
    }
    
    private func decodeData(_ input: Any) -> DTOResult<Any, NSError> {
        if let dict = input as? [String: Any] { return .success(dict) }
        if let arr = input as? [Any] { return .success(arr) }
        let data = input as? Data ?? (input as? String)?.data(using: .utf8)
        
        let defaultError = createError(with: -18, message: "No vaid data to decode to JSON!")
        
        if data == nil { return .failure(defaultError) }
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions())
            return .success(json)
        }
        catch let error {
            return .failure(error as NSError)
        }
    }
    
    private func createError(with code: Int, message: String) -> NSError {
        return NSError(domain: "com.farbflash.DTOParser", code: code, userInfo: [NSLocalizedDescriptionKey: message])
    }
}

