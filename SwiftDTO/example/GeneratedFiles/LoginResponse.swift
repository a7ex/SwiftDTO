//
//  LoginResponse.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct LoginResponse: SessionResponse, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let sessionValidityDate: Date?

    public let passwordUpdateRecommended: Bool?
    public let personalDataUpdateRecommended: Bool?
    public let profile: Profile?
    public let session: String?

    // Default initializer:
    public init(sessionValidityDate: Date?, passwordUpdateRecommended: Bool?, personalDataUpdateRecommended: Bool?, profile: Profile?, session: String?) {
        self.sessionValidityDate = sessionValidityDate
        self.passwordUpdateRecommended = passwordUpdateRecommended
        self.personalDataUpdateRecommended = personalDataUpdateRecommended
        self.profile = profile
        self.session = session
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        sessionValidityDate = dateFromAny(jsonData["sessionValidityDate"])

        passwordUpdateRecommended = boolFromAny(jsonData["passwordUpdateRecommended"])
        personalDataUpdateRecommended = boolFromAny(jsonData["personalDataUpdateRecommended"])
        if let val = Profile(jsonData: jsonData["profile"] as? JSOBJ) { self.profile = val }
        else { profile = nil }
        session = stringFromAny(jsonData["session"])

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "LoginResponse")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["sessionValidityDate", "passwordUpdateRecommended", "personalDataUpdateRecommended", "profile", "session"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if sessionValidityDate != nil { jsonData["sessionValidityDate"] = stringFromDate(sessionValidityDate!) }

        if passwordUpdateRecommended != nil { jsonData["passwordUpdateRecommended"] = passwordUpdateRecommended! }
        if personalDataUpdateRecommended != nil { jsonData["personalDataUpdateRecommended"] = personalDataUpdateRecommended! }
        if profile != nil { jsonData["profile"] = profile!.jsobjRepresentation }
        if session != nil { jsonData["session"] = session! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let sessionValidityDate = sessionValidityDate { returnString.append("    \(prefix)\"sessionValidityDate\": \"\(stringFromDate(sessionValidityDate))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"sessionValidityDate\": null,\n") }

        if let passwordUpdateRecommended = passwordUpdateRecommended { returnString.append("    \(prefix)\"passwordUpdateRecommended\": \(passwordUpdateRecommended),\n") }
        else if printNulls { returnString.append("    \(prefix)\"passwordUpdateRecommended\": null,\n") }

        if let personalDataUpdateRecommended = personalDataUpdateRecommended { returnString.append("    \(prefix)\"personalDataUpdateRecommended\": \(personalDataUpdateRecommended),\n") }
        else if printNulls { returnString.append("    \(prefix)\"personalDataUpdateRecommended\": null,\n") }

        if let profile = profile { returnString.append("    \(prefix)\"profile\": \("\(profile.jsonString(paddingPrefix: "\(prefix)    ", printNulls: printNulls))"),\n") }
        else if printNulls { returnString.append("    \(prefix)\"profile\": null,\n") }

        if let session = session { returnString.append("    \(prefix)\"session\": \"\(session)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"session\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
