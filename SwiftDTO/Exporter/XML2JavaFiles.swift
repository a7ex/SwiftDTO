//
//  XML2JavaFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2JavaFiles: BaseExporter, DTOFileGenerator {

    static let indent = "    "

    final func generateFiles(inFolder folderPath: String? = nil) {
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = (folderPath ?? workingDirectory)!

        generateEnums(inDirectory: pwd)
        generateClassFiles(inDirectory: pwd)
        generateClassFilesFromCoreData(inDirectory: pwd)
        generateProtocolFiles(inDirectory: pwd)
        createAndExportParentRelationships(inDirectory: pwd)
    }

    override func fileExtensionForCurrentOutputType() -> String {
        return "java"
    }

    override func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

        var classString = parser.headerStringFor(filename: className, fileExtension: fileExtensionForCurrentOutputType(), fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "\npackage data.api.model.GeneratedFiles;\n\n"
        classString += "import com.google.gson.annotations.Expose;\n"
        classString += "import com.google.gson.annotations.SerializedName;\n"
        classString += "import java.util.HashMap;\n"
        classString += "import java.util.Map;\n"

        classString += "\npublic class \(className)"
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

        classString += "\n\(indent)public \(className)("

        var allRestProps = [RESTProperty]()
        var parent = parentProtocol
        while parent != nil {
            if let pprops = parent?.restProperties {
                allRestProps = pprops + allRestProps
            }
            guard let protoName = parent?.parentName,
                let protocolData = (parser.protocols?.filter { $0.name == protoName })?.first else {
                    break
            }
            parent = protocolData
        }

        var firstTime = true
        for thisProp in allRestProps {
            if !firstTime { classString += ", " }
            firstTime = false
            if thisProp.isArray {
classString += "List<\(RESTProperty.mapTypeToJava(swiftType: thisProp.primitiveType))> \(thisProp.name)"
            } else {
            classString += "\(RESTProperty.mapTypeToJava(swiftType: thisProp.type)) \(thisProp.name)"
            }
        }
        for thisProp in restprops {
            if !firstTime { classString += ", " }
            firstTime = false
            if thisProp.isArray {
                classString += "List<\(RESTProperty.mapTypeToJava(swiftType: thisProp.primitiveType))> \(thisProp.name)"
            } else {
            classString += "\(RESTProperty.mapTypeToJava(swiftType: thisProp.type)) \(thisProp.name)"
            }
        }
        classString += ") {"

        if parentProtocol != nil {
            classString += "\n\(indent)\(indent)super("
            firstTime = true
            for thisProp in allRestProps {
                if !firstTime { classString += ", " }
                firstTime = false
                classString += "\(thisProp.name)"
            }
            classString += ");"
        }

        classString += "\n"

        firstTime = true
        for thisProp in restprops {
            if !firstTime { classString += "\n" }
            firstTime = false
            classString += "\(indent)\(indent)this.\(thisProp.name) = \(thisProp.name);"
        }
        classString += "\n\(indent)}"
        classString += "\n"
        if parentProtocol != nil {
        classString += "\n\(indent)@Override"
        }
        classString += "\n\(indent)public Map<String, Object> asParameterMap() {"
        if parentProtocol != nil {
            classString += "\n\(indent)\(indent)Map<String, Object> map = super.asParameterMap();"
        } else {
            classString += "\n\(indent)\(indent)Map<String, Object> map = new HashMap<>();"
        }
        for thisProp in restprops {
            classString += "\n\(indent)\(indent)map.put(\"\(thisProp.name)\", \(thisProp.name));"
        }
        classString += "\n\(indent)\(indent)return map;"
        classString += "\n\(indent)}\n"

        classString += "}"
        return classString
    }

    override func generateProtocolFileForProtocol(_ protocolName: String) -> String? {

        guard let protocolData = (parser.protocols?.filter { $0.name == protocolName })?.first else {
            fatalError("generateProtocolFileForProtocol() was called with an argument where there is no data for in protocols array!")
        }

        let parentProtocol = (parser.protocols?.filter { $0.name == protocolData.parentName })?.first
        return generateClassFinally(nil, withName: protocolName, parentProtocol: parentProtocol, storedProperties: protocolData.restProperties)
    }

    override func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {

        var classString = parser.headerStringFor(filename: className, fileExtension: fileExtensionForCurrentOutputType(), fromWSDL: parser.coreDataEntities.isEmpty)

        classString += "\npackage data.api.model.GeneratedFiles;\n\n"
        classString += "public enum \(className) {\n"

        //        var hasRelations = false
        var first = true
        for property in restprops {
            if !first { classString += ",\n" }
            first = false
            classString += "\(property.javaDeclarationString)"
        }
        classString += ";"

        classString += "\n\(indent)public final String value;"
        classString += "\n\(indent)\(className)(String value){\n"
        classString += "\n\(indent)\(indent)this.value = value;\n\(indent)}"

        classString += "\n"
        classString += "}"
        return classString
    }
}
