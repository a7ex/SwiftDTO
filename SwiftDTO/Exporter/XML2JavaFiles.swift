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

        classString += "\npackage data.api.model;\n\n"
        classString += "import com.google.gson.annotations.Expose;\n"
        classString += "import com.google.gson.annotations.SerializedName;\n"
        classString += "public class \(className)"
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

        classString += "\npackage data.api.model;\n\n"
        classString += "public enum \(className) {\n"

//        var hasRelations = false
        var first = true
        for property in restprops {
            if !first { classString += ",\n" }
            first = false
            classString += "\(property.javaDeclarationString)"
        }

        classString += "\n\tpublic final String value;"
        classString += "\n\t\(className)(String value){\n"
        classString += "\n\t\tthis.value = value;\n\t}"

        classString += "\n"
        classString += "}"
        return classString
    }
}
