//
//  Animal.swift
//  conradkiosk
//
//  Automatically created by SwiftDTO.
//  Copyright (c) 2016 Farbflash. All rights reserved.

// DO NOT EDIT THIS FILE!
// This file was automatically generated from a xcmodel file (CoreData XML Scheme)
// Edit the source coredata model (in the CoreData editor) and then use the SwiftDTO
// to create the corresponding DTO source files automatically

import Foundation

public protocol Animal: DictionaryConvertible {
	var name: String? { get }
	var animalType: AnimalType? { get }
}

extension Animal {
	static func createWith(jsonData json: JSOBJ) -> Animal? {
		if let enumValue = json["animalType"] as? String,
			let enumProp = AnimalType(rawValue: enumValue) {
			return enumProp.conditionalInstance(withJSON: json)
		}
		else {
			return nil
		}
	}
}