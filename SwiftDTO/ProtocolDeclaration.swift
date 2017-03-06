//
//  ProtocolDeclaration.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 09/10/2016.
//  Copyright © 2016 farbflash. All rights reserved.
//

import Foundation

class ProtocolDeclaration {
    let name: String
    let restProperties: [RESTProperty]
    var consumers = Set<String>()
    
    init?(xmlElement: XMLElement, isEnum: Bool, withEnumNames enums: Set<String>, withProtocolNames protocolNames: Set<String>, withProtocols protocols: [ProtocolDeclaration]?,
          withPrimitiveProxyNames primitiveProxyNames: Set<String>) {
        guard let name = xmlElement.attribute(forName: "name")?.stringValue else {
                return nil
        }
        guard let properties = xmlElement.children as? [XMLElement] else { return nil }

        let restProps = properties.flatMap() { RESTProperty(xmlElement: $0,
                                                            isEnum: false,
                                                            withEnumNames: enums,
                                                            withProtocolNames: protocolNames,
                                                            withProtocols: protocols,
                                                            withPrimitiveProxyNames: primitiveProxyNames) }
        
        guard restProps.count > 0 else { return nil }
        
        self.name = name
        self.restProperties = restProps
    }
    
    var declarationString: String {
        var declareString = ""
        for property in restProperties {
            declareString = declareString + "\(property.protocolDeclarationString)\n"
        }
        return declareString
    }
    
    func addConsumer(structName: String) {
        consumers.insert(structName)
    }
    
}
