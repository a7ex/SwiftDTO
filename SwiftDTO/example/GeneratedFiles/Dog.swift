//
//  Dog.swift
//  conradkiosk
//
//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct Dog: JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let numberOfLegs: Int?

    // Default initializer:
    public init(numberOfLegs: Int?) {
        self.numberOfLegs = numberOfLegs
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        numberOfLegs = jsonData["numberOfLegs"] as? Int ?? 0

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "Dog")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["numberOfLegs"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if numberOfLegs != nil { jsonData["numberOfLegs"] = numberOfLegs! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let numberOfLegs = numberOfLegs { returnString.append("    \(prefix)\"numberOfLegs\": \(numberOfLegs),\n") }
        else if printNulls { returnString.append("    \(prefix)\"numberOfLegs\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
