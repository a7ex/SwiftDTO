//
//  AddPoiRequest.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct AddPoiRequest: AbstractPoiRequest, SessionRequest, DefaultRequest, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let poi: Poi?
    public let session: String?
    public let locale: String?

    // Default initializer:
    public init(poi: Poi?, session: String?, locale: String?) {
        self.poi = poi
        self.session = session
        self.locale = locale
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        if let val = Poi(jsonData: jsonData["poi"] as? JSOBJ) { self.poi = val }
        else { poi = nil }
        session = stringFromAny(jsonData["session"])
        locale = stringFromAny(jsonData["locale"])

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "AddPoiRequest")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["poi", "session", "locale"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if poi != nil { jsonData["poi"] = poi!.jsobjRepresentation }
        if session != nil { jsonData["session"] = session! }
        if locale != nil { jsonData["locale"] = locale! }

        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let poi = poi { returnString.append("    \(prefix)\"poi\": \("\(poi.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"poi\": null,\n") }

        if let session = session { returnString.append("    \(prefix)\"session\": \"\(session)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"session\": null,\n") }

        if let locale = locale { returnString.append("    \(prefix)\"locale\": \"\(locale)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"locale\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
