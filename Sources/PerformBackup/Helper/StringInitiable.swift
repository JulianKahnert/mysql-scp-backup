//
//  StringInitiable.swift
//  
//
//  Created by Julian Kahnert on 07.12.20.
//

protocol StringInitiable {
    init?(_ value: String)
}
extension String: StringInitiable {}
extension Int: StringInitiable {}
