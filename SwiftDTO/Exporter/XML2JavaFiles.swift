//
//  XML2JavaFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2JavaFiles: BaseExporter, DTOFileGenerator {

    final func generateFiles(inFolder folderPath: String? = nil) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        generateEnums(inDirectory: pwd)
        generateClassFiles(inDirectory: pwd)
        generateClassFilesFromCoreData(inDirectory: pwd)

        createAndExportParentRelationships(inDirectory: pwd)

    }

    override func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

        var classString = parser.headerStringFor(filename: className, fileExtension: "java", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "include Some.Java.Classes\n\npublic class \(className)"
        if parentProtocol != nil {
            classString += " extends \(parentProtocol!.name)"
        }
        classString += " {\n"

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
            classString += "\(property.javaDeclarationString)\n"
        }

        classString += "}"
        return classString
    }

    override func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {

        var classString = parser.headerStringFor(filename: className, fileExtension: "java", fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "include Some.Java.Classes\n\npublic enum \(className): \(enumParentName) {\n"

        var hasRelations = false
        for property in restprops {
            classString += indent + "\(property.javaDeclarationString)\n"
        }

        classString += "}"
        return classString
    }
}
