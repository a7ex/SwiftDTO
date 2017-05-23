//
//  XCModelTranslator.swift
//  SwiftDTO
//
//  Created by alex da franca on 19/06/16.
//  Copyright © 2016 farbflash. All rights reserved.
//

import Foundation

enum XmlType {
    case coreData, wsdl
}

func createClassNameFromType(_ nsType: String?) -> String? {
    guard let nsType = nsType,
        !nsType.isEmpty else { return nil }
    guard let type = nsType.components(separatedBy: ":").last else { return nil }
    let capType = type.capitalizedFirst
    switch capType {
    case "Error": return "DTOError"
    default: return capType
    }
}

struct ParentRelation {
    let subclass: String
    let parentClass: String
}

class XCModelTranslator {
    let model: XMLNode
    let xmlType: XmlType
    var enumNames: Set<String>?
    var protocolNames = Set<String>()
    var primitiveProxyNames = Set<String>()
    var protocols: [ProtocolDeclaration]?
    var enumsWithRelations = Set<String>()

    let indent = "    "

    init?(xmlData: XMLDocument) {
        if let children = xmlData.children, !children.isEmpty,
            let mo = children.first(where: { $0.name == "model" }) {
            self.model = mo
            xmlType = .coreData
        } else if let children = xmlData.children, !children.isEmpty,
            let mo = children.first(where: { $0.name == "xs:schema" }) {
            self.model = mo
            xmlType = .wsdl
        } else {
            return nil
        }
    }

    func addXMLData(xmlData: XMLDocument) {
        guard let children = xmlData.children,
            !children.isEmpty else { return }
        if xmlType == .coreData,
            children.first(where: { $0.name == "model" }) != nil {
            for thisModel in children {
                thisModel.detach()
                (model as? XMLElement)?.addChild(thisModel)
            }

        } else if xmlType == .wsdl,
            children.first(where: { $0.name == "xs:schema" }) != nil {
            for thisModel in children {
                thisModel.detach()
                (model as? XMLElement)?.addChild(thisModel)
            }
        }
    }

    struct ComplexTypesInfo {
        let name: String
        let parentName: String
        let restprops: [RESTProperty]
        let isProtocol: Bool
    }

    final func generateFiles(inFolder folderPath: String? = nil) {
        guard let children = model.children else { return }

        let info = ProcessInfo.processInfo
        let workingDirectory = info.environment["PWD"]
        let pwd = folderPath ?? workingDirectory

        let entities = children.filter { $0.name == "entity" }
        let complexTypes = children.filter { $0.name == "xs:complexType" }
        let simpleTypes = children.filter { $0.name == "xs:simpleType" }

        var enums = Set<String>()

        for simpType in simpleTypes {
            guard let enuName = createClassNameFromType((simpType as? XMLElement)?.attribute(forName: "name")?.stringValue) else { continue }
            let enumerations: [XMLElement]?
            let enumParentName: String
            if let enumParent = simpType.children?.first(where: { $0.name == "xs:restriction" }) as? XMLElement { enumParentName = createClassNameFromType(enumParent.attribute(forName: "base")?.stringValue) ?? ""
                enumerations = enumParent.children as? [XMLElement]
            } else {
                enumParentName = ""
                enumerations = simpType.children as? [XMLElement]
            }

            var eProps = [RESTProperty]()
            if let enumerations = enumerations {
                for enumVal in (enumerations.filter { $0.name == "xs:enumeration" }) {
                    if let element = RESTProperty(wsdlElement: enumVal,
                                                  enumParentName: enumParentName,
                                                  withEnumNames: enums,
                                                  overrideInitializers: [ParentRelation]()) {
                        eProps.append(element)
                    }
                }
            }

            if eProps.count > 0 {
                enums.insert(enuName)
                if let content = generateEnumFileForEntityFinally(eProps, withName: enuName, enumParentName: enumParentName) {
                    if let fpath = pathForClassName(enuName, inFolder: pwd) {
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
        }

        var complexTypesInfos = [ComplexTypesInfo]()
        var parentRelations = [ParentRelation]()
        for compType in complexTypes {
            guard createClassNameFromType((compType as? XMLElement)?.attribute(forName: "name")?.stringValue) != nil else { continue }

            if compType.children?[0].name == "xs:complexContent",
                compType.children?[0].children?[0].name == "xs:extension",
                let baseClassName = createClassNameFromType((compType.children?[0].children?[0] as? XMLElement)?.attribute(forName: "base")?.stringValue) {
                protocolNames.insert(baseClassName)
                if let clName = createClassNameFromType((compType as? XMLElement)?.attribute(forName: "name")?.stringValue) {
                    parentRelations.append(ParentRelation(subclass: clName, parentClass: baseClassName))
                }
            }
        }

        for compType in complexTypes {
            guard let tName = createClassNameFromType((compType as? XMLElement)?.attribute(forName: "name")?.stringValue) else { continue }

            var baseClassName = ""
            let paramNode: [XMLElement]?
            if compType.children?[0].name == "xs:complexContent" {
                if compType.children?[0].children?[0].name == "xs:extension" {
                    baseClassName = createClassNameFromType((compType.children?[0].children?[0] as? XMLElement)?.attribute(forName: "base")?.stringValue) ?? ""
                    paramNode = (compType.children?[0].children?[0].children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
                } else {
                    paramNode = (compType.children?[0].children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
                }
            } else {
                paramNode = (compType.children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
            }

            print("Name: \(tName); baseClassName: \(baseClassName); param count:\(paramNode?.count ?? 0)")

            var rProps = [RESTProperty]()
            if let paramNode = paramNode {
                for prop in (paramNode.filter { $0.name == "xs:element" }) {
                    if let element = RESTProperty(wsdlElement: prop,
                                                  enumParentName: nil,
                                                  withEnumNames: enums,
                                                  overrideInitializers: parentRelations) {
                        rProps.append(element)
                    }
                }
            }
            complexTypesInfos.append(ComplexTypesInfo(name: tName, parentName: baseClassName, restprops: rProps, isProtocol: protocolNames.contains(tName)))
        }

        var tProtocols = [ProtocolDeclaration]()
        for complexType in complexTypesInfos {
            let thisProtocol = ProtocolDeclaration(name: complexType.name,
                                                   restProperties: complexType.restprops,
                                                   withEnumNames: enums,
                                                   withProtocolNames: protocolNames,
                                                   withProtocols: nil,
                                                   withPrimitiveProxyNames: Set<String>())
            tProtocols.append(thisProtocol)
        }

        protocols = [ProtocolDeclaration]()
        for complexType in complexTypesInfos {
            let thisProtocol = ProtocolDeclaration(name: complexType.name,
                                                   restProperties: complexType.restprops,
                                                   withEnumNames: enums,
                                                   withProtocolNames: protocolNames,
                                                   withProtocols: tProtocols,
                                                   withPrimitiveProxyNames: Set<String>())
            protocols?.append(thisProtocol)
        }

        for complexType in complexTypesInfos {

            if protocolNames.contains(complexType.name) {
                if let content = generateProtocolFileForProtocol(complexType.name) {
                    if let fpath = pathForClassName(complexType.name, inFolder: pwd) {
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
                continue
            }

            let protoDeclaration = protocols?.first(where: { $0.name == complexType.parentName })
            if let content = generateClassFinally(nil, withName: complexType.name, parentProtocol: protoDeclaration, storedProperties: complexType.restprops) {
                if let fpath = pathForClassName(complexType.name, inFolder: pwd) {
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

        var primitiveProxies = Set<String>()
        for thisEntity in entities {
            guard let children2 = thisEntity.children as? [XMLElement],
                let userInfo = children2.first(where: { $0.name == "userInfo" }),
                let theseInfos = userInfo.children as? [XMLElement] else {
                    continue
            }
            if theseInfos.first(where: { $0.attribute(forName: "key")?.stringValue == "isPrimitiveProxy" }) != nil {
                if let entityName = (thisEntity as? XMLElement)?.attribute(forName: "name")?.stringValue {
                    primitiveProxies.insert(entityName)
                }
            }
        }
        primitiveProxyNames = primitiveProxies

        for thisEntity in entities {
            guard let children2 = thisEntity.children as? [XMLElement],
                let userInfo = children2.first(where: { $0.name == "userInfo" }),
                let isEnumInfos = userInfo.children as? [XMLElement] else {
                    continue
            }
            if isEnumInfos.first(where: { $0.attribute(forName: "key")?.stringValue == "isEnum" }) != nil {
                if let entityName = (thisEntity as? XMLElement)?.attribute(forName: "name")?.stringValue {
                    enums.insert(entityName)
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
                isAbstractNode.stringValue == "YES",
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: unwrappedEntity,
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
            guard let className = classNameNode?.stringValue,
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let protocolName = unwrappedEntity.attribute(forName: "parentEntity")?.stringValue {
                let parentProtocol = (protocols?.filter { $0.name == protocolName })?.first
                parentProtocol?.addConsumer(structName: className)
            }
        }

        // now do the first step again in order to have the information of all other protocols
        var newProts = [ProtocolDeclaration]()
        for thisEntity in entities {
            guard let isAbstractNode = (thisEntity as? XMLElement)?.attribute(forName: "isAbstract"),
                isAbstractNode.stringValue == "YES",
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: unwrappedEntity,
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
            guard let className = classNameNode?.stringValue,
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let protocolName = unwrappedEntity.attribute(forName: "parentEntity")?.stringValue {
                let parentProtocol = newProts.first(where: { $0.name == protocolName })
                parentProtocol?.addConsumer(structName: className)
            }
        }
        protocols = newProts

        for thisEntity in entities {
            let classNameNode = (thisEntity as? XMLElement)?.attribute(forName: "name")
            guard let className = classNameNode?.stringValue,
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateEnumFileFor(entity: unwrappedEntity, withName: className) {
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
            guard let className = classNameNode?.stringValue,
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateProtocolFileForEntity(unwrappedEntity, withName: className) {
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
            guard let className = classNameNode?.stringValue,
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let content = generateClassFileForEntity(unwrappedEntity, withName: className) {
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

        if let userInfo = properties.first(where: { $0.name == RESTProperty.Constants.UserInfoKeyName }),
            let jsProps = userInfo.children as? [XMLElement] {

            if jsProps.first(where: { $0.attribute(forName: "key")?.stringValue == "isPrimitiveProxy" }) != nil {
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

        return generateClassFinally(properties, withName: className, parentProtocol: parentProtocol, storedProperties: nil)
    }

    fileprivate final func generateClassFinally(_ properties: [XMLElement]?, withName className: String, parentProtocol: ProtocolDeclaration?, storedProperties: [RESTProperty]?) -> String? {

        var classString = headerStringFor(filename: className)

        classString += "import Foundation\n\npublic struct \(className): "
        if parentProtocol != nil {
            classString += parentProtocol!.name + ", "
            if let pprotName = parentProtocol?.parentName,
                !pprotName.isEmpty {
                classString += pprotName + ", "
                var pp = protocols?.first(where: { $0.name == pprotName })
                while pp != nil,
                let ppprotName = pp?.parentName,
                    !ppprotName.isEmpty {
                        classString += ppprotName + ", "
                        pp = protocols?.first(where: { $0.name == ppprotName })
                }
            }
        }
        classString += "JSOBJSerializable, DictionaryConvertible, CustomStringConvertible {\n"

        var ind = indent

        classString += "\n\(ind)// DTO properties:\n"

        let ppRestProps = parentProtocol?.restProperties ?? [RESTProperty]()
        let parentPropertyNames = Set(parentProtocol?.restProperties.flatMap { $0.name } ?? [String]())
        for property in ppRestProps {
            classString += "\(property.declarationString)\n"
        }
        if !ppRestProps.isEmpty { classString += "\n" }

        let restprops: [RESTProperty]
        if let storedProperties = storedProperties {
            restprops = storedProperties
        } else if let properties = properties {
            restprops = properties.flatMap { RESTProperty(xmlElement: $0,
                                                          enumParentName: nil,
                                                          withEnumNames: enumNames ?? Set<String>(),
                                                          withProtocolNames: protocolNames,
                                                          withProtocols: protocols,
                                                          withPrimitiveProxyNames: primitiveProxyNames) }
        } else {
            return nil
        }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.declarationString)\n"
            }
        }

        classString += "\n\(ind)// Default initializer:\n"
        classString += "\(ind)public init("
        for property in ppRestProps {
            classString += "\(property.defaultInitializeParameter), "
        }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeParameter), "
            }
        }
        classString = classString.substring(to: classString.index(classString.endIndex, offsetBy: -2))
        classString += ") {\n"
        for property in ppRestProps {
            classString += "\(property.defaultInitializeString)\n"
        }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.defaultInitializeString)\n"
            }
        }
        classString += "\(ind)}\n"

        classString += "\n\(ind)// Object creation using JSON dictionary representation from NSJSONSerializer:\n"
        classString += "\(ind)public init?(jsonData: JSOBJ?) {\n"
        classString += "\(ind)\(ind)guard let jsonData = jsonData else { return nil }\n"

        for property in ppRestProps {
            classString += "\(property.initializeString)\n"
        }
        if !ppRestProps.isEmpty { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.initializeString)\n"
            }
        }
        classString += "\n\(ind)\(ind)#if DEBUG\n\(ind)\(ind)\(ind)DTODiagnostics.analize(jsonData: jsonData, expectedKeys: allExpectedKeys, inClassWithName: \"\(className)\")\n\(ind)\(ind)#endif\n"
        classString += "\(ind)}\n"

        var hasProperties = false

        classString += "\n\(ind)// all expected keys (for diagnostics in debug mode):\n"
        classString += "\(ind)public var allExpectedKeys: Set<String> {\n\(ind)\(ind)return Set(["
        for property in ppRestProps {
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

        classString += "\(ind)}\n"

        classString += "\n\(ind)// dictionary representation (for use with NSJSONSerializer or as parameters for URL request):\n"
        classString += "\(ind)public var jsobjRepresentation: JSOBJ {\n"
        ind += indent
        classString += "\(ind)var jsonData = JSOBJ()\n"

        for property in ppRestProps {
            classString += "\(property.exportString)\n"
        }
        if !ppRestProps.isEmpty { classString += "\n" }

        for property in restprops {
            if !parentPropertyNames.contains(property.name) {
                classString += "\(property.exportString)\n"
            }
        }
        classString += "\(ind)return jsonData\n"
        ind = ind.substring(start: 0, end: (indent.characters.count * -1))
        classString += "\(ind)}\n"

        classString += "\n\(ind)// printable protocol conformance:\n"
        classString += "\(ind)public var description: String { return \"\\(jsonString())\" }\n"

        classString += "\n\(ind)// pretty print JSON string representation:\n"
        classString += "\(ind)public func jsonString(paddingPrefix prefix: String = \"\", printNulls: Bool = false) -> String {\n"
        ind += indent
        classString += "\(ind)var returnString = \"{\\n\"\n"
        classString += "\n"

        hasProperties = false
        for property in ppRestProps {
            classString += "\(property.jsonString)\n"
            hasProperties = true
        }
        if !ppRestProps.isEmpty { classString += "\n" }

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
        classString += "\(ind)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \"\\n\"))\n"
        classString += "\(ind)returnString = returnString.trimmingCharacters(in: CharacterSet(charactersIn: \",\"))\n"
        classString += "\(ind)returnString += \"\\n\\(prefix)}\"\n"
        classString += "\(ind)return returnString\n"
        ind = ind.substring(start: 0, end: (indent.characters.count * -1))
        classString += "\(ind)}\n"

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

        let restprops = properties.flatMap { RESTProperty(xmlElement: $0,
                                                          enumParentName: "String",
                                                          withEnumNames: enumNames ?? Set<String>(),
                                                          withProtocolNames: protocolNames,
                                                          withProtocols: protocols,
                                                          withPrimitiveProxyNames: primitiveProxyNames) }

        return generateEnumFileForEntityFinally(restprops, withName: className, enumParentName: "String")
    }

    private final func generateEnumFileForEntityFinally(_ restprops: [RESTProperty], withName className: String, enumParentName: String) -> String? {

        var classString = headerStringFor(filename: className)

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

            if commonProtocol != nil {
                classString += "\n"

                enumsWithRelations.insert(className)

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
        if let prop = protocolData.restProperties.first(where: { $0.isEnumProperty == true }) {
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
        return "//\n//  \(filename).swift\n\n"
            + "//  Automatically created by SwiftDTO.\n"
            + "//  \(copyRightString)\n\n"
            + "// DO NOT EDIT THIS FILE!\n"
            + "// This file was automatically generated from a xcmodel file (CoreData XML Scheme)\n"
            + "// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO\n"
            + "// to create the corresponding DTO source files automatically\n\n"
    }

}

extension String {
    func substring(start: Int, end: Int) -> String {
        let strLength = characters.count
        let startPos = start < 0 ? characters.count + start: start
        guard startPos < strLength else { return "" }
        let endPos = end < 0 ? characters.count + end: end
        guard endPos >= Int(startPos) else { return "" }
        return self[index(startIndex, offsetBy: Int(startPos))..<index(startIndex, offsetBy: min(endPos, characters.count))]
    }
}
