//
//  XML2SwiftFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2SwiftFiles: BaseExporter, DTOFileGenerator {

    final func generateFiles(inFolder folderPath: String? = nil, withParseSupport parseSupport: Bool = false) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        generateEnums(inDirectory: pwd)
        generateProtocolFiles(inDirectory: pwd)
        generateClassFiles(inDirectory: pwd, withParseSupport: parseSupport)
        generateClassFilesFromCoreData(inDirectory: pwd, withParseSupport: parseSupport)

        createAndExportParentRelationships(inDirectory: pwd)
        copyStaticSwiftFiles(named: ["DTO_Globals"], inDirectory: pwd)
        copyStaticSwiftFiles(named: ["Dictionary+Keypath"], inDirectory: pwd)
    }

    override func fileExtensionForCurrentOutputType() -> String {
        return "swift"
    }

    private final func onlyPrimitives(in restprops: [RESTProperty], parentChain: [ProtocolDeclaration]) -> Bool {
        for thisProp in restprops {
            if !thisProp.isPrimitiveType { return false }
        }
        for ppRestProps in parentChain {
            for thisProp in ppRestProps.restProperties {
                if !thisProp.isPrimitiveType { return false }
            }
        }
        return true
    }

    override func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?, parseSupport: Bool) -> String? {

        var parentChain = [ProtocolDeclaration]()
        if var pp = parentProtocol {
            parentChain.append(pp)
            var pparentName = parser.protocols?.first(where: { $0.name == pp.parentName })?.name
            while pparentName != nil && pparentName?.isEmpty == false {
                pp = (parser.protocols?.first(where: { $0.name == pparentName! }))!
                parentChain.append(pp)
                pparentName = pp.parentName
            }
        }

        var parentPropertyNames = Set<String>()
        for thisPP in parentChain {
            for thisRProp in thisPP.restProperties {
                parentPropertyNames.insert(thisRProp.name)
            }
        }

        let restprops: [RESTProperty]
        if let storedProperties = storedProperties {
            restprops = storedProperties
        } else if let properties = properties {
            restprops = properties.flatMap { RESTProperty(xmlElement: $0,
                                                          enumParentName: nil,
                                                          withEnumNames: parser.enumNames,
                                                          withProtocolNames: parser.protocolNames,
                                                          withProtocols: parser.protocols,
                                                          withPrimitiveProxyNames: parser.primitiveProxyNames,
                                                          embedParseSDKSupport: parseSupport) }
        } else {
            return nil
        }

        var classString = parser.headerStringFor(filename: className, fileExtension: "swift", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "import Foundation\n"
        if parseSupport {
            if !onlyPrimitives(in: restprops, parentChain: parentChain) {
                classString += "import Parse\n"
            }
        }
        classString += "\npublic struct \(className): "
        if parentProtocol != nil {
            classString += parentProtocol!.name + ", "
            if let pprotName = parentProtocol?.parentName,
                !pprotName.isEmpty {
                classString += pprotName + ", "
                var pp = parser.protocols?.first(where: { $0.name == pprotName })
                while pp != nil,
                    let ppprotName = pp?.parentName,
                    !ppprotName.isEmpty {
                        classString += ppprotName + ", "
                        pp = parser.protocols?.first(where: { $0.name == ppprotName })
                }
            }
        }
        classString += "JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {\n"

        var ind = indent

        classString += "\n\(ind)// DTO properties:\n"

        var hasProps = false
        for ppRestProps in parentChain {
            for thisProp in ppRestProps.restProperties {
                classString += "\(thisProp.declarationString)\n"
                hasProps = true
            }
        }
        if hasProps { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.declarationString)\n"
            }
        }

        // ----------------------- init(params...)

        classString += "\n\(ind)// Default initializer:\n"
        classString += "\(ind)public init("

        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\(property.defaultInitializeParameter), "
            }
        }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeParameter), "
            }
        }
        classString = classString.substring(to: classString.index(classString.endIndex, offsetBy: -2))
        classString += ") {\n"

        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\(property.defaultInitializeString)\n"
            }
        }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeString)\n"
            }
        }
        classString += "\(ind)}\n"

        // ----------------------- init?(jsonData: JSOBJ?)

        classString += "\n\(ind)// Object creation using JSON dictionary representation from NSJSONSerializer:\n"
        classString += "\(ind)public init?(jsonData: JSOBJ?) {\n"
        classString += "\(ind)\(ind)guard let jsonData = jsonData else { return nil }\n"

        hasProps = false
        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\(property.initializeString)\n"
                hasProps = true
            }
        }
        if hasProps { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.initializeString)\n"
            }
        }
        classString += "\n\(ind)\(ind)#if DEBUG\n\(ind)\(ind)\(ind)DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: \"\(className)\")\n\(ind)\(ind)#endif\n"
        classString += "\(ind)}\n"

        // ----------------------- allExpectedKeys() // Helper function

        var hasProperties = false
        classString += "\n\(ind)// all expected keys (for diagnostics in debug mode):\n"
        classString += "\(ind)public var allExpectedKeys: Set<String> {\n\(ind)\(ind)return Set(["
        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\"\(property.jsonProperty)\", "
                hasProperties = true
            }
        }
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\"\(property.jsonProperty)\", "
                hasProperties = true
            }
        }
        if hasProperties {
            classString.remove(at: classString.characters.index(classString.endIndex, offsetBy: -1))
            classString.remove(at: classString.characters.index(classString.endIndex, offsetBy: -1))
        }
        classString += "])\n"

        classString += "\(ind)}\n"

        // ----------------------- jsobjRepresentation

        classString += "\n\(ind)// dictionary representation (for use with NSJSONSerializer or as parameters for URL request):\n"
        classString += "\(ind)public var jsobjRepresentation: JSOBJ {\n"
        ind += indent
        classString += "\(ind)var jsonData = JSOBJ()\n"

        hasProps = false
        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\(property.exportString)\n"
                hasProps = true
            }
        }
        if hasProps { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.exportString)\n"
            }
        }
        classString += "\(ind)return jsonData\n"
        ind = ind.substring(start: 0, end: (indent.characters.count * -1))
        classString += "\(ind)}\n"

        // ----------------------- description + jsonString()

        classString += "\n\(ind)// printable protocol conformance:\n"
        classString += "\(ind)public var description: String { return \"\\(jsonString())\" }\n"

        classString += "\n\(ind)// pretty print JSON string representation:\n"
        classString += "\(ind)public func jsonString(paddingPrefix prefix: String = \"\", printNulls: Bool = false) -> String {\n"
        ind += indent
        classString += "\(ind)var returnString = \"{\\n\"\n"
        classString += "\n"

        hasProperties = false
        hasProps = false
        for ppRestProps in parentChain {
            for property in ppRestProps.restProperties {
                classString += "\(property.jsonString)\n"
                hasProperties = true
                hasProps = false
            }
        }
        if hasProps { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.jsonString)\n"
                hasProperties = true
            }
        }

        if hasProperties {
            classString = parser.removeCommaAtPos(-5, sourceString: classString)
        }

        classString = classString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        classString += "\n"
        classString += "\(ind)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \"\\n\"))\n"
        classString += "\(ind)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \",\"))\n"
        classString += "\(ind)returnString += \"\\n\\(prefix)}\"\n"
        classString += "\(ind)return returnString\n"
        ind = ind.substring(start: 0, end: (indent.characters.count * -1))
        classString += "\(ind)}\n"

        classString += "}"

        return classString
    }

    private final func parseFileReferenceBody(indent: String) -> String {
        return "\(indent)name = jsonData.name\n\(indent)url = jsonData.url\n"
    }

    override func generateParseExtensionFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

//        return generateParseExtensionFinallyWithFetchIfNeeded(properties, withName: className, parentProtocol: parentProtocol, storedProperties: storedProperties)

        let ind = indent

        let restprops: [RESTProperty]
        if let storedProperties = storedProperties {
            restprops = storedProperties
        } else if let properties = properties {
            restprops = properties.flatMap { RESTProperty(
                xmlElement: $0,
                enumParentName: nil,
                withEnumNames: parser.enumNames,
                withProtocolNames: parser.protocolNames,
                withProtocols: parser.protocols,
                withPrimitiveProxyNames: parser.primitiveProxyNames,
                embedParseSDKSupport: true)
            }
        } else {
            return nil
        }

        var classString = parser.headerStringFor(filename: "\(className)+Extension", fileExtension: "swift", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "import Foundation\nimport Parse\n\npublic extension \(className) {"

        if className == "ParseFileReference" {
            classString += "\n\(ind)public init?(parseData: PFFile?) {"
        } else {
            classString += "\n\(ind)public init?(parseData: PFObject?) {"
        }
        classString += "\n\(ind)\(ind)guard let jsonData = parseData else { return nil }"
        classString += "\n"

        let fileprop = (restprops.filter { $0.jsonProperty == "__type" }).first

        if (className == "ParseFileReference" || fileprop?.value == "File") {
            classString += parseFileReferenceBody(indent: "\(ind)\(ind)")
        } else {

            var parentChain = [ProtocolDeclaration]()
            if var pp = parentProtocol {
                parentChain.append(pp)
                var pparentName = parser.protocols?.first(where: { $0.name == pp.parentName })?.name
                while pparentName != nil && pparentName?.isEmpty == false {
                    pp = (parser.protocols?.first(where: { $0.name == pparentName! }))!
                    parentChain.append(pp)
                    pparentName = pp.parentName
                }
            }

            var parentPropertyNames = Set<String>()
            for thisPP in parentChain {
                for thisRProp in thisPP.restProperties {
                    parentPropertyNames.insert(thisRProp.name)
                }
            }

            var hasProps = false
            for ppRestProps in parentChain {
                for thisProp in ppRestProps.restProperties {
                    classString += "\(thisProp.parseInitializeString)\n"
                    hasProps = true
                }
            }
            if hasProps { classString += "\n" }

            for property in restprops {
                if !parentPropertyNames.contains(property.name) {
                    classString += "\(property.parseInitializeString)\n"
                }
            }
        }

        classString += "\(ind)}\n"
        classString += "}\n"
        return classString
    }

    private final func generateParseExtensionFinallyWithFetchIfNeeded(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

        let ind = indent

        var classString = parser.headerStringFor(filename: "\(className)+Extension", fileExtension: "swift", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "import Foundation\nimport Parse\n\npublic extension \(className) {"

        if className == "ParseFileReference" {
            classString += "\n\(ind)public init?(parseData: PFFile?) {"
        } else {
            classString += "\n\(ind)public init?(parseData: PFObject?) {"
        }
        classString += "\n\(ind)\(ind)guard let jsonData = parseData else { return nil }"
        classString += "\n\(ind)\(ind)do {"
        classString += "\n\(ind)\(ind)\(ind)try jsonData.fetchIfNeeded()\n"

        if className == "ParseFileReference" {
            classString += parseFileReferenceBody(indent: "\(ind)\(ind)\(ind)")
        } else {

            var parentChain = [ProtocolDeclaration]()
            if var pp = parentProtocol {
                parentChain.append(pp)
                var pparentName = parser.protocols?.first(where: { $0.name == pp.parentName })?.name
                while pparentName != nil && pparentName?.isEmpty == false {
                    pp = (parser.protocols?.first(where: { $0.name == pparentName! }))!
                    parentChain.append(pp)
                    pparentName = pp.parentName
                }
            }

            var parentPropertyNames = Set<String>()
            for thisPP in parentChain {
                for thisRProp in thisPP.restProperties {
                    parentPropertyNames.insert(thisRProp.name)
                }
            }

            var hasProps = false
            for ppRestProps in parentChain {
                for thisProp in ppRestProps.restProperties {
                    classString += "\(ind)\(thisProp.parseInitializeString)\n"
                    hasProps = true
                }
            }
            if hasProps { classString += "\n" }

            let restprops: [RESTProperty]
            if let storedProperties = storedProperties {
                restprops = storedProperties
            } else if let properties = properties {
                restprops = properties.flatMap { RESTProperty(xmlElement: $0,
                                                              enumParentName: nil,
                                                              withEnumNames: parser.enumNames,
                                                              withProtocolNames: parser.protocolNames,
                                                              withProtocols: parser.protocols,
                                                              withPrimitiveProxyNames: parser.primitiveProxyNames,
                                                              embedParseSDKSupport: true) }
            } else {
                return nil
            }

            for property in restprops {
                if !parentPropertyNames.contains(property.name) {
                    classString += "\(ind)\(property.parseInitializeString)\n"
                }
            }
        }

        classString += "\(ind)\(ind)} catch {\n"
        classString += "\(ind)\(ind)\(ind)return nil\n"
        classString += "\(ind)\(ind)}\n"

        classString += "\(ind)}\n"
        classString += "}\n"
        return classString
    }

    override func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {

        var classString = parser.headerStringFor(filename: className, fileExtension: "swift", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "import Foundation\n\npublic enum \(className): \(enumParentName) {\n"

        var hasRelations = false
        for property in restprops {
            if property.isPrimitiveType {
                classString += indent + "\(property.declarationString)\n"
            }
            else {
                hasRelations = true
            }
        }
        classString += "\n"
        classString += indent + "public static func byString(_ typeAsString: String?) -> \(className)? {\n"
        classString += indent + indent + "switch (typeAsString ?? \"\").uppercased() {\n"
        for property in restprops where property.isPrimitiveType {
            classString += "\(property.upperCasedInitializer)\n"
        }
        classString += indent + indent + "default:\n"
        classString += indent + indent + indent + "#if DEBUG\n"
        classString += indent + indent + indent + indent + "DTODiagnostics.unknownEnumCase(typeAsString, inEnum: \"\(className)\")\n"
        classString += indent + indent + indent + "#endif\n"
        classString += indent + indent + indent + "return nil\n"
        classString += indent + indent + "}\n"
        classString += indent + "}\n"
        classString += "\n"

        if hasRelations {
            var commonProtocol: String?
            for property in restprops where !property.isPrimitiveType {
                let protocolName = parser.protocolNameFor(property.primitiveType)
                if protocolName.isEmpty { continue }
                if commonProtocol == nil {
                    commonProtocol = protocolName
                }
                else {
                    if protocolName != commonProtocol {
                        fatalError("Relations in enum \"\(className)\" have different protocol dependencies!")
                    }
                }
            }

            if commonProtocol != nil {
                classString += "\n"

                parser.enumsWithRelations.insert(className)

                classString += indent + "func conditionalInstance(withJSON jsonData: JSOBJ) -> \(commonProtocol!)? {\n"
                classString += indent + "\(indent)switch self {\n"

                for property in restprops where !property.isPrimitiveType {
                    classString += indent + "\(indent)case .\(String(property.name.characters.dropFirst())):\n"
                    classString += indent + "\(indent)\(indent)return \(property.primitiveType)(jsonData: jsonData)\n"
                }
                classString += indent + "\(indent)}\n"
                classString += indent + "}\n"
            }
        }

        classString += "}"
        return classString
    }

    override func generateProtocolFileForProtocol(_ protocolName: String) -> String? {

        guard let protocolData = (parser.protocols?.filter { $0.name == protocolName })?.first else {
            fatalError("generateProtocolFileForProtocol() was called with an argument where there is no data for in protocols array!")
        }
        var classString = parser.headerStringFor(filename: protocolName, fileExtension: "swift", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "import Foundation\n\npublic protocol \(protocolName): DictionaryConvertible {\n"
        classString += protocolData.declarationString
        classString += "}"

        guard let consumer = protocolData.consumers.first else {
            return classString
        }
        if let prop = protocolData.restProperties.first(where: { $0.isEnumProperty == true }) {
            if parser.enumsWithRelations.contains(prop.primitiveType) {

                classString += "\n\nextension \(protocolName) {\n"
                classString += "\(indent)static func createWith(jsonData json: JSOBJ) -> \(protocolName)? {\n"
                classString += "\(indent)\(indent)if let enumValue = json[\"\(prop.jsonProperty)\"] as? String,\n\(indent)\(indent)\(indent)let enumProp = \(prop.primitiveType)(rawValue: enumValue) {\n"
                classString += "\(indent)\(indent)\(indent)return enumProp.conditionalInstance(withJSON: json)\n"
                classString += "\(indent)\(indent)}\n"
                classString += "\(indent)\(indent)else {\n"
                classString += "\(indent)\(indent)\(indent)return nil\n"
                classString += "\(indent)\(indent)}\n"
                classString += "\(indent)}\n"
                classString += "}"

                return classString
            }
        }
        classString += "\n\nextension \(protocolName) {\n"
        classString += "\(indent)static func createWith(jsonData json: JSOBJ) -> \(protocolName)? {\n"
        classString += "\(indent)\(indent)return \(consumer)(jsonData: json)\n"
        classString += "\(indent)}\n"
        classString += "}"

        return classString
    }
}
