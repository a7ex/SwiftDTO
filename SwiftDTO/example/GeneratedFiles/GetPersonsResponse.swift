//
//  GetPersonsResponse.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct GetPersonsResponse: SessionResponse, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let sessionValidityDate: Date?

    public let pers: Person?

    // Default initializer:
    public init(sessionValidityDate: Date?, pers: Person?) {
        self.sessionValidityDate = sessionValidityDate
        self.pers = pers
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        sessionValidityDate = dateFromAny(jsonData["sessionValidityDate"])

        if let val = PersonalData(jsonData: jsonData["pers"] as? JSOBJ) { self.pers = val }
        else { pers = nil }

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "GetPersonsResponse")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["sessionValidityDate", "pers"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if sessionValidityDate != nil { jsonData["sessionValidityDate"] = stringFromDate(sessionValidityDate!) }

        if pers != nil { jsonData["pers"] = pers!.jsobjRepresentation }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let sessionValidityDate = sessionValidityDate { returnString.append("    \(prefix)\"sessionValidityDate\": \"\(stringFromDate(sessionValidityDate))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"sessionValidityDate\": null,\n") }

        if let pers = pers { returnString.append("    \(prefix)\"pers\": \("\(pers.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"pers\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
