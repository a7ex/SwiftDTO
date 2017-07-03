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
    let programName: String
    let programPath: String
    let help: Bool
    let destination: String
    let paths: [String]
    let mode: OutputType
    let parseSupport: Bool

    init() {
        let cliArguments = CLIArgsParser.processCLIArgs(cliParams: CommandLine.arguments, mapping: CliArguments.expandedPropertyName)
        self.init(with: cliArguments)
    }

    init(with cliParams: [String: Any]) {
        // program stats:
        programName = (cliParams[SpecialCliArgsParserKeys.programName.rawValue] as? String) ?? ""
        programPath = (cliParams[SpecialCliArgsParserKeys.programPath.rawValue] as? String) ?? ""

        // help:
        help = (cliParams["help"] as? Bool) ?? (cliParams["h"] as? Bool) ?? (cliParams["?"] as? Bool) ?? false

        // named switches:
        destination = cliParams["destination"] as? String ?? ""
        mode = OutputType.fromString(cliParams["mode"] as? String ?? cliParams["m"] as? String)

        // unnamed parameters:
        paths = (cliParams[SpecialCliArgsParserKeys.unnamed.rawValue] as? [String]) ?? [String]()

        parseSupport = (cliParams["parse"] as? Bool) ?? (cliParams["p"] as? Bool) ?? false
    }

    func printHelpText() {
        print("Usage: \(programName) [options]")
        print("  -h, -?, --help:\n    Prints a help message.")
        print("  -d, --destination:\n    The path to a directory to write the generated files to.")
        print("  -m, --mode:\n    The output mode. The format of the output files. Can be one of the follwoing values: swift (or: s), java (or: j).")
        print("  -p, --parse:\n    Add also code to handle Parse objects.")
        print("\n  all remaining parameters are considered paths to xml input files\n\n")
    }

    static func expandedPropertyName(for shortform: String) -> String {
        switch shortform {
        case "d": return "destination"
        case "h", "?": return "help"
        case "m": return "mode"
        case "p": return "parse"
        default: return shortform
        }
    }
}

enum OutputType: String {
    case swift, java

    static func fromString(_ input: String?) -> OutputType {
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
