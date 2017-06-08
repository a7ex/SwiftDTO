//
//  DTOError.swift

//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public enum DTOError: String {
    case REQ_NOT_SET
    case INTERNAL_ERROR
    case SESSION_NOT_SET
    case SESSION_INVALID_OR_EXPIRED
    case LOGIN_DT_INVALID
    case EMAIL_RCPTS_EMPTY
    case EMAIL_ADDR_NOT_SET
    case EMAIL_ADDR_TOO_LONG
    case EMAIL_ADDR_INVALID
    case EMAIL_ADDR_ALRDY_USED
    case MIN_AGE_GT_MAX_AGE
    case MIN_AGE_ST_ZERO
    case MAX_AGE_ST_ZERO
    case REG_SINCE_DATE_IN_FUTURE
    case TFC_MD_NOT_SET
    case TFC_MD_CONST_NOT_SET
    case CMPY_TXT_ID_NOT_SET
    case CMPY_SEC_TK_NOT_SET
    case CMPY_SEC_TK_INVALID
    case CMPY_ID_NOT_SET
    case CMPY_ID_LTE_ZERO
    case CMPY_CRED_INVALID
    case TRK_NOT_SET
    case TRK_NAME_NOT_SET
    case TRK_NAME_TOO_LONG
    case TRK_ID_NOT_SET
    case TRK_ID_LTE_ZERO
    case TRK_ACT_NOT_SET
    case TRK_IDS_EMPTY
    case TRK_PERIOD_INVALID
    case SEGS_EMPTY
    case SEG_START_NOT_SET
    case SEG_END_NOT_SET
    case SEG_PERIOD_INVALID
    case SEG_GEOM_NOT_SET
    case SEG_GEOM_INVALID
    case LAT_OF_SEG_GEOM_NOT_SET
    case LAT_OF_SEG_GEOM_NAN
    case LAT_OF_SEG_GEOM_OOR
    case LON_OF_SEG_GEOM_NOT_SET
    case LON_OF_SEG_GEOM_NAN
    case LON_OF_SEG_GEOM_OOR
    case SEG_PERIODS_INVALID
    case USER_ID_NOT_SET
    case USER_ID_LTE_ZERO
    case CURR_PWD_NOT_SET
    case NEW_PWD_NOT_SET
    case PERS_DT_NOT_SET
    case FIRST_NAME_TOO_LONG
    case LAST_NAME_TOO_LONG
    case STREET_NAME_TOO_LONG
    case HOUSE_NO_TOO_LONG
    case ZIP_CODE_TOO_LONG
    case NAME_OF_CITY_TOO_LONG
    case MOB_PHNE_NO_TOO_LONG
    case LANDLINE_NO_TOO_LONG
    case ROLE_NOT_SET
    case ROLE_CONST_NOT_SET
    case ACCESS_FOR_ADM_PERS_NOT_SET
    case DEL_SENS_DT_ATR_CAMP_NOT_SET
    case NO_OF_PERS_OF_AGE_GRP_NOT_SET
    case NO_OF_PERS_OF_AGE_GRP_LTE_ZERO
    case AGE_GRP_NOT_SET
    case AGE_GRP_ID_NOT_SET
    case AGE_GRP_ID_LTE_ZERO
    case OCC_ID_NOT_SET
    case OCC_ID_LTE_ZERO
    case SAL_LVL_ID_NOT_SET
    case SAL_LVL_ID_LTE_ZERO
    case GRAD_ID_NOT_SET
    case GRAD_ID_LTE_ZERO
    case PERS_NOT_SET
    case REG_KEY_NOT_SET
    case REG_KEY_INVALID
    case NO_OF_REG_KEY_NOT_SET
    case NO_OF_REG_KEY_LTE_ZERO
    case QTY_PER_REG_KEY_NOT_SET
    case QTY_PER_REG_KEY_LTE_ZERO
    case POI_NOT_SET
    case POI_NAME_NOT_SET
    case POI_ID_NOT_SET
    case POI_ID_LTE_ZERO
    case LAT_OF_POI_NOT_SET
    case LAT_OF_POI_NAN
    case LAT_OF_POI_OOR
    case LON_OF_POI_NOT_SET
    case LON_OF_POI_NAN
    case LON_OF_POI_OOR
    case POI_NAME_TOO_LONG
    case POI_DESC_TOO_LONG
    case OID_NOT_SET
    case NON_INIT_TRKG_DT
    case NON_INIT_TRKG_DT_TS
    case NEGATIVE_TRKG_DT_TS
    case IDENTICAL_TRKG_DT_TS
    case LAT_OF_TRKG_DT_NOT_SET
    case LAT_OF_TRKG_DT_OOR
    case LAT_OF_TRKG_DT_NAN
    case LON_OF_TRKG_DT_NOT_SET
    case LON_OF_TRKG_DT_OOR
    case LON_OF_TRKG_DT_NAN
    case NULL_NULL_TRKG_DT_POS
    case NON_INIT_ACC_DT
    case NON_INIT_ACC_DT_TS
    case NEGATIVE_ACC_DT_TS
    case IDENTICAL_ACC_DT_TS
    case NON_INIT_X_ACC_VAL
    case NON_INIT_Y_ACC_VAL
    case NON_INIT_Z_ACC_VAL
    case X_ACC_VAL_NAN
    case Y_ACC_VAL_NAN
    case Z_ACC_VAL_NAN

    public static func byString(_ typeAsString: String?) -> DTOError? {
        switch (typeAsString ?? "").uppercased() {
        case "REQ_NOT_SET":
            return .REQ_NOT_SET
        case "INTERNAL_ERROR":
            return .INTERNAL_ERROR
        case "SESSION_NOT_SET":
            return .SESSION_NOT_SET
        case "SESSION_INVALID_OR_EXPIRED":
            return .SESSION_INVALID_OR_EXPIRED
        case "LOGIN_DT_INVALID":
            return .LOGIN_DT_INVALID
        case "EMAIL_RCPTS_EMPTY":
            return .EMAIL_RCPTS_EMPTY
        case "EMAIL_ADDR_NOT_SET":
            return .EMAIL_ADDR_NOT_SET
        case "EMAIL_ADDR_TOO_LONG":
            return .EMAIL_ADDR_TOO_LONG
        case "EMAIL_ADDR_INVALID":
            return .EMAIL_ADDR_INVALID
        case "EMAIL_ADDR_ALRDY_USED":
            return .EMAIL_ADDR_ALRDY_USED
        case "MIN_AGE_GT_MAX_AGE":
            return .MIN_AGE_GT_MAX_AGE
        case "MIN_AGE_ST_ZERO":
            return .MIN_AGE_ST_ZERO
        case "MAX_AGE_ST_ZERO":
            return .MAX_AGE_ST_ZERO
        case "REG_SINCE_DATE_IN_FUTURE":
            return .REG_SINCE_DATE_IN_FUTURE
        case "TFC_MD_NOT_SET":
            return .TFC_MD_NOT_SET
        case "TFC_MD_CONST_NOT_SET":
            return .TFC_MD_CONST_NOT_SET
        case "CMPY_TXT_ID_NOT_SET":
            return .CMPY_TXT_ID_NOT_SET
        case "CMPY_SEC_TK_NOT_SET":
            return .CMPY_SEC_TK_NOT_SET
        case "CMPY_SEC_TK_INVALID":
            return .CMPY_SEC_TK_INVALID
        case "CMPY_ID_NOT_SET":
            return .CMPY_ID_NOT_SET
        case "CMPY_ID_LTE_ZERO":
            return .CMPY_ID_LTE_ZERO
        case "CMPY_CRED_INVALID":
            return .CMPY_CRED_INVALID
        case "TRK_NOT_SET":
            return .TRK_NOT_SET
        case "TRK_NAME_NOT_SET":
            return .TRK_NAME_NOT_SET
        case "TRK_NAME_TOO_LONG":
            return .TRK_NAME_TOO_LONG
        case "TRK_ID_NOT_SET":
            return .TRK_ID_NOT_SET
        case "TRK_ID_LTE_ZERO":
            return .TRK_ID_LTE_ZERO
        case "TRK_ACT_NOT_SET":
            return .TRK_ACT_NOT_SET
        case "TRK_IDS_EMPTY":
            return .TRK_IDS_EMPTY
        case "TRK_PERIOD_INVALID":
            return .TRK_PERIOD_INVALID
        case "SEGS_EMPTY":
            return .SEGS_EMPTY
        case "SEG_START_NOT_SET":
            return .SEG_START_NOT_SET
        case "SEG_END_NOT_SET":
            return .SEG_END_NOT_SET
        case "SEG_PERIOD_INVALID":
            return .SEG_PERIOD_INVALID
        case "SEG_GEOM_NOT_SET":
            return .SEG_GEOM_NOT_SET
        case "SEG_GEOM_INVALID":
            return .SEG_GEOM_INVALID
        case "LAT_OF_SEG_GEOM_NOT_SET":
            return .LAT_OF_SEG_GEOM_NOT_SET
        case "LAT_OF_SEG_GEOM_NAN":
            return .LAT_OF_SEG_GEOM_NAN
        case "LAT_OF_SEG_GEOM_OOR":
            return .LAT_OF_SEG_GEOM_OOR
        case "LON_OF_SEG_GEOM_NOT_SET":
            return .LON_OF_SEG_GEOM_NOT_SET
        case "LON_OF_SEG_GEOM_NAN":
            return .LON_OF_SEG_GEOM_NAN
        case "LON_OF_SEG_GEOM_OOR":
            return .LON_OF_SEG_GEOM_OOR
        case "SEG_PERIODS_INVALID":
            return .SEG_PERIODS_INVALID
        case "USER_ID_NOT_SET":
            return .USER_ID_NOT_SET
        case "USER_ID_LTE_ZERO":
            return .USER_ID_LTE_ZERO
        case "CURR_PWD_NOT_SET":
            return .CURR_PWD_NOT_SET
        case "NEW_PWD_NOT_SET":
            return .NEW_PWD_NOT_SET
        case "PERS_DT_NOT_SET":
            return .PERS_DT_NOT_SET
        case "FIRST_NAME_TOO_LONG":
            return .FIRST_NAME_TOO_LONG
        case "LAST_NAME_TOO_LONG":
            return .LAST_NAME_TOO_LONG
        case "STREET_NAME_TOO_LONG":
            return .STREET_NAME_TOO_LONG
        case "HOUSE_NO_TOO_LONG":
            return .HOUSE_NO_TOO_LONG
        case "ZIP_CODE_TOO_LONG":
            return .ZIP_CODE_TOO_LONG
        case "NAME_OF_CITY_TOO_LONG":
            return .NAME_OF_CITY_TOO_LONG
        case "MOB_PHNE_NO_TOO_LONG":
            return .MOB_PHNE_NO_TOO_LONG
        case "LANDLINE_NO_TOO_LONG":
            return .LANDLINE_NO_TOO_LONG
        case "ROLE_NOT_SET":
            return .ROLE_NOT_SET
        case "ROLE_CONST_NOT_SET":
            return .ROLE_CONST_NOT_SET
        case "ACCESS_FOR_ADM_PERS_NOT_SET":
            return .ACCESS_FOR_ADM_PERS_NOT_SET
        case "DEL_SENS_DT_ATR_CAMP_NOT_SET":
            return .DEL_SENS_DT_ATR_CAMP_NOT_SET
        case "NO_OF_PERS_OF_AGE_GRP_NOT_SET":
            return .NO_OF_PERS_OF_AGE_GRP_NOT_SET
        case "NO_OF_PERS_OF_AGE_GRP_LTE_ZERO":
            return .NO_OF_PERS_OF_AGE_GRP_LTE_ZERO
        case "AGE_GRP_NOT_SET":
            return .AGE_GRP_NOT_SET
        case "AGE_GRP_ID_NOT_SET":
            return .AGE_GRP_ID_NOT_SET
        case "AGE_GRP_ID_LTE_ZERO":
            return .AGE_GRP_ID_LTE_ZERO
        case "OCC_ID_NOT_SET":
            return .OCC_ID_NOT_SET
        case "OCC_ID_LTE_ZERO":
            return .OCC_ID_LTE_ZERO
        case "SAL_LVL_ID_NOT_SET":
            return .SAL_LVL_ID_NOT_SET
        case "SAL_LVL_ID_LTE_ZERO":
            return .SAL_LVL_ID_LTE_ZERO
        case "GRAD_ID_NOT_SET":
            return .GRAD_ID_NOT_SET
        case "GRAD_ID_LTE_ZERO":
            return .GRAD_ID_LTE_ZERO
        case "PERS_NOT_SET":
            return .PERS_NOT_SET
        case "REG_KEY_NOT_SET":
            return .REG_KEY_NOT_SET
        case "REG_KEY_INVALID":
            return .REG_KEY_INVALID
        case "NO_OF_REG_KEY_NOT_SET":
            return .NO_OF_REG_KEY_NOT_SET
        case "NO_OF_REG_KEY_LTE_ZERO":
            return .NO_OF_REG_KEY_LTE_ZERO
        case "QTY_PER_REG_KEY_NOT_SET":
            return .QTY_PER_REG_KEY_NOT_SET
        case "QTY_PER_REG_KEY_LTE_ZERO":
            return .QTY_PER_REG_KEY_LTE_ZERO
        case "POI_NOT_SET":
            return .POI_NOT_SET
        case "POI_NAME_NOT_SET":
            return .POI_NAME_NOT_SET
        case "POI_ID_NOT_SET":
            return .POI_ID_NOT_SET
        case "POI_ID_LTE_ZERO":
            return .POI_ID_LTE_ZERO
        case "LAT_OF_POI_NOT_SET":
            return .LAT_OF_POI_NOT_SET
        case "LAT_OF_POI_NAN":
            return .LAT_OF_POI_NAN
        case "LAT_OF_POI_OOR":
            return .LAT_OF_POI_OOR
        case "LON_OF_POI_NOT_SET":
            return .LON_OF_POI_NOT_SET
        case "LON_OF_POI_NAN":
            return .LON_OF_POI_NAN
        case "LON_OF_POI_OOR":
            return .LON_OF_POI_OOR
        case "POI_NAME_TOO_LONG":
            return .POI_NAME_TOO_LONG
        case "POI_DESC_TOO_LONG":
            return .POI_DESC_TOO_LONG
        case "OID_NOT_SET":
            return .OID_NOT_SET
        case "NON_INIT_TRKG_DT":
            return .NON_INIT_TRKG_DT
        case "NON_INIT_TRKG_DT_TS":
            return .NON_INIT_TRKG_DT_TS
        case "NEGATIVE_TRKG_DT_TS":
            return .NEGATIVE_TRKG_DT_TS
        case "IDENTICAL_TRKG_DT_TS":
            return .IDENTICAL_TRKG_DT_TS
        case "LAT_OF_TRKG_DT_NOT_SET":
            return .LAT_OF_TRKG_DT_NOT_SET
        case "LAT_OF_TRKG_DT_OOR":
            return .LAT_OF_TRKG_DT_OOR
        case "LAT_OF_TRKG_DT_NAN":
            return .LAT_OF_TRKG_DT_NAN
        case "LON_OF_TRKG_DT_NOT_SET":
            return .LON_OF_TRKG_DT_NOT_SET
        case "LON_OF_TRKG_DT_OOR":
            return .LON_OF_TRKG_DT_OOR
        case "LON_OF_TRKG_DT_NAN":
            return .LON_OF_TRKG_DT_NAN
        case "NULL_NULL_TRKG_DT_POS":
            return .NULL_NULL_TRKG_DT_POS
        case "NON_INIT_ACC_DT":
            return .NON_INIT_ACC_DT
        case "NON_INIT_ACC_DT_TS":
            return .NON_INIT_ACC_DT_TS
        case "NEGATIVE_ACC_DT_TS":
            return .NEGATIVE_ACC_DT_TS
        case "IDENTICAL_ACC_DT_TS":
            return .IDENTICAL_ACC_DT_TS
        case "NON_INIT_X_ACC_VAL":
            return .NON_INIT_X_ACC_VAL
        case "NON_INIT_Y_ACC_VAL":
            return .NON_INIT_Y_ACC_VAL
        case "NON_INIT_Z_ACC_VAL":
            return .NON_INIT_Z_ACC_VAL
        case "X_ACC_VAL_NAN":
            return .X_ACC_VAL_NAN
        case "Y_ACC_VAL_NAN":
            return .Y_ACC_VAL_NAN
        case "Z_ACC_VAL_NAN":
            return .Z_ACC_VAL_NAN
        default:
            #if DEBUG
                DTODiagnostics.unknownEnumCase(typeAsString, inEnum: "DTOError")
            #endif
            return nil
        }
    }

}
