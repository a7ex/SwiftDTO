//
//  Graduation.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct Graduation: JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let id: Int?
    public let name: String?

    // Default initializer:
    public init(id: Int?, name: String?) {
        self.id = id
        self.name = name
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        id = jsonData["id"] as? Int
        name = stringFromAny(jsonData["name"])

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "Graduation")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["id", "name"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if id != nil { jsonData["id"] = id! }
        if name != nil { jsonData["name"] = name! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let id = id { returnString.append("    \(prefix)\"id\": \(id),\n") }
        else if printNulls { returnString.append("    \(prefix)\"id\": null,\n") }

        if let name = name { returnString.append("    \(prefix)\"name\": \"\(name)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"name\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
