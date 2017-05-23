//
//  GetPersonsRequest.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public struct GetPersonsRequest: SessionRequest, JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {

    // DTO properties:
    public let session: String?

    public let accessForAdmUsersAllowed: Bool?
    public let alphaChar: Int?
    public let alreadyParticipateInCampaigns: Bool?
    public let companyIds: Int?
    public let gender: Bool?
    public let maxAge: Int?
    public let minAge: Int?
    public let mtrVehAvail: Bool?
    public let neverLoggedIn: Bool?
    public let occs: Int?
    public let operation: Bool?
    public let ptSubscrAvail: Bool?
    public let registeredSince: Date?
    public let roles: RoleConstant?
    public let searchTerm: String?
    public let tfcModes: TrafficModeConstant?
    public let zipCodes: String?

    // Default initializer:
    public init(session: String?, accessForAdmUsersAllowed: Bool?, alphaChar: Int?, alreadyParticipateInCampaigns: Bool?, companyIds: Int?, gender: Bool?, maxAge: Int?, minAge: Int?, mtrVehAvail: Bool?, neverLoggedIn: Bool?, occs: Int?, operation: Bool?, ptSubscrAvail: Bool?, registeredSince: Date?, roles: RoleConstant?, searchTerm: String?, tfcModes: TrafficModeConstant?, zipCodes: String?) {
        self.session = session
        self.accessForAdmUsersAllowed = accessForAdmUsersAllowed
        self.alphaChar = alphaChar
        self.alreadyParticipateInCampaigns = alreadyParticipateInCampaigns
        self.companyIds = companyIds
        self.gender = gender
        self.maxAge = maxAge
        self.minAge = minAge
        self.mtrVehAvail = mtrVehAvail
        self.neverLoggedIn = neverLoggedIn
        self.occs = occs
        self.operation = operation
        self.ptSubscrAvail = ptSubscrAvail
        self.registeredSince = registeredSince
        self.roles = roles
        self.searchTerm = searchTerm
        self.tfcModes = tfcModes
        self.zipCodes = zipCodes
    }

    // Object creation using JSON dictionary representation from NSJSONSerializer:
    public init?(jsonData: JSOBJ?) {
        guard let jsonData = jsonData else { return nil }
        session = stringFromAny(jsonData["session"])

        accessForAdmUsersAllowed = boolFromAny(jsonData["accessForAdmUsersAllowed"])
        alphaChar = jsonData["alphaChar"] as? Int
        alreadyParticipateInCampaigns = boolFromAny(jsonData["alreadyParticipateInCampaigns"])
        companyIds = jsonData["companyIds"] as? Int
        gender = boolFromAny(jsonData["gender"])
        maxAge = jsonData["maxAge"] as? Int
        minAge = jsonData["minAge"] as? Int
        mtrVehAvail = boolFromAny(jsonData["mtrVehAvail"])
        neverLoggedIn = boolFromAny(jsonData["neverLoggedIn"])
        occs = jsonData["occs"] as? Int
        operation = boolFromAny(jsonData["operation"])
        ptSubscrAvail = boolFromAny(jsonData["ptSubscrAvail"])
        registeredSince = dateFromAny(jsonData["registeredSince"])
        if let val = RoleConstant.byString(jsonData["roles"] as? String) { self.roles = val }
        else { roles = nil }
        searchTerm = stringFromAny(jsonData["searchTerm"])
        if let val = TrafficModeConstant.byString(jsonData["tfcModes"] as? String) { self.tfcModes = val }
        else { tfcModes = nil }
        zipCodes = stringFromAny(jsonData["zipCodes"])

        #if DEBUG
            DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: "GetPersonsRequest")
        #endif
    }

    // all expected keys (for diagnostics in debug mode):
    public var allExpectedKeys: Set<String> {
        return Set(["session", "accessForAdmUsersAllowed", "alphaChar", "alreadyParticipateInCampaigns", "companyIds", "gender", "maxAge", "minAge", "mtrVehAvail", "neverLoggedIn", "occs", "operation", "ptSubscrAvail", "registeredSince", "roles", "searchTerm", "tfcModes", "zipCodes"])
    }

    // dictionary representation (for use with NSJSONSerializer or as parameters for URL request):
    public var jsobjRepresentation: JSOBJ {
        var jsonData = JSOBJ()
        if session != nil { jsonData["session"] = session! }

        if accessForAdmUsersAllowed != nil { jsonData["accessForAdmUsersAllowed"] = accessForAdmUsersAllowed! }
        if alphaChar != nil { jsonData["alphaChar"] = alphaChar! }
        if alreadyParticipateInCampaigns != nil { jsonData["alreadyParticipateInCampaigns"] = alreadyParticipateInCampaigns! }
        if companyIds != nil { jsonData["companyIds"] = companyIds! }
        if gender != nil { jsonData["gender"] = gender! }
        if maxAge != nil { jsonData["maxAge"] = maxAge! }
        if minAge != nil { jsonData["minAge"] = minAge! }
        if mtrVehAvail != nil { jsonData["mtrVehAvail"] = mtrVehAvail! }
        if neverLoggedIn != nil { jsonData["neverLoggedIn"] = neverLoggedIn! }
        if occs != nil { jsonData["occs"] = occs! }
        if operation != nil { jsonData["operation"] = operation! }
        if ptSubscrAvail != nil { jsonData["ptSubscrAvail"] = ptSubscrAvail! }
        if registeredSince != nil { jsonData["registeredSince"] = stringFromDate(registeredSince!) }
        if roles != nil { jsonData["roles"] = roles!.rawValue }
        if searchTerm != nil { jsonData["searchTerm"] = searchTerm! }
        if tfcModes != nil { jsonData["tfcModes"] = tfcModes!.rawValue }
        if zipCodes != nil { jsonData["zipCodes"] = zipCodes! }
        return jsonData
    }

    // printable protocol conformance:
    public var description: String { return "\(jsonString())" }

    // pretty print JSON string representation:
    public func jsonString(paddingPrefix prefix: String = "", printNulls: Bool = false) -> String {
        var returnString = "{\n"

        if let session = session { returnString.append("    \(prefix)\"session\": \"\(session)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"session\": null,\n") }

        if let accessForAdmUsersAllowed = accessForAdmUsersAllowed { returnString.append("    \(prefix)\"accessForAdmUsersAllowed\": \(accessForAdmUsersAllowed),\n") }
        else if printNulls { returnString.append("    \(prefix)\"accessForAdmUsersAllowed\": null,\n") }

        if let alphaChar = alphaChar { returnString.append("    \(prefix)\"alphaChar\": \(alphaChar),\n") }
        else if printNulls { returnString.append("    \(prefix)\"alphaChar\": null,\n") }

        if let alreadyParticipateInCampaigns = alreadyParticipateInCampaigns { returnString.append("    \(prefix)\"alreadyParticipateInCampaigns\": \(alreadyParticipateInCampaigns),\n") }
        else if printNulls { returnString.append("    \(prefix)\"alreadyParticipateInCampaigns\": null,\n") }

        if let companyIds = companyIds { returnString.append("    \(prefix)\"companyIds\": \(companyIds),\n") }
        else if printNulls { returnString.append("    \(prefix)\"companyIds\": null,\n") }

        if let gender = gender { returnString.append("    \(prefix)\"gender\": \(gender),\n") }
        else if printNulls { returnString.append("    \(prefix)\"gender\": null,\n") }

        if let maxAge = maxAge { returnString.append("    \(prefix)\"maxAge\": \(maxAge),\n") }
        else if printNulls { returnString.append("    \(prefix)\"maxAge\": null,\n") }

        if let minAge = minAge { returnString.append("    \(prefix)\"minAge\": \(minAge),\n") }
        else if printNulls { returnString.append("    \(prefix)\"minAge\": null,\n") }

        if let mtrVehAvail = mtrVehAvail { returnString.append("    \(prefix)\"mtrVehAvail\": \(mtrVehAvail),\n") }
        else if printNulls { returnString.append("    \(prefix)\"mtrVehAvail\": null,\n") }

        if let neverLoggedIn = neverLoggedIn { returnString.append("    \(prefix)\"neverLoggedIn\": \(neverLoggedIn),\n") }
        else if printNulls { returnString.append("    \(prefix)\"neverLoggedIn\": null,\n") }

        if let occs = occs { returnString.append("    \(prefix)\"occs\": \(occs),\n") }
        else if printNulls { returnString.append("    \(prefix)\"occs\": null,\n") }

        if let operation = operation { returnString.append("    \(prefix)\"operation\": \(operation),\n") }
        else if printNulls { returnString.append("    \(prefix)\"operation\": null,\n") }

        if let ptSubscrAvail = ptSubscrAvail { returnString.append("    \(prefix)\"ptSubscrAvail\": \(ptSubscrAvail),\n") }
        else if printNulls { returnString.append("    \(prefix)\"ptSubscrAvail\": null,\n") }

        if let registeredSince = registeredSince { returnString.append("    \(prefix)\"registeredSince\": \"\(stringFromDate(registeredSince))\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"registeredSince\": null,\n") }

        if let roles = roles { returnString.append("    \(prefix)\"roles\": \("\"\(roles.rawValue)\""),\n") }
        else if printNulls { returnString.append("    \(prefix)\"roles\": null,\n") }
        if let searchTerm = searchTerm { returnString.append("    \(prefix)\"searchTerm\": \"\(searchTerm)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"searchTerm\": null,\n") }

        if let tfcModes = tfcModes { returnString.append("    \(prefix)\"tfcModes\": \("\"\(tfcModes.rawValue)\""),\n") }
        else if printNulls { returnString.append("    \(prefix)\"tfcModes\": null,\n") }
        if let zipCodes = zipCodes { returnString.append("    \(prefix)\"zipCodes\": \"\(zipCodes)\",\n") }
        else if printNulls { returnString.append("    \(prefix)\"zipCodes\": null,\n") }

        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
        returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        returnString += "\n\(prefix)}"
        return returnString
    }
}
