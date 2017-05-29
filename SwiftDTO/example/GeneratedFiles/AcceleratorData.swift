//
//  AcceleratorData.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct AcceleratorData: JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let ts: Date?
    public let x: Double?
    public let y: Double?
    public let z: Double?

    // Default initializer:
    public init(ts: Date?, x: Double?, y: Double?, z: Double?) {
        self.ts = ts
        self.x = x
        self.y = y
        self.z = z
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        ts = dateFromAny(jsonData["ts"])
        x = jsonData["x"] as? Double
        y = jsonData["y"] as? Double
        z = jsonData["z"] as? Double

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "AcceleratorData")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["ts", "x", "y", "z"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if ts != nil { jsonData["ts"] = stringFromDate(ts!) }
        if x != nil { jsonData["x"] = x! }
        if y != nil { jsonData["y"] = y! }
        if z != nil { jsonData["z"] = z! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let ts = ts { returnString.append("    \(prefix)\"ts\": \"\(stringFromDate(ts))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"ts\": null,\n") }

        if let x = x { returnString.append("    \(prefix)\"x\": \(x),\n") }
        else if printNulls { returnString.append("    \(prefix)\"x\": null,\n") }

        if let y = y { returnString.append("    \(prefix)\"y\": \(y),\n") }
        else if printNulls { returnString.append("    \(prefix)\"y\": null,\n") }

        if let z = z { returnString.append("    \(prefix)\"z\": \(z),\n") }
        else if printNulls { returnString.append("    \(prefix)\"z\": null,\n") }


        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}