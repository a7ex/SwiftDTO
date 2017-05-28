//
//  XMLModelTranslator.swift
//  SwiftDTO
//
//  Created by alex da franca on 19/06/16.
//  Copyright © 2016 farbflash. All rights reserved.
//

import Foundation

struct ParentRelation: Hashable {
    let subclass: String
    let parentClass: String

    static func ==(lhs: ParentRelation, rhs: ParentRelation) -> Bool {
        return lhs.subclass == rhs.subclass && lhs.parentClass == rhs.parentClass
    }

    var hashValue: Int {
        return subclass.hashValue ^ parentClass.hashValue
    }
}

extension XMLNode {

    var isPrimitiveProxy: Bool {
        if let userInfo = (children as? [XMLElement])?.first(where: { $0.name == RESTProperty.Constants.UserInfoKeyName }),
            let jsProps = userInfo.children as? [XMLElement] {
            if jsProps.first(where: { $0.attributeStringValue(for: "key") == "isPrimitiveProxy" }) != nil {
                return true
            }
        }
        return false
    }

    var isEnum: Bool {
        if let userInfo = (children as? [XMLElement])?.first(where: { $0.name == RESTProperty.Constants.UserInfoKeyName }),
            let jsProps = userInfo.children as? [XMLElement] {
            if jsProps.first(where: { $0.attributeStringValue(for: "key") == "isEnum" }) != nil {
                return true
            }
        }
        return false
    }

    func attributeStringValue(for attributeName: String) -> String? {
        return (self as? XMLElement)?.attribute(forName: attributeName)?.stringValue
    }
}

struct ComplexTypesInfo {
    let name: String
    let parentName: String
    let restprops: [RESTProperty]
    let isProtocol: Bool
}

class XMLModelParser {

    // MARK: - Instance variables

    let model: XMLNode

    var protocolNames = Set<String>()
    var protocols: [ProtocolDeclaration]?

    var enumNames = Set<String>()
    var enums = [EnumInfo]()
    var enumsWithRelations = Set<String>()

    var coreDataEntities = [XMLNode]()
    var complexTypesInfos = [ComplexTypesInfo]()

    var primitiveProxyNames = Set<String>()

    var parentRelations = Set<ParentRelation>()

    // MARK: - Types

    struct EnumInfo {
        let name: String
        let typeName: String
        let restprops: [RESTProperty]
    }

    // MARK: - Initializer

    init?(xmlData: XMLDocument) {
        if let children = xmlData.children, !children.isEmpty,
            let mo = children.first(where: { $0.name == "model" }) {
            self.model = mo
        } else if let children = xmlData.children, !children.isEmpty,
            let mo = children.first(where: { $0.name == "xs:schema" }) {
            self.model = mo
        } else {
            return nil
        }
    }

    func addXMLData(xmlData: XMLDocument) {
        guard let children = xmlData.children,
            !children.isEmpty else { return }
        if let newModel = children.first(where: { $0.name == "model" }) {
            if let chldren = newModel.children {
                for thisModel in chldren {
                    thisModel.detach()
                    (model as? XMLElement)?.addChild(thisModel)
                }
            }

        } else if let newModel = children.first(where: { $0.name == "xs:schema" }) {
            if let chldren = newModel.children {
                for thisModel in chldren {
                    thisModel.detach()
                    (model as? XMLElement)?.addChild(thisModel)
                }
            }
        }
    }

    // MARK: - Shared helpers (used by concrete subclasses)

    final func removeCommaAtPos(_ pos: Int, sourceString: String) -> String {
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

    final func protocolNameFor(_ childName: String) -> String {
        for thisProtocol in protocols ?? [ProtocolDeclaration]() {
            if thisProtocol.consumers.contains(childName) {
                return thisProtocol.name
            }
        }
        return ""
    }

    final func headerStringFor(filename: String) -> String {
        return "//\n//  \(filename).swift\n\n"
            + "//  Automatically created by SwiftDTO.\n"
            + "//  \(copyRightString)\n\n"
            + "// DO NOT EDIT THIS FILE!\n"
            + "// This file was automatically generated from a xcmodel file (CoreData XML Scheme)\n"
            + "// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO\n"
            + "// to create the corresponding DTO source files automatically\n\n"
    }

    // MARK: - File generator

    final func parseXMLFiles() {
        guard let children = model.children else { return }

        coreDataEntities = children.filter { $0.name == "entity" } // coreData
        let complexTypes = children.filter { $0.name == "xs:complexType" } // soap/wsdl
        let simpleTypes = children.filter { $0.name == "xs:simpleType" } // soap/wsdl

        enumNames = Set<String>()
        protocols = [ProtocolDeclaration]()

        parseEnumFilesInWSDL(with: simpleTypes)
        parseComplexTypesInWSDL(with: complexTypes)
        parseCoreDataXML(with: coreDataEntities)
    }

    private final func parseCoreDataXML(with entities: [XMLNode]) {

        var primitiveProxies = Set<String>()

        for thisEntity in entities where thisEntity.isPrimitiveProxy {
            if let entityName = thisEntity.attributeStringValue(for: "name") {
                primitiveProxies.insert(entityName)
            }
        }
        primitiveProxyNames = primitiveProxies

        for thisEntity in entities where thisEntity.isEnum {
            if let entityName = thisEntity.attributeStringValue(for: "name") {
                enumNames.insert(entityName)
            }
        }

        for thisEntity in entities {
            guard thisEntity.attributeStringValue(for: "isAbstract") == "YES",
                let className = thisEntity.attributeStringValue(for: "name") else { continue }
            protocolNames.insert(className)
        }

        var newProts = [ProtocolDeclaration]()
        for thisEntity in entities {
            guard thisEntity.attributeStringValue(for: "isAbstract") != "YES",
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: unwrappedEntity,
                                                      isEnum: false,
                                                      withEnumNames: enumNames,
                                                      withProtocolNames: protocolNames,
                                                      withProtocols: nil,
                                                      withPrimitiveProxyNames: primitiveProxyNames) {
                newProts.append(thisProtocol)
            }
        }

        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let protocolName = thisEntity.attributeStringValue(for: "parentEntity") else { continue }
            let parentProtocol = newProts.first(where: { $0.name == protocolName })
            parentProtocol?.addConsumer(structName: className)
        }

        // now do the first step again in order to have the information of all other protocols

        for thisEntity in entities {
            guard thisEntity.attributeStringValue(for: "isAbstract") != "YES",
                let unwrappedEntity = thisEntity as? XMLElement else { continue }
            if let thisProtocol = ProtocolDeclaration(xmlElement: unwrappedEntity,
                                                      isEnum: false,
                                                      withEnumNames: enumNames,
                                                      withProtocolNames: protocolNames,
                                                      withProtocols: protocols,
                                                      withPrimitiveProxyNames: primitiveProxyNames) {
                protocols?.append(thisProtocol)
            }
        }
        for thisEntity in entities {
            guard let className = thisEntity.attributeStringValue(for: "name"),
                let protocolName = thisEntity.attributeStringValue(for: "parentEntity") else { continue }
            let parentProtocol = protocols?.first(where: { $0.name == protocolName })
            parentProtocol?.addConsumer(structName: className)
        }
    }

    private final func parseEnumFilesInWSDL(with simpleTypes: [XMLNode]) {
        for simpType in simpleTypes {

            guard let xmlElement = simpType as? XMLElement,
                let enumName = createClassNameFromType(xmlElement.attributeStringValue(for: "name")) else { continue }

            let enumerations: [XMLElement]
            let enumParentName: String
            if let enumParent = simpType.children?.first(where: { $0.name == "xs:restriction" }) as? XMLElement {
                let parentName = enumParent.attributeStringValue(for: "base")
                enumParentName = createClassNameFromType(parentName) ?? ""
                enumerations = enumParent.children as? [XMLElement] ?? [XMLElement]()
            } else {
                enumParentName = ""
                enumerations = simpType.children as? [XMLElement] ?? [XMLElement]()
            }

            var enumProperties = [RESTProperty]()
            for enumVal in (enumerations.filter { $0.name == "xs:enumeration" }) {
                if let element = RESTProperty(wsdlElement: enumVal,
                                              enumParentName: enumParentName,
                                              withEnumNames: enumNames,
                                              overrideInitializers: Set<ParentRelation>()) {
                    enumProperties.append(element)
                }
            }

            if enumProperties.count > 0 {
                enumNames.insert(enumName)
                enums.append(EnumInfo(name: enumName, typeName: enumParentName, restprops: enumProperties))
            }
        }
    }

    private final func parseComplexTypesInWSDL(with complexTypes: [XMLNode]) {

        complexTypesInfos = [ComplexTypesInfo]()

        // find all nodes, which are subclasses (have a child: "xs:extension")
        // store their baseclass names (they will become protocols)
        // and also store a record for the parent child relationships
        for compType in complexTypes {
            guard createClassNameFromType(compType.attributeStringValue(for: "name")) != nil else { continue }

            if compType.children?[0].name == "xs:complexContent",
                compType.children?[0].children?[0].name == "xs:extension",
                let baseClassName = createClassNameFromType(compType.children?[0].children?[0].attributeStringValue(for: "base")) {
                protocolNames.insert(baseClassName)
                if let clName = createClassNameFromType(compType.attributeStringValue(for: "name")) {
                    parentRelations.insert(ParentRelation(subclass: clName, parentClass: baseClassName))
                }
            }
        }

        // loop through all complex types and gather their "xs:sequence" children (-> properties)
        // and create an RESTProperty instance for each
        for compType in complexTypes {
            guard let tName = createClassNameFromType(compType.attributeStringValue(for: "name")) else { continue }

            var baseClassName = ""
            let paramNode: [XMLElement]?
            if compType.children?[0].name == "xs:complexContent" {
                if compType.children?[0].children?[0].name == "xs:extension" {
                    baseClassName = createClassNameFromType(compType.children?[0].children?[0].attributeStringValue(for: "base")) ?? ""
                    paramNode = (compType.children?[0].children?[0].children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
                } else {
                    paramNode = (compType.children?[0].children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
                }
            } else {
                paramNode = (compType.children?.filter { $0.name == "xs:sequence" })?.first?.children as? [XMLElement]
            }

            var rProps = [RESTProperty]()
            if let paramNode = paramNode {
                for prop in (paramNode.filter { $0.name == "xs:element" }) {
                    if let element = RESTProperty(wsdlElement: prop,
                                                  enumParentName: nil,
                                                  withEnumNames: enumNames,
                                                  overrideInitializers: parentRelations) {
                        rProps.append(element)
                    }
                }
            }
            complexTypesInfos.append(ComplexTypesInfo(name: tName, parentName: baseClassName, restprops: rProps, isProtocol: protocolNames.contains(tName)))
        }

        // go through all complex types to create ProtocolDeclarations
        for complexType in complexTypesInfos {
            let thisProtocol = ProtocolDeclaration(name: complexType.name,
                                                   restProperties: complexType.restprops,
                                                   withParentRelations: parentRelations)
            protocols?.append(thisProtocol)
        }

    }

}
