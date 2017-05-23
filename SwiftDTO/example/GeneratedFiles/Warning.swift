//
//  Warning.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public enum Warning: String {
    case TRKG_DT_LIST_EMPTY = "TRKG_DT_LIST_EMPTY"
    case ACC_DT_LIST_EMPTY = "ACC_DT_LIST_EMPTY"
    case SEND_INVIT_NOT_SET = "SEND_INVIT_NOT_SET"
    case BRG_OF_TRKG_DT_OOR = "BRG_OF_TRKG_DT_OOR"
    case SPD_OF_TRKG_DT_OOR = "SPD_OF_TRKG_DT_OOR"
    case ACCY_OF_TRKG_DT_OOR = "ACCY_OF_TRKG_DT_OOR"
    case ALT_OF_TRKG_DT_NOT_SET = "ALT_OF_TRKG_DT_NOT_SET"
    case BRG_OF_TRKG_DT_NOT_SET = "BRG_OF_TRKG_DT_NOT_SET"
    case BRG_OF_TRKG_DT_NAN = "BRG_OF_TRKG_DT_NAN"
    case ACCY_OF_TRKG_DT_NOT_SET = "ACCY_OF_TRKG_DT_NOT_SET"
    case SPD_OF_TRKG_DT_NOT_SET = "SPD_OF_TRKG_DT_NOT_SET"
    case SPD_OF_TRKG_DT_NAN = "SPD_OF_TRKG_DT_NAN"
    case TRKG_DT_TIMELINE_INVALID = "TRKG_DT_TIMELINE_INVALID"
    case ALL_TRKG_DT_RECS_FILTERED = "ALL_TRKG_DT_RECS_FILTERED"
    case ALL_ACC_DT_RECS_FILTERED = "ALL_ACC_DT_RECS_FILTERED"
    case TRKG_DT_ALREADY_SENT = "TRKG_DT_ALREADY_SENT"
    case X_ACC_VAL_NOT_SET = "X_ACC_VAL_NOT_SET"
    case Y_ACC_VAL_NOT_SET = "Y_ACC_VAL_NOT_SET"
    case Z_ACC_VAL_NOT_SET = "Z_ACC_VAL_NOT_SET"
    case ACC_DT_ALREADY_SENT = "ACC_DT_ALREADY_SENT"

    public static func byString(_ typeAsString: String?) -> Warning? {
        switch (typeAsString ?? "").uppercased() {
        case "TRKG_DT_LIST_EMPTY":
            return .TRKG_DT_LIST_EMPTY
        case "ACC_DT_LIST_EMPTY":
            return .ACC_DT_LIST_EMPTY
        case "SEND_INVIT_NOT_SET":
            return .SEND_INVIT_NOT_SET
        case "BRG_OF_TRKG_DT_OOR":
            return .BRG_OF_TRKG_DT_OOR
        case "SPD_OF_TRKG_DT_OOR":
            return .SPD_OF_TRKG_DT_OOR
        case "ACCY_OF_TRKG_DT_OOR":
            return .ACCY_OF_TRKG_DT_OOR
        case "ALT_OF_TRKG_DT_NOT_SET":
            return .ALT_OF_TRKG_DT_NOT_SET
        case "BRG_OF_TRKG_DT_NOT_SET":
            return .BRG_OF_TRKG_DT_NOT_SET
        case "BRG_OF_TRKG_DT_NAN":
            return .BRG_OF_TRKG_DT_NAN
        case "ACCY_OF_TRKG_DT_NOT_SET":
            return .ACCY_OF_TRKG_DT_NOT_SET
        case "SPD_OF_TRKG_DT_NOT_SET":
            return .SPD_OF_TRKG_DT_NOT_SET
        case "SPD_OF_TRKG_DT_NAN":
            return .SPD_OF_TRKG_DT_NAN
        case "TRKG_DT_TIMELINE_INVALID":
            return .TRKG_DT_TIMELINE_INVALID
        case "ALL_TRKG_DT_RECS_FILTERED":
            return .ALL_TRKG_DT_RECS_FILTERED
        case "ALL_ACC_DT_RECS_FILTERED":
            return .ALL_ACC_DT_RECS_FILTERED
        case "TRKG_DT_ALREADY_SENT":
            return .TRKG_DT_ALREADY_SENT
        case "X_ACC_VAL_NOT_SET":
            return .X_ACC_VAL_NOT_SET
        case "Y_ACC_VAL_NOT_SET":
            return .Y_ACC_VAL_NOT_SET
        case "Z_ACC_VAL_NOT_SET":
            return .Z_ACC_VAL_NOT_SET
        case "ACC_DT_ALREADY_SENT":
            return .ACC_DT_ALREADY_SENT
        default:
            #if DEBUG
                DTODiagnostics.unknownEnumCase(typeAsString, inEnum: "Warning")
            #endif
            return nil
        }
    }

}
