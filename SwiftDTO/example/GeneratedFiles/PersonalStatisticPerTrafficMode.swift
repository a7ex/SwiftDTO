//
//  PersonalStatisticPerTrafficMode.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct PersonalStatisticPerTrafficMode: JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let tfcMode: TrafficMode?
    public let travelTime: Int?
    public let travelledDist: Int?

    // Default initializer:
    public init(tfcMode: TrafficMode?, travelTime: Int?, travelledDist: Int?) {
        self.tfcMode = tfcMode
        self.travelTime = travelTime
        self.travelledDist = travelledDist
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        if let val = TrafficMode(jsonData: jsonData["tfcMode"] as? JSOBJ) { self.tfcMode = val }
        else { tfcMode = nil }
        travelTime = jsonData["travelTime"] as? Int
        travelledDist = jsonData["travelledDist"] as? Int

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "PersonalStatisticPerTrafficMode")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["tfcMode", "travelTime", "travelledDist"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if tfcMode != nil { jsonData["tfcMode"] = tfcMode!.jsobjRepresentation }
        if travelTime != nil { jsonData["travelTime"] = travelTime! }
        if travelledDist != nil { jsonData["travelledDist"] = travelledDist! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let tfcMode = tfcMode { returnString.append("    \(prefix)\"tfcMode\": \("\(tfcMode.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"tfcMode\": null,\n") }

        if let travelTime = travelTime { returnString.append("    \(prefix)\"travelTime\": \(travelTime),\n") }
        else if printNulls { returnString.append("    \(prefix)\"travelTime\": null,\n") }

        if let travelledDist = travelledDist { returnString.append("    \(prefix)\"travelledDist\": \(travelledDist),\n") }
        else if printNulls { returnString.append("    \(prefix)\"travelledDist\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
