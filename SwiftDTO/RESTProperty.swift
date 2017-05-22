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
    }
    let name: String
    let type: String
    let primitiveType: String
    let value: String?
    let isOptional: Bool
    let jsonProperty: String
    let isPrimitiveType: Bool
    let isArray: Bool
    let isEnum: Bool
    let isEnumProperty: Bool
    let typeIsProxyType: Bool
    let protocolInitializerType: String
    let enumParentName: String

    let indent = "    "

    init?(wsdlElement: XMLElement,
          enumParentName: String?,
          withEnumNames enums: Set<String>) {

        self.isEnum = enumParentName != nil
        if isEnum {
            guard let propname = wsdlElement.attribute(forName: "value")?.stringValue,
                !propname.isEmpty else { return nil }
            name = propname
            type = "String"
            isPrimitiveType = true
            isArray = false
            isEnumProperty = false
            primitiveType = type
            protocolInitializerType = ""
            value = propname
            isOptional = false
            jsonProperty = name
            typeIsProxyType = false

            if let enumParentName = enumParentName,
                !enumParentName.isEmpty {
                switch enumParentName {
                case "xs:int": self.enumParentName = "Int"
                default: self.enumParentName = "String"
                }
            } else {
                self.enumParentName = "String"
            }
            return
        }

        guard let propname = wsdlElement.attribute(forName: "name")?.stringValue,
            !propname.isEmpty,
            let nsproptype = wsdlElement.attribute(forName: "type")?.stringValue,
            !nsproptype.isEmpty else { return nil }

        name = propname
        jsonProperty = propname

        if let propmaxOccurs = wsdlElement.attribute(forName: "maxOccurs")?.stringValue,
            let maxOcc = Int(propmaxOccurs),
            maxOcc > 1 {
            isArray = true
        } else {
            isArray = false
        }

        var opt = false
        let propnillable = wsdlElement.attribute(forName: "nillable")?.stringValue
        opt = (propnillable == "true")

        let propminOccurs = wsdlElement.attribute(forName: "minOccurs")?.stringValue
        if !opt { opt = (propminOccurs == "0") }

        var primType = ""
        var isPrimType = false
        let proptype = nsproptype.components(separatedBy: ":").last!
        switch nsproptype {
        case "xs:int", "xs:long":
            primType = "Int"
            isPrimType = true
        case "xs:float", "xs:double":
            primType = "Double"
            isPrimType = true
        case "xs:boolean":
            primType = "Bool"
            isPrimType = true
        case "xs:date", "xs:dateTime":
            primType = "Date"
            isPrimType = true
        case "xs:string":
            primType = "String"
            isPrimType = true
        default:
            primType = proptype
        }
            if isArray { type = "[\(primType)]" }
            else { type = primType }

        primitiveType = primType
        isPrimitiveType = isPrimType

        isOptional = opt
        protocolInitializerType = ""
        value = nil
        isEnumProperty = enums.contains(primType)
        typeIsProxyType = false
        self.enumParentName = "String"
    }

    init?(xmlElement: XMLElement?,
          enumParentName: String?,
          withEnumNames enums: Set<String>,
          withProtocolNames protocolNames: Set<String>,
          withProtocols protocols: [ProtocolDeclaration]?,
          withPrimitiveProxyNames proxyNames: Set<String>) {

        guard let xmlElement = xmlElement,
            let name = xmlElement.attribute(forName: "name")?.stringValue else { return nil }

        self.name = name
        self.isEnum = enumParentName != nil
        self.enumParentName = enumParentName ?? "String"

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
                for thisProtocol in protocols ?? [ProtocolDeclaration]() where thisProtocol.name == ttype {
                    tmp = thisProtocol.consumers.first ?? ""
                    break
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
        } else {
            value = nil
        }

        typeIsProxyType = proxyNames.contains(isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type)

        // Override 1 to 1 name mapping by defining custom property for json property:
        if let children = xmlElement.children as? [XMLElement],
            let userInfo = children.first(where: { $0.name == Constants.UserInfoKeyName }),
            let jsProps = userInfo.children as? [XMLElement] {

            let jsProp = jsProps.first(where: { $0.attribute(forName: "key")?.stringValue == Constants.JsonPropertyOverrideName })
            jsonProperty = "\(jsProp?.attribute(forName: "value")?.stringValue ??  name)"
        }
        else {
            jsonProperty = name
        }

        //        if typeIsProxyType {
        //            print("type: \(type) is contained in: \(proxyNames)")
        //        }
        //        else {
        //            print("type: \(type) is NOT contained in: \(proxyNames)")
        //        }

        isOptional = xmlElement.attribute(forName: Constants.OptionalAttributeName)?.stringValue == "YES"
    }

    fileprivate var typeSingular: String {
        return isArray ? type.trimmingCharacters(in: CharacterSet(charactersIn: "[]")): type
    }

    var declarationString: String {
        if isEnum {
            return "case \(name.uppercased()) = \"\(value ?? name)\""
        }
        else {
            return "\(indent)public let \(name): \(type)\(isOptional ? "?": "")"
        }
    }

    var upperCasedInitializer: String {
        if isEnum {
            return "\(indent)\(indent)case \"\((value ?? name).uppercased())\":\n\(indent)\(indent)\(indent)return .\(name.uppercased())"
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
            return "\(indent)var \(name): \(type)\(isOptional ? "?": "") { get }"
        }
    }

    var defaultInitializeString: String {
        return "\(indent)\(indent)self.\(name) = \(name)"
    }

    var defaultInitializeParameter: String {
        return "\(name): \(type)\(isOptional ? "?": "")"
    }

    var initializeString: String {
        var returnIfNil = ""
        if !isOptional,
            value == nil {
            if type == "String" {
                returnIfNil = "\(indent)\(indent)guard let val = stringFromAny(jsonData[\"\(jsonProperty)\"]) else { return  nil }\n"
            } else if type == "Date" {
                returnIfNil = "\(indent)\(indent)guard let val = dateFromAny(jsonData[\"\(jsonProperty)\"]) else { return  nil }\n"
            } else if type == "Bool" {
                returnIfNil = "\(indent)\(indent)guard let val = stringFromBool(jsonData[\"\(jsonProperty)\"]) else { return  nil }\n"
            } else if isPrimitiveType {
                returnIfNil = "\(indent)\(indent)guard let val = jsonData[\"\(jsonProperty)\"] as? \(type) else { return  nil }\n"
            } else {
                returnIfNil = "\n\(indent)\(indent)else { return nil }"
            }
        }

        var defaultValueSuffix = ""
        if value != nil {
            if type == "Date" {
                defaultValueSuffix = value!
            } else if type == "String" {
                defaultValueSuffix = " ?? \"\(value!)\""
            } else if type == "Int" {
                if let val = Int(value!) {
                    defaultValueSuffix = " ?? \(val)"
                }
            } else if type == "Double" {
                if let val = Double(value!) {
                    defaultValueSuffix = " ?? \(val)"
                }
            } else if type == "Bool" {
                if value == "YES" || value == "true" {
                    defaultValueSuffix = " ?? true"
                } else if value == "NO" || value == "false" {
                    defaultValueSuffix = " ?? false"
                }
            }
        }

        if isPrimitiveType {
            if type == "Date" {
                if !returnIfNil.isEmpty {
                    return "\(returnIfNil)\(indent)\(indent)self.\(name) = val"
                } else {
                    return "\(indent)\(indent)\(name) = dateFromAny(jsonData[\"\(jsonProperty)\"])\(defaultValueSuffix)"
                }
            }
            else {
                if type == "String" { // exception for String, because if a property of type string is e.g. "true" it will appear as boolean after NSJSONSerialization :-(
                    if !returnIfNil.isEmpty {
                        return "\(returnIfNil)\(indent)\(indent)self.\(name) = val"
                    } else {
                        return "\(indent)\(indent)\(name) = stringFromAny(jsonData[\"\(jsonProperty)\"])\(defaultValueSuffix)"
                    }
                } else if type == "Bool" {
                    if !returnIfNil.isEmpty {
                        return "\(returnIfNil)\(indent)\(indent)self.\(name) = val"
                    } else {
                        return "\(indent)\(indent)\(name) = boolFromAny(jsonData[\"\(jsonProperty)\"])\(defaultValueSuffix)"
                    }
                }
                else {
                    if !returnIfNil.isEmpty {
                        return "\(returnIfNil)\(indent)\(indent)self.\(name) = val"
                    } else {
                        return "\(indent)\(indent)\(name) = jsonData[\"\(jsonProperty)\"] as? \(type)\(defaultValueSuffix)"
                    }
                }
            }
        }
        else {
            if !isOptional,
                value == nil {
                returnIfNil = "\n\(indent)\(indent)else { return nil }"
            } else {
                returnIfNil = "\n\(indent)\(indent)else { \(name) = nil }"
            }
            if isArray {
                if isEnum {
                    return "\(indent)\(indent)if let val = ((jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap { \(typeSingular).byString($0) }) { self.\(name) = val }\(returnIfNil)"
                }
                else {
                    if isEnumProperty {
                        return "\(indent)\(indent)if let val = ((jsonData[\"\(jsonProperty)\"] as? [String])?.flatMap { \(typeSingular).byString($0) }) { self.\(name) = val }\(returnIfNil)"
                    }
                    else {
                        if typeIsProxyType {
                            return "\(indent)\(indent)if let val = jsonData[\"\(jsonProperty)\"] as? [\(typeSingular)] { self.\(name) = val }\(returnIfNil)"
                        }
                        else {
                            if !protocolInitializerType.isEmpty {
                                return "\(indent)\(indent)if let val = ((jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap { \(protocolInitializerType).createWith(jsonData: $0) }) { self.\(name) = val }\(returnIfNil)"
                            }
                            else {
                                return "\(indent)\(indent)if let val = ((jsonData[\"\(jsonProperty)\"] as? JSARR)?.flatMap { \(typeSingular)(jsonData: $0) }) { self.\(name) = val }\(returnIfNil)"
                            }
                        }
                    }
                }
            }
            else {
                if isEnum {
                    if !defaultValueSuffix.isEmpty {
                        return "\(indent)\(indent)\(name) = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String)\(defaultValueSuffix)"
                    } else {
                        return "\(indent)\(indent)if let val = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String) { self.\(name) = val }\(returnIfNil)"
                    }
                }
                else {
                    if isEnumProperty {
                        if !defaultValueSuffix.isEmpty {
                            return "\(indent)\(indent)\(name) = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String)\(defaultValueSuffix)"
                        } else {
                            return "\(indent)\(indent)if let val = \(typeSingular).byString(jsonData[\"\(jsonProperty)\"] as? String) { self.\(name) = val }\(returnIfNil)"
                        }
                    }
                    else {
                        if !protocolInitializerType.isEmpty {
                            return "\(indent)\(indent)if let val = \(protocolInitializerType).createWith(jsonData: jsonData[\"\(jsonProperty)\"] as? JSOBJ) { self.\(name) = val }\(returnIfNil)"
                        }
                        else {
                            if typeSingular == "NSAttributedString" {
                                return "\(indent)\(indent)\(name) = nil"
                            }
                            else if typeSingular == "CGSize" {
                                return "\(indent)\(indent)\(name) = nil"
                            }
                            else {
                                return "\(indent)\(indent)if let val = \(typeSingular)(jsonData: jsonData[\"\(jsonProperty)\"] as? JSOBJ) { self.\(name) = val }\(returnIfNil)"
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
                if isOptional {
                    return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = stringFromDate(\(name)!) }"
                } else {
                    return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = stringFromDate(\(name))"
                }
            }
            else {
                if isOptional {
                    return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)! }"
                } else {
                    return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name)"
                }
            }
        }
        else {
            if isArray {
                if isEnum {
                    if isOptional {
                        return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.flatMap { $0.rawValue } }\n"
                    } else {
                        return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name).flatMap { $0.rawValue }\n"
                    }
                }
                else {
                    if isEnumProperty {
                        if isOptional {
                            return "\(indent)\(indent)if let \(name) = \(name) {\n\(indent)\(indent)\(indent)var tmp = [String]()\n\(indent)\(indent)\(indent)for this in \(name) { tmp.append(this.rawValue) }\n\(indent)\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = tmp\n\(indent)\(indent)}"
                        } else {
                            return "\(indent)\(indent)var tmp = [String]()\n\(indent)\(indent)for this in \(name) { tmp.append(this.rawValue) }\n\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = tmp"
                        }
                    }
                    else {
                        if typeIsProxyType {
                            if isOptional {
                                return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)! }\n"
                            } else {
                                return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name)\n"
                            }
                        }
                        else {
                            if isOptional {
                                return "\(indent)\(indent)if let \(name) = \(name) {\n\(indent)\(indent)\(indent)var tmp = [JSOBJ]()\n\(indent)\(indent)\(indent)for this in \(name) { tmp.append(this.jsobjRepresentation) }\n\(indent)\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = tmp\n\(indent)\(indent)}"
                            } else {
                                return "\(indent)\(indent)var tmp = [JSOBJ]()\n\(indent)\(indent)for this in \(name) { tmp.append(this.jsobjRepresentation) }\n\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = tmp"
                            }
                        }
                    }
                }
            }
            else {
                if isEnum {
                    if isOptional {
                        return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.rawValue }"
                    } else {
                        return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name).rawValue"
                    }
                }
                else {
                    if isEnumProperty {
                        if isOptional {
                            return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.rawValue }"
                        } else {
                            return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name).rawValue"
                        }
                    }
                    else {
                        if typeSingular == "NSAttributedString" {
                            return ""
                        }
                        else if typeSingular == "CGSize" {
                            return ""
                        }
                        else {
                            if isOptional {
                                return "\(indent)\(indent)if \(name) != nil { jsonData[\"\(jsonProperty)\"] = \(name)!.jsobjRepresentation }"
                            } else {
                                return "\(indent)\(indent)jsonData[\"\(jsonProperty)\"] = \(name).jsobjRepresentation"
                            }
                        }
                    }
                }
            }
        }
    }

    var jsonString: String {
        if isPrimitiveType {
            if type == "Date" {
                if isOptional {
                    return "\(indent)\(indent)if let \(name) = \(name) { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\\"\\(stringFromDate(\(name)))\\\",\\n\") }"
                        + "\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\") }\n"
                } else {
                    return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\\"\\(stringFromDate(\(name)))\\\",\\n\")"
                }
            }
            else {
                let valueString: String
                if type == "String" || type == "Date" {
                    valueString = "\\\"\\(\(name))\\\""
                }
                else {
                    valueString = "\\(\(name))"
                }
                if isOptional {
                    return "\(indent)\(indent)if let \(name) = \(name) { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \(valueString),\\n\") }"
                        + "\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\") }\n"
                } else {
                    return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \(valueString),\\n\")"
                }
            }
        }
        else {
            if isArray {
                if isEnumProperty {
                    if isOptional {
                        return "\(indent)\(indent)if let \(name) = \(name) {\n"
                            + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                            + "\(indent)\(indent)\(indent)for thisObj in \(name) {\n"
                            + "\(indent)\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\\"\\(thisObj.rawValue)\\\"\"),\\n\")\n"
                            + "\(indent)\(indent)\(indent)}\n"
                            + "\(indent)\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                            + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                            + "\(indent)\(indent)}\n\(indent)\(indent)else if printNulls { returnString = \"\\(returnString)\(indent)\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null\\n\" }\n"
                    } else {
                        return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                            + "\(indent)\(indent)for thisObj in \(name) {\n"
                            + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\\"\\(thisObj.rawValue)\\\"\"),\\n\")\n"
                            + "\(indent)\(indent)}\n"
                            + "\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                            + "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                            + "\(indent)\(indent)\n"
                    }
                }
                else {
                    if typeIsProxyType {
                        if isOptional {
                            return "\(indent)\(indent)if let \(name) = \(name) {\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                                + "\(indent)\(indent)\(indent)for thisObj in \(name) {\n"
                                + "\(indent)\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\(\"\\(prefix)\(indent)\(indent)\" + \"\\(thisObj)\")\"),\\n\")\n"
                                + "\(indent)\(indent)\(indent)}\n"
                                + "\(indent)\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                                + "\(indent)\(indent)}\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null\\n\") }\n"
                        } else {
                            return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                                + "\(indent)\(indent)for thisObj in \(name) {\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\(\"\\(prefix)\(indent)\(indent)\" + \"\\(thisObj)\")\"),\\n\")\n"
                                + "\(indent)\(indent)}\n"
                                + "\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                                + "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                                + "\(indent)\(indent)\n"
                        }
                    }
                    else {
                        if isOptional {
                            return "\(indent)\(indent)if let \(name) = \(name) {\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                                + "\(indent)\(indent)\(indent)for thisObj in \(name) {\n"
                                + "\(indent)\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\(thisObj.jsonString(paddingPrefix: \"\\(prefix)\(indent)\(indent)\", printNulls: printNulls))\"),\\n\")\n"
                                + "\(indent)\(indent)\(indent)}\n"
                                + "\(indent)\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                                + "\(indent)\(indent)}\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null\\n\") }\n"
                        } else {
                            return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": [\\n\")\n"
                                + "\(indent)\(indent)for thisObj in \(name) {\n"
                                + "\(indent)\(indent)\(indent)returnString.append(\"\(indent)\(indent)\\(prefix)\\(\"\\(thisObj.jsonString(paddingPrefix: \"\\(prefix)\(indent)\(indent)\", printNulls: printNulls))\"),\\n\")\n"
                                + "\(indent)\(indent)}\n"
                                + "\(indent)\(indent)if !\(name).isEmpty { returnString.remove(at: returnString.characters.index(returnString.endIndex, offsetBy: -2)) }\n"
                                + "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)],\\n\")\n"
                                + "\(indent)\(indent)\n"
                        }
                    }
                }
            }
            else {
                if isEnumProperty {
                    if isOptional {
                        return "\(indent)\(indent)if let \(name) = \(name) { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\\"\\(\(name).rawValue)\\\"\"),\\n\") }"
                            + "\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\") }"
                    } else {
                        return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\\"\\(\(name).rawValue)\\\"\"),\\n\")"
                    }
                }
                else {
                    if typeSingular == "NSAttributedString" {
                        return ""
                    }
                    else if typeSingular == "CGSize" {
                        return ""
                    }
                    else {
                        if isOptional {
                            return "\(indent)\(indent)if let \(name) = \(name) { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\(\(name).jsonString(paddingPrefix: \"\\(prefix)\(indent)\", printNulls: printNulls))\"),\\n\") }"
                                + "\n\(indent)\(indent)else if printNulls { returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": null,\\n\") }\n"
                        } else {
                            return "\(indent)\(indent)returnString.append(\"\(indent)\\(prefix)\\\"\(jsonProperty)\\\": \\(\"\\(\(name).jsonString(paddingPrefix: \"\\(prefix)\(indent)\", printNulls: printNulls))\"),\\n\")"
                        }
                    }
                }
            }
        }
    }
}
