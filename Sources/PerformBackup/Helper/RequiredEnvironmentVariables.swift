//
//  RequiredEnvironmentVariables.swift
//  
//
//  Created by Julian Kahnert on 07.12.20.
//

enum RequiredEnvironmentVariables: String, CaseIterable {
    case dbHost = "DB_HOST"
    case dbPort = "DB_PORT"
    case dbUser = "DB_USER"
    case dbPassword = "DB_PASSWORD"
    case dbNames = "DB_NAMES"

    case serviceName = "SERVICE_NAME"
    case tempLocation = "TEMP_LOCATION"

    case backupsToKeep = "BACKUPS_TO_KEEP"

    case sshStorageUrl = "SSH_STORAGE_URL"
    case sshBase64PrivateKey = "SSH_BASE64_PRIVATE_KEY"
    case sshBase64PublicKey = "SSH_BASE64_PUBLIC_KEY"
}
