//
//  XML2SwiftFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2SwiftFiles {

    let parser: XMLModelParser

    init(parser: XMLModelParser) {
        self.parser = parser
    }

    let indent = "    "

    final func generateFiles(inFolder folderPath: String? = nil) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        generateEnums(inDirectory: pwd)
        generateProtocolFiles(inDirectory: pwd)
        generateClassFiles(inDirectory: pwd)
        generateClassFilesFromCoreData(inDirectory: pwd)

        struct ParentRel {
            let name: String
            let children: Set<String>
        }
        if parser.parentRelations.count > 0 {

            let keyset = Set<String>(parser.parentRelations.map { $0.parentClass })
            var parentRels = [ParentRel]()
            for key in keyset {
                let subcls = parser.parentRelations.filter { $0.parentClass == key && !(keyset.contains($0.subclass)) }
                parentRels.append(ParentRel(name: key, children: Set(subcls.map { $0.subclass })))
            }

            var parRelString = "{\n"
            for (idx, thisPR) in parentRels.enumerated() {
                if idx != 0 { parRelString += ",\n" }
                parRelString += "  \"\(thisPR.name)\": [\n"
                let sortedChildren = thisPR.children.sorted(by: { (left, right) -> Bool in
                    let leftCType = parser.complexTypesInfos.first(where: { $0.name == left })
                    let rightCType = parser.complexTypesInfos.first(where: { $0.name == right })
                    return (leftCType?.restprops.count ?? 0) < (rightCType?.restprops.count ?? 0)
                })
                for (ind, str) in sortedChildren.enumerated() {
                    if ind != 0 { parRelString += ",\n" }
                    parRelString += "    \"\(str)\""
                }
                parRelString += "\n  ]"
            }
            parRelString += "\n}"

            let fileurl = URL(fileURLWithPath: pwd)
            let newUrl = fileurl.appendingPathComponent("DTOParentInfo.json")
            writeContent(parRelString, toFileAtPath: newUrl.path)
        }

        let helperClassName = "DTO_Globals"
        if let swfilePath = Bundle.main.path(forResource: helperClassName, ofType: "swift"),
            let helperClass = try? String(contentsOfFile: swfilePath, encoding: String.Encoding.utf8) {
            writeContent(helperClass, toFileAtPath: pathForClassName(helperClassName, inFolder: pwd))
        }
    }

    private final func generateClassFilesFromCoreData(inDirectory outputDir: String) {
        let entities = parser.coreDataEntities

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateEnumFileFor(entity: unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir))
            }
        }

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateProtocolFileForEntity(unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir))
            }
        }

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateClassFileForEntity(unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir))
            }
        }
    }

    // MARK: - Helper Methods

    fileprivate final func generateProtocolFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard (entity.children as? [XMLElement]) != nil else { return nil }

        if parser.protocolNames.contains(className) {
            return generateProtocolFileForProtocol(className)
        }
        return nil
    }

    fileprivate final func generateEnumFileFor(entity: XMLElement, withName className: String) -> String? {
        guard (entity.children as? [XMLElement]) != nil else { return nil }

        if parser.enumNames.contains(className) {
            return generateEnumFileForEntity(entity, withName: className)
        }
        return nil
    }

    private final func generateEnumFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard let properties = entity.children as? [XMLElement] else { return nil }

        let restprops = properties.flatMap { RESTProperty(xmlElement: $0,
                                                          enumParentName: "String",
                                                          withEnumNames: parser.enumNames,
                                                          withProtocolNames: parser.protocolNames,
                                                          withProtocols: parser.protocols,
                                                          withPrimitiveProxyNames: parser.primitiveProxyNames) }

        return generateEnumFileForEntityFinally(restprops, withName: className, enumParentName: "String")
    }

    private final func generateProtocolFiles(inDirectory outputDir: String) {
        for complexType in parser.complexTypesInfos where parser.protocolNames.contains(complexType.name) {
            // write protocol files to disk:
            if let content = generateProtocolFileForProtocol(complexType.name) {
                writeContent(content, toFileAtPath: pathForClassName(complexType.name, inFolder: outputDir))
            }
        }
    }

    private final func generateClassFiles(inDirectory outputDir: String) {
        for complexType in parser.complexTypesInfos where !parser.protocolNames.contains(complexType.name) {
            // write DTO structs to disk:
            let protoDeclaration = parser.protocols?.first(where: { $0.name == complexType.parentName })
            if let content = generateClassFinally(nil,
                                                  withName: complexType.name,
                                                  parentProtocol: protoDeclaration,
                                                  storedProperties: complexType.restprops) {
                writeContent(content, toFileAtPath: pathForClassName(complexType.name, inFolder: outputDir))
            }
        }
    }

    private final func generateEnums(inDirectory outputDir: String) {
        for enumInfo in parser.enums {
            if let content = generateEnumFileForEntityFinally(enumInfo.restprops,
                                                              withName: enumInfo.name,
                                                              enumParentName: enumInfo.typeName) {
                writeContent(content, toFileAtPath: pathForClassName(enumInfo.name, inFolder: outputDir))
            }
        }
    }

    private final func generateClassFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard let properties = entity.children as? [XMLElement] else { return nil }

        guard !parser.enumNames.contains(className),
            !parser.protocolNames.contains(className),
            !entity.isPrimitiveProxy else { return nil }

        let parentProtocol: ProtocolDeclaration?
        if let protocolName = entity.attribute(forName: "parentEntity")?.stringValue {
            parentProtocol = (parser.protocols?.filter { $0.name == protocolName })?.first
        }
        else {
            parentProtocol = nil
        }

        return generateClassFinally(properties, withName: className, parentProtocol: parentProtocol, storedProperties: nil)
    }

    private final func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

        var classString = parser.headerStringFor(filename: className)

        classString += "import Foundation\n\npublic struct \(className): "
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
                classString += "\(thisProp.declarationString)\n"
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
                                                          withPrimitiveProxyNames: parser.primitiveProxyNames) }
        } else {
            return nil
        }

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

    private final func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {

        var classString = parser.headerStringFor(filename: className)

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

    private final func generateProtocolFileForProtocol(_ protocolName: String) -> String? {

        guard let protocolData = (parser.protocols?.filter { $0.name == protocolName })?.first else {
            fatalError("generateProtocolFileForProtocol() was called with an argument where there is no data for in protocols array!")
        }
        var classString = parser.headerStringFor(filename: protocolName)

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
