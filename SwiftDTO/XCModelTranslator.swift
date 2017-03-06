//
//  XCModelTranslator.swift
//  SwiftDTO
//
//  Created by alex da franca on 19/06/16.
//  Copyright © 2016 farbflash. All rights reserved.
//

import Foundation

class XCModelTranslator {
    let model: XMLNode
    var enumNames: Set<String>?
    var protocolNames = Set<String>()
    var primitiveProxyNames = Set<String>()
    var protocols: [ProtocolDeclaration]?
    var enumsWithRelations = Set<String>()
    
    let indent = "    "
    
    init?(xmlData: XMLDocument) {
        guard let children = xmlData.children , children.count > 0,
            let mo = children.filter({ $0.name == "model" }).first else { return nil }
        self.model = mo
    }
    
    final func generateFiles(inFolder folderPath: String? = nil) {
        guard let children = model.children else { return }
        let entities = children.filter() { $0.name == "entity" }
        
        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        
        let pwd = folderPath ?? workingDirectory
        
        var primitiveProxies = Set<String>()
        for thisEntity in entities {
            guard let children2 = thisEntity.children as? [XMLElement],
                let userInfo = children2.filter({ $0.name == "userInfo" }).first,
                let theseInfos = userInfo.children as? [XMLElement] else {
                    continue
            }
            if let elementInfo = theseInfos.filter({ $0.attribute(forName: "key")?.stringValue == "isPrimitiveProxy" }).first {
                if elementInfo.attribute(forName: "value")?.stringValue == "1" {
                    if let entityName = (thisEntity as? XMLElement)?.attribute(forName: "name")?.stringValue {
                        primitiveProxies.insert(entityName)
                    }
                }
            }
        }
        primitiveProxyNames = primitiveProxies
        
        var enums = Set<String>()
        for thisEntity in entities {
            guard let children2 = thisEntity.children as? [XMLElement],
                let userInfo = children2.filter({ $0.name == "userInfo" }).first,
                let isEnumInfos = userInfo.children as? [XMLElement] else {
                    continue
            }
            if let enumInfo = isEnumInfos.filter({ $0.attribute(forName: "key")?.stringValue == "isEnum" }).first {
                if enumInfo.attribute(forName: "value")?.stringValue == "1" {
                    if let entityName = (thisEntity as? XMLElement)?.attribute(forName: "name")?.stringValue {
                        enums.insert(entityName)
                    }
                }
            }
        }
        enumNames = enums
        
        
        for thisEntity in entities {
            guard let isAbstractNode = (thisEntity as? XMLElement)?.attribute(forName: "isAbstract"),
                isAbstractNode.stringValue == "YES" else { continue }
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            protocolNames.insert(className)
        }
        
        protocols = [ProtocolDeclaration]()
        for thisEntity in entities {
            guard let isAbstractNode = (thisEntity as? XMLElement)?.attribute(forName: "isAbstract"),
                isAbstractNode.stringValue == "YES" else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: thisEntity as! XMLElement,
                                                      isEnum: false,
                                                      withEnumNames: enums,
                                                      withProtocolNames: protocolNames,
                                                      withProtocols: nil,
                                                      withPrimitiveProxyNames: primitiveProxyNames) {
                protocols?.append(thisProtocol)
            }
        }
        
        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            if let protocolName = (thisEntity as! XMLElement).attribute(forName: "parentEntity")?.stringValue {
                let parentProtocol = (protocols?.filter { $0.name == protocolName })?.first
                parentProtocol?.addConsumer(structName: className)
            }
        }
        
        // now do the first step again in order to have the information of all other protocols
        var newProts = [ProtocolDeclaration]()
        for thisEntity in entities {
            guard let isAbstractNode = (thisEntity as? XMLElement)?.attribute(forName: "isAbstract"),
                isAbstractNode.stringValue == "YES" else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: thisEntity as! XMLElement,
                                                      isEnum: false,
                                                      withEnumNames: enums,
                                                      withProtocolNames: protocolNames,
                                                      withProtocols: protocols,
                                                      withPrimitiveProxyNames: primitiveProxyNames) {
                newProts.append(thisProtocol)
            }
        }
        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            if let protocolName = (thisEntity as! XMLElement).attribute(forName: "parentEntity")?.stringValue {
                let parentProtocol = (newProts.filter { $0.name == protocolName }).first
                parentProtocol?.addConsumer(structName: className)
            }
        }
        protocols = newProts
        
        
        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            if let content = generateEnumFileFor(entity: thisEntity as! XMLElement, withName: className) {
                if let fpath = pathForClassName(className, inFolder: pwd) {
                    do {
                        try content.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
                        writeToStdOut("Successfully written file to: \(fpath)\n")
                    }
                    catch let error as NSError {
                        writeToStdError("error: \(error.localizedDescription)")
                    }
                }
                else {
                    writeToStdOut(content)
                }
            }
        }
        
        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            if let content = generateProtocolFileForEntity(thisEntity as! XMLElement, withName: className) {
                if let fpath = pathForClassName(className, inFolder: pwd) {
                    do {
                        try content.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
                        writeToStdOut("Successfully written file to: \(fpath)\n")
                    }
                    catch let error as NSError {
                        writeToStdError("error: \(error.localizedDescription)")
                    }
                }
                else {
                    writeToStdOut(content)
                }
            }
        }
        
        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue else { continue }
            if let content = generateClassFileForEntity(thisEntity as! XMLElement, withName: className) {
                if let fpath = pathForClassName(className, inFolder: pwd) {
                    do {
                        try content.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
                        writeToStdOut("Successfully written file to: \(fpath)\n")
                    }
                    catch let error as NSError {
                        writeToStdError("error: \(error.localizedDescription)")
                    }
                }
                else {
                    writeToStdOut(content)
                }
            }
        }
        
        let helperClassName = "DTO_Globals"
        if let swfilePath = Bundle.main.path(forResource: helperClassName, ofType: "swift"),
            let helperClass = try? String(contentsOfFile: swfilePath, encoding: String.Encoding.utf8) {
            if let fpath = pathForClassName(helperClassName, inFolder: pwd) {
                do {
                    try helperClass.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
                    writeToStdOut("Successfully written file to: \(fpath)\n")
                }
                catch let error as NSError {
                    writeToStdError("error: \(error.localizedDescription)")
                }
            }
            else {
                writeToStdOut(helperClass)
            }
        }
    }
    
    fileprivate final func pathForClassName(_ className: String, inFolder target: String?) -> String? {
        guard let target = target else { return nil }
        let fileurl = URL(fileURLWithPath: target)
        let newUrl = fileurl.appendingPathComponent(className).appendingPathExtension("swift")
        return newUrl.path
    }
    
    
    fileprivate final func generateProtocolFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard (entity.children as? [XMLElement]) != nil else { return nil }
        
        if protocolNames.contains(className) {
            return generateProtocolFileForProtocol(className)
        }
        return nil
    }
    
    fileprivate final func generateEnumFileFor(entity: XMLElement, withName className: String) -> String? {
        guard (entity.children as? [XMLElement]) != nil else { return nil }
        
        if let enums = enumNames,
            enums.contains(className) {
            return generateEnumFileForEntity(entity, withName: className)
        }
        return nil
    }
    
    fileprivate final func generateClassFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard let properties = entity.children as? [XMLElement] else { return nil }
        
        if let enums = enumNames,
            enums.contains(className) {
            return nil
        }
        
        if protocolNames.contains(className) {
            return nil
        }
        
        if let userInfo = properties.filter({ $0.name == RESTProperty.Constants.UserInfoKeyName }).first,
            let jsProps = userInfo.children as? [XMLElement] {
            
            if let isProxy = jsProps.filter({ $0.attribute(forName: "key")?.stringValue == "isPrimitiveProxy" }).first,
                (isProxy.attribute(forName: "value")?.stringValue ?? "") == "1" {
                return nil
            }
        }
        
        let parentProtocol: ProtocolDeclaration?
        if let protocolName = entity.attribute(forName: "parentEntity")?.stringValue {
            parentProtocol = (protocols?.filter { $0.name == protocolName })?.first
        }
        else {
            parentProtocol = nil
        }
        
        var classString = headerStringFor(filename: className)
        
        classString += "import Foundation\n\npublic struct \(className): \((parentProtocol == nil) ? "": parentProtocol!.name + ", ")JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {\n"
        
        var indent = "    "
        
        classString += "\n\(indent)// DTO properties:\n"
        
        let parentPropertyNames = Set(parentProtocol?.restProperties.flatMap { $0.name } ?? [String]())
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.declarationString)\n"
        }
        if parentProtocol != nil { classString += "\n" }
        
        let restprops = properties.flatMap() { RESTProperty(xmlElement: $0,
                                                            isEnum: false,
                                                            withEnumNames: enumNames ?? Set<String>(),
                                                            withProtocolNames: protocolNames,
                                                            withProtocols: protocols,
                                                            withPrimitiveProxyNames: primitiveProxyNames) }
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.declarationString)\n"
            }
        }
        
        classString += "\n\(indent)// Default initializer:\n"
        classString += "\(indent)public init("
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.defaultInitializeParameter), "
        }
        
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeParameter), "
            }
        }
        classString = classString.substring(to: classString.index(classString.endIndex, offsetBy: -2))
        classString += ") {\n"
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.defaultInitializeString)\n"
        }
        
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeString)\n"
            }
        }
        classString += "\(indent)}\n"
        
        
        classString += "\n\(indent)// Object creation using JSON dictionary representation from NSJSONSerializer:\n"
        classString += "\(indent)public init?(jsonData: JSOBJ?) {\n"
        classString += "\(indent)\(indent)guard let jsonData = jsonData else { return nil }\n"
        
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.initializeString)\n"
        }
        if parentProtocol != nil { classString += "\n" }
        
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.initializeString)\n"
            }
        }
        classString += "\n\(indent)\(indent)#if DEBUG\n\(indent)\(indent)\(indent)DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: \"\(className)\")\n\(indent)\(indent)#endif\n"
        classString += "\(indent)}\n"
        
        var hasProperties = false
        
        classString += "\n\(indent)// all expected keys (for diagnostics in debug mode):\n"
        classString += "\(indent)public var allExpectedKeys: Set<String> {\n\(indent)\(indent)return Set(["
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\"\(property.jsonProperty)\", "
            hasProperties = true
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

        classString += "\(indent)}\n"
        
        classString += "\n\(indent)// dictionary representation (for use with NSJSONSerializer or as parameters for URL request):\n"
        classString += "\(indent)public var jsobjRepresentation: JSOBJ {\n"
        indent = indent + indent
        classString += "\(indent)var jsonData = JSOBJ()\n"
        
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.exportString)\n"
        }
        if parentProtocol != nil { classString += "\n" }
        
        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.exportString)\n"
            }
        }
        classString += "\(indent)return jsonData\n"
        indent.remove(at: indent.characters.index(before: indent.endIndex))
        classString += "\(indent)}\n"
        
        classString += "\n\(indent)// printable protocol conformance:\n"
        classString += "\(indent)public var description: String { return \"\\(jsonString())\" }\n"
        
        classString += "\n\(indent)// pretty print JSON string representation:\n"
        classString += "\(indent)public func jsonString(paddingPrefix prefix: String = \"\", printNulls: Bool = false) -> String {\n"
        indent = indent + indent
        classString += "\(indent)var returnString = \"{\\n\"\n"
        classString += "\n"

        hasProperties = false
        for property in parentProtocol?.restProperties ?? [RESTProperty]() {
            classString += "\(property.jsonString)\n"
            hasProperties = true
        }
        if parentProtocol != nil { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.jsonString)\n"
                hasProperties = true
            }
        }

        if hasProperties {
            classString = removeCommaAtPos(-5, sourceString: classString)
        }
        
        classString = classString.trimmingCharacters(in: CharacterSet(charactersIn: ","))
        classString += "\n"
        classString += "\(indent)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \"\\n\"))\n"
        classString += "\(indent)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \",\"))\n"
        classString += "\(indent)returnString = returnString + \"\\n\\(prefix)}\"\n"
        classString += "\(indent)return returnString\n"
        indent.remove(at: indent.characters.index(before: indent.endIndex))
        classString += "\(indent)}\n"
        
        classString += "}"
        
        return classString
    }
    
    private final func removeCommaAtPos(_ pos: Int, sourceString: String) -> String {
        var sourceString = sourceString
        let startInd = sourceString.characters.index(sourceString.endIndex, offsetBy: pos)
        let endInd = sourceString.characters.index(sourceString.endIndex, offsetBy: pos)
        let rng = Range(uncheckedBounds: (lower: startInd, upper: endInd))
        //            let rng = Range(startInd...endInd)
        if sourceString.substring(with: rng) == "," {
            sourceString.remove(at: sourceString.characters.index(sourceString.endIndex, offsetBy: pos))
        }
        return sourceString
    }
    
    private final func generateEnumFileForEntity(_ entity: XMLElement, withName className: String) -> String? {
        guard let properties = entity.children as? [XMLElement] else { return nil }
        
        var classString = headerStringFor(filename: className)
        
        classString += "import Foundation\n\npublic enum \(className): String {\n"
        
        let restprops = properties.flatMap() { RESTProperty(xmlElement: $0,
                                                            isEnum: true,
                                                            withEnumNames: enumNames ?? Set<String>(),
                                                            withProtocolNames: protocolNames,
                                                            withProtocols: protocols,
                                                            withPrimitiveProxyNames: primitiveProxyNames) }
        
        let indent = "    "
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
        for property in restprops {
            if property.isPrimitiveType {
                classString += "\(property.upperCasedInitializer)\n"
            }
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
            for property in restprops {
                if !property.isPrimitiveType {
                    let protocolName = protocolNameFor(property.primitiveType)
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
            }
            
            if commonProtocol != nil {
                classString += "\n"
                
                enumsWithRelations.insert(className)
                
                classString += indent + "func conditionalInstance(withJSON jsonData: JSOBJ) -> \(commonProtocol!)? {\n"
                classString += indent + "\(indent)switch self {\n"
                
                for property in restprops {
                    if !property.isPrimitiveType {
                        classString += indent + "\(indent)case .\(String(property.name.characters.dropFirst())):\n"
                        classString += indent + "\(indent)\(indent)return \(property.primitiveType)(jsonData: jsonData)\n"
                    }
                }
                classString += indent + "\(indent)}\n"
                classString += indent + "}\n"
            }
        }
        
        classString += "}"
        return classString
    }
    
    private final func protocolNameFor(_ childName: String) -> String {
        for thisProtocol in protocols ?? [ProtocolDeclaration]() {
            if thisProtocol.consumers.contains(childName) {
                return thisProtocol.name
            }
        }
        return ""
    }
    
    private final func generateProtocolFileForProtocol(_ protocolName: String) -> String? {
        
        guard let protocolData = (protocols?.filter { $0.name == protocolName })?.first else {
            fatalError("generateProtocolFileForProtocol() was called with an argument where there is no data for in protocols array!")
        }
        var classString = headerStringFor(filename: protocolName)
        
        classString += "import Foundation\n\npublic protocol \(protocolName): DictionaryConvertible {\n"
        classString += protocolData.declarationString
        classString += "}"
        
        guard let consumer = protocolData.consumers.first else {
            return classString
        }
        if let prop = (protocolData.restProperties.filter { $0.isEnumProperty == true }).first {
            if enumsWithRelations.contains(prop.primitiveType) {
                
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
    
    private func headerStringFor(filename: String) -> String {
        return "//\n//  \(filename).swift\n"
        + "//  conradkiosk\n//\n"
        + "//  Automatically created by SwiftDTO.\n"
        + "//  \(copyRightString)\n\n"
        + "// DO NOT EDIT THIS FILE!\n"
        + "// This file was automatically generated from a xcmodel file (CoreData XML Scheme)\n"
        + "// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO\n"
        + "// to create the corresponding DTO source files automatically\n\n"
    }
    
}
