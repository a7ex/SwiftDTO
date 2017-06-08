//
//  GetTracksRequest.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct GetTracksRequest: SessionRequest, DefaultRequest, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let session: String?
    public let locale: String?

    public let from: Date?
    public let to: Date?
    public let validated: Bool?

    // Default initializer:
    public init(session: String?, locale: String?, from: Date?, to: Date?, validated: Bool?) {
        self.session = session
        self.locale = locale
        self.from = from
        self.to = to
        self.validated = validated
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        session = stringFromAny(jsonData["session"])
        locale = stringFromAny(jsonData["locale"])

        from = dateFromAny(jsonData["from"])
        to = dateFromAny(jsonData["to"])
        validated = boolFromAny(jsonData["validated"])

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "GetTracksRequest")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["session", "locale", "from", "to", "validated"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if session != nil { jsonData["session"] = session! }
        if locale != nil { jsonData["locale"] = locale! }

        if from != nil { jsonData["from"] = stringFromDate(from!) }
        if to != nil { jsonData["to"] = stringFromDate(to!) }
        if validated != nil { jsonData["validated"] = validated! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let session = session { returnString.append("    \(prefix)\"session\": \"\(session)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"session\": null,\n") }

        if let locale = locale { returnString.append("    \(prefix)\"locale\": \"\(locale)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"locale\": null,\n") }

        if let from = from { returnString.append("    \(prefix)\"from\": \"\(stringFromDate(from))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"from\": null,\n") }

        if let to = to { returnString.append("    \(prefix)\"to\": \"\(stringFromDate(to))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"to\": null,\n") }

        if let validated = validated { returnString.append("    \(prefix)\"validated\": \(validated),\n") }
        else if printNulls { returnString.append("    \(prefix)\"validated\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
