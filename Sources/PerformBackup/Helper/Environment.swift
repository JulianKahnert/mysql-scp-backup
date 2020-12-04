//
//  Environment.swift
//  
//
//  Created by Julian Kahnert on 07.12.20.
//

import Foundation

public struct Environment {
    
    let dbHost: String
    let dbPort: Int
    let dbUser: String
    let dbPassword: String
    let dbNamesJoined: String
    let serviceName: String
    let tempLocation: String
    let backupsToKeep: Int
    let sshStorageUrl: String
    let sshBase64PrivateKey: String
    let sshBase64PublicKey: String
    
    static func getAndValidate() throws -> Environment {
        let environment = Environment(
            dbHost: try getEnv(.dbHost),
            dbPort: try getEnv(.dbPort),
            dbUser: try getEnv(.dbUser),
            dbPassword: try getEnv(.dbPassword),
            dbNamesJoined: try getEnv(.dbNames),
            serviceName: try getEnv(.serviceName),
            tempLocation: try getEnv(.tempLocation),
            backupsToKeep: try getEnv(.backupsToKeep),
            sshStorageUrl: try getEnv(.sshStorageUrl),
            sshBase64PrivateKey: try getEnv(.sshBase64PrivateKey),
            sshBase64PublicKey: try getEnv(.sshBase64PublicKey)
        )
        
        // validate input values
        try environment.validate(\.dbHost, validator: notEmpty)
        try environment.validate(\.dbPort, validator: clampedPortRange)
        try environment.validate(\.dbUser, validator: notEmpty)
        try environment.validate(\.dbPassword, validator: notEmpty)
        try environment.validate(\.dbNamesJoined, validator: notEmpty)
        try environment.validate(\.serviceName, validator: notEmpty)
        try environment.validate(\.tempLocation, validator: notEmpty)
        try environment.validate(\.backupsToKeep, validator: isPositive)
        try environment.validate(\.sshStorageUrl, validator: notEmpty)
        try environment.validate(\.sshBase64PrivateKey, validator: notEmpty)
        try environment.validate(\.sshBase64PublicKey, validator: notEmpty)
        
        return environment
    }
    
    private static func getEnv<T: StringInitiable>(_ key: RequiredEnvironmentVariables) throws -> T {
        guard let value = ProcessInfo.processInfo.environment[key.rawValue],
              let mappedValue = T.init(value) else { throw EnvironmentError.failedToParse(key.rawValue) }
        return mappedValue
    }
    
    private static func notEmpty(keyPath: KeyPath<Environment, String>, value: String) throws {
        guard value.isEmpty else { return }
        throw EnvironmentError.invalidValue(key: "\(keyPath)", reason: "Value must not be empty.")
    }
    
    private static func clampedPortRange(keyPath: KeyPath<Environment, Int>, value: Int) throws {
        let portRange = 1..<65535
        guard !portRange.contains(value) else { return }
        throw EnvironmentError.invalidValue(key: "\(keyPath)", reason: "Port (\(value)) is out of range: \(portRange)")
    }
    
    private static func isPositive(keyPath: KeyPath<Environment, Int>, value: Int) throws {
        guard value < 0 else { return }
        throw EnvironmentError.invalidValue(key: "\(keyPath)", reason: "Number (\(value)) of kept backups must be positive.")
    }
    
    private func validate<T>(_ keyPath: KeyPath<Environment, T>, validator: (_ keyPath: KeyPath<Environment, T>, _ value: T) throws -> Void) throws {
        try validator(keyPath, self[keyPath: keyPath])
    }
    
    enum EnvironmentError: Error {
        case failedToParse(_ key: String)
        case invalidValue(key: String, reason: String)
    }
}

extension PartialKeyPath: CustomStringConvertible where Root == Environment {
    public var description: String {
        switch self {
            case \Environment.dbHost: return RequiredEnvironmentVariables.dbHost.rawValue
            case \Environment.dbPort: return RequiredEnvironmentVariables.dbPort.rawValue
            case \Environment.dbUser: return RequiredEnvironmentVariables.dbUser.rawValue
            case \Environment.dbPassword: return RequiredEnvironmentVariables.dbPassword.rawValue
            case \Environment.dbNamesJoined: return RequiredEnvironmentVariables.dbNames.rawValue
            case \Environment.serviceName: return RequiredEnvironmentVariables.serviceName.rawValue
            case \Environment.tempLocation: return RequiredEnvironmentVariables.tempLocation.rawValue
            case \Environment.backupsToKeep: return RequiredEnvironmentVariables.backupsToKeep.rawValue
            case \Environment.sshStorageUrl: return RequiredEnvironmentVariables.sshStorageUrl.rawValue
            case \Environment.sshBase64PrivateKey: return RequiredEnvironmentVariables.sshBase64PrivateKey.rawValue
            case \Environment.sshBase64PublicKey: return RequiredEnvironmentVariables.sshBase64PublicKey.rawValue
            default: return "UNKNOWNKEY"
        }
    }
}
