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

func writeToStdError(_ str: String) {
    let handle = FileHandle.standardError

    if let data = str.data(using: String.Encoding.utf8) {
        handle.write(data)
    }
}

func writeToStdOut(_ str: String) {
    let handle = FileHandle.standardOutput

    if let data = "\(str)\n".data(using: String.Encoding.utf8) {
        handle.write(data)
    }
}

if CommandLine.arguments.count < 2 {
    // Expecting a string but didn't receive it
    writeToStdError("Expected string argument defining the path to the XCModelData file!\n")
    writeToStdError("Usage: \(CommandLine.arguments[0]) [string]\n")
    exit(EXIT_FAILURE)
}

//let path = CommandLine.arguments[1]
//let path = "/Users/alexapprime/__NoBackup/user.xml"
let path = "/Users/alex/Documents/TestApps/wsdlDescriptionFiles/xsd1_schema_tracking.xml"

print("\(path)")
let url = URL(fileURLWithPath: path)

// Check if the file exists, exit if not
var error: NSError?
if !(url as NSURL).checkResourceIsReachableAndReturnError(&error) {
    exit(EXIT_FAILURE)
}

let targetFolder: String? = (CommandLine.arguments.count > 2) ? CommandLine.arguments[2]: nil

do {
    let xml = try XMLDocument(contentsOf: url, options: 0)

    if let parser = XCModelTranslator(xmlData: xml) {
        parser.generateFiles(inFolder: targetFolder)
    }
}
catch let err as NSError {
    writeToStdError(err.localizedDescription)
    exit(EXIT_FAILURE)
}

// Finally, exit
exit(EXIT_SUCCESS)
