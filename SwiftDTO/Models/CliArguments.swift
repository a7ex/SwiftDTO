//
//  CliArguments.swift
//
//  Created by Alex da Franca on 07.06.17.
//  Copyright © 2017 Farbflash. All rights reserved.
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
    let version: Bool

    static func expandedPropertyName(for shortform: String) -> String {
        switch shortform {
        case "d": return "destination"
        case "h", "?": return "help"
        case "v": return "version"
        case "m": return "mode"
        case "p": return "parse"
        default: return shortform
        }
    }

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

        // version:
        version = (cliParams["version"] as? Bool) ?? (cliParams["v"] as? Bool) ?? false
    }

    func printHelpText() {
        print(helpText)
    }

    func printVersion() {
        print(versionString)
    }

    var helpText: String {
        var returnText = "\(programName) - \(versionString)"
        returnText += "\nCreated by Alex da Franca - Farbflash\n"
        returnText += "\nUsage: \(programName) [options]"
        returnText += "\n  -h, -?, --help:\n    Prints a help message."
        returnText += "\n  -v, --version:\n    Prints version information."
        returnText += "\n  -d, --destination:\n    The path to a directory to write the generated files to."
        returnText += "\n  -m, --mode:\n    The output mode. The format of the output files. Can be one of the follwoing values: swift (or: s), java (or: j)."
        returnText += "\n  -p, --parse:\n    Add also code to handle Parse objects."
        returnText += "\n\n  all remaining parameters are considered paths to xml input files\n\n"
        return returnText
    }

    var versionString: String {
        let majorVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
        let buildnumber = (Bundle.main.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as? String) ?? ""
        return "Version: \(majorVersion) (Build: \(buildnumber))"
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
