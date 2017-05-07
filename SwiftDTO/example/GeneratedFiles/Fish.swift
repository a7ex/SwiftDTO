//
//  Fish.swift
//  conradkiosk
//
//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct Fish: Animal, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let name: String?
    public let animalType: AnimalType?

    public let numberOfFins: Int?

    // Default initializer:
    public init(name: String?, animalType: AnimalType?, numberOfFins: Int?) {
        self.name = name
        self.animalType = animalType
        self.numberOfFins = numberOfFins
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        name = ConversionHelper.stringFromAny(jsonData["name"])
        animalType = AnimalType.byString(jsonData["animalType"] as? String)

        numberOfFins = jsonData["numberOfFins"] as? Int

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "Fish")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["name", "animalType", "numberOfFins"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if name != nil { jsonData["name"] = name! }
        if animalType != nil { jsonData["animalType"] = animalType!.rawValue }

        if numberOfFins != nil { jsonData["numberOfFins"] = numberOfFins! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let name = name { returnString.append("    \(prefix)\"name\": \"\(name)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"name\": null,\n") }

        if let animalType = animalType { returnString.append("    \(prefix)\"animalType\": \("\"\(animalType.rawValue)\""),\n") }
        else if printNulls { returnString.append("    \(prefix)\"animalType\": null,\n") }

        if let numberOfFins = numberOfFins { returnString.append("    \(prefix)\"numberOfFins\": \(numberOfFins),\n") }
        else if printNulls { returnString.append("    \(prefix)\"numberOfFins\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString = returnString + "\n\(prefix)}"
        return returnString
    }
}
