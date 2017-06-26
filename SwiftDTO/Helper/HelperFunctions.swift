//
//  HelperFunctions.swift
//  SwiftDTO
//
//  Created by Alex da Franca on 24.05.17.
//  Copyright © 2017 Farbflash. All rights reserved.
//

import Foundation

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

func writeContent(_ content: String, toFileAtPath fpath: String?) {
    guard let fpath = fpath else {
        writeToStdError("Error creating enum file. Path for target file is nil.")
        return
    }
    do {
        try content.write(toFile: fpath, atomically: false, encoding: String.Encoding.utf8)
        writeToStdOut("Successfully written file to: \(fpath)\n")
    }
    catch let error as NSError {
        writeToStdError("error: \(error.localizedDescription)")
    }

}

func pathForClassName(_ className: String, inFolder target: String?, fileExtension: String = "swift") -> String? {
    guard let target = target else { return nil }
    let fileurl = URL(fileURLWithPath: target)
    let newUrl = fileurl.appendingPathComponent(className).appendingPathExtension(fileExtension)
    return newUrl.path
}

func pathForParseExtension(_ className: String, inFolder target: String?, fileExtension: String = "swift") -> String? {
    guard let target = target else { return nil }
    let fileurl = URL(fileURLWithPath: target)
    let newUrl = fileurl
        .appendingPathComponent("\(className)+Parse")
        .appendingPathExtension(fileExtension)
    return newUrl.path
}
