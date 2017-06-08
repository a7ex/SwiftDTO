//
//  XML2JavaFiles.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 08.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Cocoa

class XML2JavaFiles: DTOFileGenerator {

    let parser: XMLModelParser

    init(parser: XMLModelParser) {
        self.parser = parser
    }

    let indent = "    "

    final func generateFiles(inFolder folderPath: String? = nil) {

    }
}
