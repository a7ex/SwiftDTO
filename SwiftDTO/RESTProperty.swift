//
//  RESTProperty.swift
//  SwiftDTO
//
//  Created by alex da franca on 19/06/16.
//  Copyright © 2016 farbflash. All rights reserved.
//

import Foundation

struct RESTProperty {
    
    struct Constants {
        static let OptionalAttributeName = "optional"
        static let DestinationEntityAttributeName = "destinationEntity"
        static let DefaultValueStringAttributeName = "defaultValueString"
        static let TypeAttributeName = "attributeType"
        static let ToManyAttributeName = "toMany"
        static let UserInfoKeyName = "userInfo"
        static let JsonPropertyOverrideName = "jsonPropertyName"
//        static let InnerProxyType = "innerType"
    }
    let name: String
    let type: String
    let primitiveType: String
    let value: String
    let isOptional: Bool
    let jsonProperty: String
    let isPrimitiveType: Bool
    let isArray: Bool
    let isEnum: Bool
    let isEnumProperty: Bool
    let typeIsProxyType: Bool
    let protocolInitializerType: String
    
    init?(xmlElement: XMLElement?,
          isEnum: Bool,
          withEnumNames enums: Set<String>,
          withProtocolNames protocolNames: Set<String>,
          withProtocols protocols: [ProtocolDeclaration]?,
          withPrimitiveProxyNames proxyNames: Set<String>) {
        
        guard let xmlElement = xmlElement,
            let name = xmlElement.attribute(forName: "name")?.stringValue else { return nil }
        
        self.name = name
        self.isEnum = isEnum
        
        // map the type
        if let ttype = xmlElement.attribute(forName: Constants.TypeAttributeName)?.stringValue {
            switch ttype {
            case "Integer 64", "Integer 32", "Integer 16":
                type = "Int"
            case "Float", "Double", "Decimal":
                type = "Double"
            case "Boolean":
                type = "Bool"
            case "Transformable":
                type = "[String: AnyObject]"
            case "Binary":
                return nil // (Binary not supported)
            case "Date":
                type = "Date"
            default: // String
                type = "String"
            }
            isPrimitiveType = true
            isArray = false
            isEnumProperty = enums.contains(type)
            primitiveType = type
            protocolInitializerType = ""
        }
        else if let ttype = xmlElement.attribute(forName: Constants.DestinationEntityAttributeName)?.stringValue {
            if xmlElement.attribute(forName: Constants.DestinationEntityAttributeName) == nil { return nil } // backref
            let toMany = (xmlElement.attribute(forName: Constants.ToManyAttributeName)?.stringValue ?? "NO") == "YES"
            type = toMany ? "[\(ttype)]": ttype
            isPrimitiveType = false
            isArray = toMany
            isEnumProperty = enums.contains(ttype)
            primitiveType = ttype
            var tmp = ""
            if protocolNames.contains(ttype) {
                for thisProtocol in protocols ?? [ProtocolDeclaration]() {
                    if thisProtocol.name == ttype {
                        tmp = thisProtocol.consumers.first ?? ""
                        break
                    }
                }
            }
            protocolInitializerType = tmp
        }
        else { // default to string
            type = "String"
            isPrimitiveType = true
            isArray = false
            isEnumProperty = enums.contains(type)
            primitiveType = type
            protocolInitializerType = ""
        }
        
        if let defaultValue = xmlElement.attribute(forName: Constants.DefaultValueStringAttributeName)?.stringValue {
            value = defaultValue
        }
        else {
            value = ""
        }
        
        typeIsProxyType = proxyNames.contains(isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type)
        
        // Override 1 to 1 name mapping by defining custom property for json property:
        if let children = xmlElement.children as? [XMLElement],
            let userInfo = children.filter({ $0.name == Constants.UserInfoKeyName }).first,
            let jsProps = userInfo.children as? [XMLElement] {
            
            let jsProp = jsProps.filter({ $0.attribute(forName: "key")?.stringValue == Constants.JsonPropertyOverrideName }).first
            jsonProperty = "\(jsProp?.attribute(forName: "value")?.stringValue ??  name)"
            
//            print("is singletype: \((isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type)) contained in: \(proxyNames)? \(proxyNames.contains(isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type))")
//            typeIsProxyType = proxyNames.contains(isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type)
//            typeIsProxyType = (jsProps.filter({ $0.attribute(forName: "key")?.stringValue == Constants.InnerProxyType }).first) != nil
        }
        else {
            jsonProperty = name
//            typeIsProxyType = false
        }
        
        if typeIsProxyType {
            print("type: \(type) is contained in: \(proxyNames)")
        }
        else {
            print("type: \(type) is NOT contained in: \(proxyNames)")
        }
        
        isOptional = (xmlElement.attribute(forName: Constants.OptionalAttributeName)?.objectValue as? Bool) ?? true // default to optional
    }
    
    fileprivate var typeSingular: String {
        return isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type
    }
    
    var declarationString: String {
        if isEnum {
            return "case \(name.uppercased()) = \"\(value)\""
        }
        else {
            return "\tpublic let \(name): \(type)\(isOptional ? "?": "")"
        }
    }
    
    var upperCasedInitializer: String {
        if isEnum {
            return "\t\tcase \"\(value.uppercased())\":\n\t\t\treturn .\(name.uppercased())"
        }
        else {
            return ""
        }
    }
    
    var protocolDeclarationString: String {
        if isEnum {
            return ""
        }
        else {
            return "\tvar \(name): \(type)\(isOptional ? "?": "") { get }"
        }
    }
    
    var defaultInitializeString: String {
        return "\t\tself.\(name) = \(name)"
    }
    
    var defaultInitializeParameter: String {
        return "\(name): \(type)\(isOptional ? "?": "")"
    }
    
    var initializeString: String {
        if isPrimitiveType {
            if type == "Date" {
                return "\t\t\(name) = ConversionHelper.dateFromAny(jsonData[\"\(jsonProperty)\"])"
            }
            else {
                return "\t\t\(name) = jsonData[\"\(jsonProperty)\"] as? \(type)"
            }
        }
        else {
            if isArray {
                if isEnum {
                    return "\t\t\(name) = (jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap() { \(typeSingular).byString($0) }"
                }
                else {
                    if isEnumProperty {
                        return "\t\t\(name) = (jsonData[\"\(jsonProperty)\"] as? [String])?.flatMap() { \(typeSingular).byString($0) }"
                    }
                    else {
                        if typeIsProxyType {
                            return "\t\t\(name) = jsonData[\"\(jsonProperty)\"] as? [\(typeSingular)]"
                        }
                        else {
                            if !protocolInitializerType.isEmpty {
                                return "\t\t\(name) = (jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap() { \(protocolInitializerType).createWith(jsonData: $0) }"
                            }
                            else {
                                return "\t\t\(name) = (jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap() { \(typeSingular)(jsonData: $0) }"
                            }
                        }
                    }
                }
            }
            else {
                if isEnum {
                    return "\t\t\(name) = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String)"
                }
                else {
                    if isEnumProperty {
                        return "\t\t\(name) = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String)"
                    }
                    else {
                        if !protocolInitializerType.isEmpty {
                            return "\t\t\(name) = \(protocolInitializerType).createWith(jsonData: jsonData[\"\(jsonProperty)\"] as? JSOBJ)"
                        }
                        else {
                            if typeSingular == "NSAttributedString" {
                                return "\t\t\(name) = nil"
                            }
                            else if typeSingular == "CGSize" {
                                return "\t\t\(name) = nil"
                            }
                            else {
                                return "\t\t\(name) = \(typeSingular)(jsonData: jsonData[\"\(jsonProperty)\"] as? JSOBJ)"
                            }
                        }
                    }
                }
            }
        }
    }
    
    var exportString: String {
        if isPrimitiveType {
            if type == "Date" {
                return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = ConversionHelper.stringFromDate(\(name)!) }"
            }
            else {
                return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)! }"
            }
        }
        else {
            if isArray {
                if isEnum {
                    return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.flatMap() { $0.rawValue } }\n"
                }
                else {
                    if isEnumProperty {
                        
                        return "\t\tif let \(name) = \(name) {\n\t\t\tvar tmp = [String]()\n\t\t\tfor this in \(name) { tmp.append(this.rawValue) }\n\t\t\tjsonData[\"\(jsonProperty)\"] = tmp\n\t\t}"
                        
                        //                        return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.flatMap() { $0.rawValue } }\n"
                    }
                    else {
                        if typeIsProxyType {
                            return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)! }\n"
                        }
                        else {
                            return "\t\tif let \(name) = \(name) {\n\t\t\tvar tmp = [JSOBJ]()\n\t\t\tfor this in \(name) { tmp.append(this.jsobjRepresentation) }\n\t\t\tjsonData[\"\(jsonProperty)\"] = tmp\n\t\t}"
//                            return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.flatMap() { $0.jsobjRepresentation } }\n"
                        }
                    }
                }
            }
            else {
                if isEnum {
                    return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.rawValue }"
                }
                else {
                    if isEnumProperty {
                        return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.rawValue }"
                    }
                    else {
                        if typeSingular == "NSAttributedString" {
                            return ""
                        }
                        else if typeSingular == "CGSize" {
                            return ""
                        }
                        else {
                            return "\t\tif \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.jsobjRepresentation }"
                        }
                    }
                }
            }
        }
    }
    
    var jsonString: String {
        if isPrimitiveType {
            if type == "Date" {
                return "\t\tif let \(name) = \(name) { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": \\\"\\(ConversionHelper.stringFromDate(\(name)))\\\",\\n\" }"
                    + "\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\" }\n"
            }
            else {
                let valueString: String
                if type == "String" || type == "Date" {
                    valueString = "\\\"\\(\(name))\\\""
                }
                else {
                    valueString = "\\(\(name))"
                }
                return "\t\tif let \(name) = \(name) { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": \(valueString),\\n\" }"
                    + "\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\" }\n"
            }
        }
        else {
            if isArray {
                if isEnumProperty {
                    return "\t\tif let \(name) = \(name) {\n"
                        + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": [\\n\"\n"
                        + "\t\t\tfor thisObj in \(name) {\n"
                        + "\t\t\t\treturnString = \"\\(returnString)\\t\\t\\(prefix)\\(\"\\\"\\(thisObj.rawValue)\\\"\"),\\n\"\n"
                        + "\t\t\t}\n"
                        + "\t\t\tif \(name).count > 0 { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                        + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)],\\n\"\n"
                        + "\t\t}\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\t\\(prefix)\\\"\(jsonProperty)\\\": null\\n\" }\n"
                }
                else {
                    if typeIsProxyType {
                        return "\t\tif let \(name) = \(name) {\n"
                            + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": [\\n\"\n"
                            + "\t\t\tfor thisObj in \(name) {\n"
                            + "\t\t\t\treturnString = \"\\(returnString)\\t\\t\\(prefix)\\(\"\\(\"\\(prefix)\\t\\t\" + \"\\(thisObj)\")\"),\\n\"\n"
                            + "\t\t\t}\n"
                            + "\t\t\tif \(name).count > 0 { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                            + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)],\\n\"\n"
                            + "\t\t}\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\t\\(prefix)\\\"\(jsonProperty)\\\": null\\n\" }\n"
                    }
                    else {
                        return "\t\tif let \(name) = \(name) {\n"
                            + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": [\\n\"\n"
                            + "\t\t\tfor thisObj in \(name) {\n"
                            + "\t\t\t\treturnString = \"\\(returnString)\\t\\t\\(prefix)\\(\"\\(thisObj.jsonString(paddingPrefix: \"\\(prefix)\\t\\t\", printNulls: printNulls))\"),\\n\"\n"
                            + "\t\t\t}\n"
                            + "\t\t\tif \(name).count > 0 { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                            + "\t\t\treturnString = \"\\(returnString)\\t\\(prefix)],\\n\"\n"
                            + "\t\t}\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\t\\(prefix)\\\"\(jsonProperty)\\\": null\\n\" }\n"
                    }
                }
            }
            else {
                if isEnumProperty {
                    return "\t\tif let \(name) = \(name) { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\\"\\(\(name).rawValue)\\\"\"),\\n\" }"
                        + "\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\" }"
                }
                else {
                    if typeSingular == "NSAttributedString" {
                        return ""
                    }
                    else if typeSingular == "CGSize" {
                        return ""
                    }
                    else {
                        return "\t\tif let \(name) = \(name) { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\(\(name).jsonString(paddingPrefix: \"\\(prefix)\\t\", printNulls: printNulls))\"),\\n\" }"
                            + "\n\t\telse if printNulls { returnString = \"\\(returnString)\\t\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\" }\n"
                    }
                }
            }
        }
    }
}
