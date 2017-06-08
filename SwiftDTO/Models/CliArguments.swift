//
//  CliArguments.swift
//  ArgsTester
//
//  Created by Alex da Franca on 07.06.17.
//  Copyright © 2017 apprime. All rights reserved.
//

import Foundation

/// This is the "model" for our supported command line parameters
/// This is an example for a programm which recognizes -h (or -? or --help), -m (or --mode) with a paramter
/// and all unnamed parameters go into the array "paths"

struct CliArguments {
    let help: Bool
    let paths: [String]
    let mode: OutputMode
    let programName: String
    let programPath: String

    init() {
        let cliArguments = CLIArgsParser.processCLIArgs(cliParams: CommandLine.arguments)
        self.init(with: cliArguments)
    }

    init(with cliParams: [String: Any]) {
        // program stats:
        programName = (cliParams[SpecialCliArgsParserKeys.programName.rawValue] as? String) ?? ""
        programPath = (cliParams[SpecialCliArgsParserKeys.programPath.rawValue] as? String) ?? ""

        // help:
        help = (cliParams["help"] as? Bool) ?? (cliParams["h"] as? Bool) ?? (cliParams["?"] as? Bool) ?? false

        // named switches:
        mode = OutputMode.fromString(cliParams["mode"] as? String ?? cliParams["m"] as? String)

        // unnamed parameters:
        paths = (cliParams[SpecialCliArgsParserKeys.unnamed.rawValue] as? [String]) ?? [String]()
    }

    func printHelpText() {
        print("Usage: \(programName) [options]")
        print("  -h, -?, --help:\n    Prints a help message.")
        print("  -m, --mode:\n    The output mode. The format of the output files. Can be one of the follwoing values: swift (or: s), java (or: j).")
        print("\n  all remaining parameters are considered path names\n\n")
    }
}

enum OutputMode: String {
    case swift, java

    static func fromString(_ input: String?) -> OutputMode {
        guard let input = input else {
            return .swift
        }
        switch input.lowercased() {
        case "swift", "s": return .swift
        case "java", "j": return .java
        default: return .swift
        }
    }
}
