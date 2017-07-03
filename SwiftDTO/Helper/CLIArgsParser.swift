//
//  CLIArgsParser.swift
//  ArgsTester
//
//  Created by Alex da Franca on 07.06.17.
//  Copyright © 2017 apprime. All rights reserved.
//

import Foundation

enum SpecialCliArgsParserKeys: String {
    case programName = "__programName"
    case programPath = "__programPath"
    case unnamed = "__unnamedParameters"
}

struct CLIArgsParser {
    static func processCLIArgs(cliParams: [String], mapping: ((String) -> String) = { return $0 }) -> [String: Any] {
        var args = [String: Any]()
        var currentParamName = ""
        var unnamedParams = [String]()
        var endparsing = false
        for (index, thisParam) in cliParams.enumerated() {
            guard index != 0 else {
                let url = URL(fileURLWithPath: thisParam)
                args[SpecialCliArgsParserKeys.programPath.rawValue] = url.absoluteString
                args[SpecialCliArgsParserKeys.programName.rawValue] = url.lastPathComponent
                continue
            }
            guard endparsing == false else {
                unnamedParams.append(thisParam)
                continue
            }
            if thisParam.hasPrefix("--") {
                if !currentParamName.isEmpty {
                    args[mapping(currentParamName)] = true
                }
                currentParamName = thisParam.substring(from: thisParam.characters.index(thisParam.startIndex, offsetBy: 2))
            } else if thisParam == "--" {
                endparsing = true
            } else if thisParam == "-" {
                endparsing = true
            } else if thisParam.hasPrefix("-") {
                let switches = thisParam.substring(from: thisParam.characters.index(thisParam.startIndex, offsetBy: 1))

                // check for the special case of "-" starting a negative number parameter:
                let num = switches.substring(to: switches.characters.index(switches.startIndex, offsetBy: 1))
                if "0123456789".contains(num) {
                    if !currentParamName.isEmpty {
                        args[mapping(currentParamName)] = thisParam
                        currentParamName = ""
                    } else {
                        unnamedParams.append(thisParam)
                    }

                } else {
                    if !currentParamName.isEmpty {
                        args[mapping(currentParamName)] = true
                    }

                    for (index, thisChar) in switches.characters.enumerated() {
                        if index < switches.characters.count - 1 {
                            args[mapping(String(thisChar))] = true
                        } else {
                            currentParamName = String(thisChar)
                        }
                    }
                }
            } else {
                if !currentParamName.isEmpty {
                    args[mapping(currentParamName)] = thisParam
                    currentParamName = ""
                } else {
                    unnamedParams.append(thisParam)
                }
            }
        }
        if !currentParamName.isEmpty {
            args[mapping(currentParamName)] = true
        }
        args[SpecialCliArgsParserKeys.unnamed.rawValue] = unnamedParams
        return args
    }
}
