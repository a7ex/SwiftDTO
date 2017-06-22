//
//  BaseExporter.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

protocol DTOFileGenerator {
    func generateFiles(inFolder folderPath: String?)
}

class BaseExporter {
    let parser: XMLModelParser
    let indent = "    "

    init(parser: XMLModelParser) {
        self.parser = parser
    }

    func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {
        return "Override 'generateProtocolFileForProtocol()' in your concrete subclass of BaseExporter!"
    }

    func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {
        return "Override 'generateProtocolFileForProtocol()' in your concrete subclass of BaseExporter!"
    }

    func generateProtocolFileForProtocol(_ protocolName: String) -> String? {
        return "Override 'generateProtocolFileForProtocol()' in your concrete subclass of BaseExporter!"
    }

    func fileExtensionForCurrentOutputType() -> String {
        // Override in concrete subclass. This is the default: -> swift
        return "swift"
    }

    final func generateEnums(inDirectory outputDir: String) {
        for enumInfo in parser.enums {
            if let content = generateEnumFileForEntityFinally(enumInfo.restprops,
                                                              withName: enumInfo.name,
                                                              enumParentName: enumInfo.typeName) {
                writeContent(content, toFileAtPath: pathForClassName(enumInfo.name, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }
    }

    final func generateProtocolFiles(inDirectory outputDir: String) {
        for complexType in parser.complexTypesInfos where parser.protocolNames.contains(complexType.name) {
            // write protocol files to disk:
            if let content = generateProtocolFileForProtocol(complexType.name) {
                writeContent(content, toFileAtPath: pathForClassName(complexType.name, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }
    }

    final func generateClassFiles(inDirectory outputDir: String) {
        for complexType in parser.complexTypesInfos where !parser.protocolNames.contains(complexType.name) {
            // write DTO structs to disk:
            let protoDeclaration = parser.protocols?.first(where: { $0.name == complexType.parentName })
            if let content = generateClassFinally(nil,
                                                  withName: complexType.name,
                                                  parentProtocol: protoDeclaration,
                                                  storedProperties: complexType.restprops) {
                writeContent(content, toFileAtPath: pathForClassName(complexType.name, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }
    }

    final func generateClassFilesFromCoreData(inDirectory outputDir: String) {
        let entities = parser.coreDataEntities

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateEnumFileFor(entity: unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateProtocolFileForEntity(unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateClassFileForEntity(unwrappedEntity, withName: className) {
                writeContent(content, toFileAtPath: pathForClassName(className, inFolder: outputDir, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }
    }

    // MARK: - Helper Methods

    private final func generateProtocolFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard (entity.children as? [XMLElement]) != nil else { return nil }

        if parser.protocolNames.contains(className) {
            return generateProtocolFileForProtocol(className)
        }
        return nil
    }

    private final func generateEnumFileFor(entity: XMLElement, withName className: String) -> String? {
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

    final func createAndExportParentRelationships(inDirectory folderPath: String) {
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

            let fileurl = URL(fileURLWithPath: folderPath)
            let newUrl = fileurl.appendingPathComponent("DTOParentInfo.json")
            writeContent(parRelString, toFileAtPath: newUrl.path)
        }
    }

    final func copyStaticSwiftFiles(named filenames: [String], inDirectory folderPath: String) {
        for filename in filenames {
            if let swfilePath = Bundle.main.path(forResource: filename, ofType: fileExtensionForCurrentOutputType()),
                let classContents = try? String(contentsOfFile: swfilePath, encoding: String.Encoding.utf8) {
                writeContent(classContents, toFileAtPath: pathForClassName(filename, inFolder: folderPath, fileExtension: fileExtensionForCurrentOutputType()))
            }
        }
    }
}
