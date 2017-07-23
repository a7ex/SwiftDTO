//
//  main.swift
//  SwiftDTO
//
//  Created by alex da franca on 19/06/16.
//  Copyright © 2016 farbflash. All rights reserved.
//

// usage:
//          SwiftDTO DTOModel.xcdatamodeld/DTOModel.xcdatamodel/contents

import Foundation

/// adjust it for your needs, it is used for the header of each swift file
let copyRightString = "Copyright (c) 2016 Farbflash. All rights reserved."

let options = CliArguments()

if options.help {
    options.printHelpText()
    exit(EXIT_SUCCESS)
}
if options.version {
    options.printVersion()
    exit(EXIT_SUCCESS)
}

guard let firstInputFile = options.paths.first,
    let targetFolder = options.destination.nonEmptyString else {
    // Expecting a string but didn't receive it
    writeToStdError("Expected string argument defining the output folder and at least one path to an XML file!\n")
    options.printHelpText()
    exit(EXIT_FAILURE)
}

let url = URL(fileURLWithPath: firstInputFile)

// Check if the file exists, exit if not
var error: NSError?
if !(url as NSURL).checkResourceIsReachableAndReturnError(&error) {
    exit(EXIT_FAILURE)
}

do {
    let xml = try XMLDocument(contentsOf: url, options: 0)

    if let parser = XMLModelParser(xmlData: xml) {
        // if there is more than one xml file specified
        // add them now to the array of elements:
        for thisPath in options.paths[1..<options.paths.count] {
            let thisUrl = URL(fileURLWithPath: thisPath)
            if let thisXML = try? XMLDocument(contentsOf: thisUrl, options: 0) {
                parser.addXMLData(xmlData: thisXML)
            }
        }
        parser.parseXMLFiles()
        let generator: DTOFileGenerator
        switch options.mode {
        case .swift: generator = XML2SwiftFiles(parser: parser)
        case .java: generator = XML2JavaFiles(parser: parser)
        }

        generator.generateFiles(inFolder: targetFolder, withParseSupport: options.parseSupport)
    }
}
catch let err as NSError {
    writeToStdError(err.localizedDescription)
    exit(EXIT_FAILURE)
}

// Finally, exit
exit(EXIT_SUCCESS)
