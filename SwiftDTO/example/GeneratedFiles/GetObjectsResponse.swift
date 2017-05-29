//
//  GetObjectsResponse.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct GetObjectsResponse: DefaultResponse, Information, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let errs: QuantifiableError?
    public let wrngs: QuantifiableWarning?

    public let lentObjs: LentObj?
    public let nonLentObjs: Obj?

    // Default initializer:
    public init(errs: QuantifiableError?, wrngs: QuantifiableWarning?, lentObjs: LentObj?, nonLentObjs: Obj?) {
        self.errs = errs
        self.wrngs = wrngs
        self.lentObjs = lentObjs
        self.nonLentObjs = nonLentObjs
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        if let val = QuantifiableError(jsonData: jsonData["errs"] as? JSOBJ) { self.errs = val }
        else { errs = nil }
        if let val = QuantifiableWarning(jsonData: jsonData["wrngs"] as? JSOBJ) { self.wrngs = val }
        else { wrngs = nil }

        if let val = LentObj(jsonData: jsonData["lentObjs"] as? JSOBJ) { self.lentObjs = val }
        else { lentObjs = nil }
        if let val = LentObj(jsonData: jsonData["nonLentObjs"] as? JSOBJ) { self.nonLentObjs = val }
        else { nonLentObjs = nil }

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "GetObjectsResponse")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["errs", "wrngs", "lentObjs", "nonLentObjs"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if errs != nil { jsonData["errs"] = errs!.jsobjRepresentation }
        if wrngs != nil { jsonData["wrngs"] = wrngs!.jsobjRepresentation }

        if lentObjs != nil { jsonData["lentObjs"] = lentObjs!.jsobjRepresentation }
        if nonLentObjs != nil { jsonData["nonLentObjs"] = nonLentObjs!.jsobjRepresentation }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let errs = errs { returnString.append("    \(prefix)\"errs\": \("\(errs.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"errs\": null,\n") }

        if let wrngs = wrngs { returnString.append("    \(prefix)\"wrngs\": \("\(wrngs.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"wrngs\": null,\n") }

        if let lentObjs = lentObjs { returnString.append("    \(prefix)\"lentObjs\": \("\(lentObjs.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"lentObjs\": null,\n") }

        if let nonLentObjs = nonLentObjs { returnString.append("    \(prefix)\"nonLentObjs\": \("\(nonLentObjs.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"nonLentObjs\": null,\n") }


        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}