//
// ManagementModels.swift
//
// Kinde SDK Management API Models
//

import Foundation

// MARK: - User Models

/// User model for Management API
public struct ManagementUser: Codable, Identifiable {
    public let id: String
    public let email: String?
    public let firstName: String?
    public let lastName: String?
    public let fullName: String?
    public let isSuspended: Bool?
    public let picture: String?
    public let isPasswordResetRequested: Bool?
    public let createdOn: String?
    public let updatedOn: String?
    
    public init(id: String, email: String? = nil, firstName: String? = nil, lastName: String? = nil, fullName: String? = nil, isSuspended: Bool? = nil, picture: String? = nil, isPasswordResetRequested: Bool? = nil, createdOn: String? = nil, updatedOn: String? = nil) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.fullName = fullName
        self.isSuspended = isSuspended
        self.picture = picture
        self.isPasswordResetRequested = isPasswordResetRequested
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case firstName = "first_name"
        case lastName = "last_name"
        case fullName = "full_name"
        case isSuspended = "is_suspended"
        case picture
        case isPasswordResetRequested = "is_password_reset_requested"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
}

// MARK: - Organization Models

/// Organization model for Management API
public struct ManagementOrganization: Codable, Identifiable {
    public let id: String
    public let code: String
    public let name: String?
    public let isDefault: Bool?
    public let externalId: String?
    public let createdOn: String?
    public let updatedOn: String?
    
    public init(id: String, code: String, name: String? = nil, isDefault: Bool? = nil, externalId: String? = nil, createdOn: String? = nil, updatedOn: String? = nil) {
        self.id = id
        self.code = code
        self.name = name
        self.isDefault = isDefault
        self.externalId = externalId
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case code
        case name
        case isDefault = "is_default"
        case externalId = "external_id"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
}

// MARK: - Permission Models

/// Permission model for Management API
public struct ManagementPermission: Codable, Identifiable {
    public let id: String
    public let key: String
    public let name: String?
    public let description: String?
    public let category: String?
    public let createdOn: String?
    public let updatedOn: String?
    
    public init(id: String, key: String, name: String? = nil, description: String? = nil, category: String? = nil, createdOn: String? = nil, updatedOn: String? = nil) {
        self.id = id
        self.key = key
        self.name = name
        self.description = description
        self.category = category
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case description
        case category
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
}

// MARK: - Role Models

/// Role model for Management API
public struct ManagementRole: Codable, Identifiable {
    public let id: String
    public let key: String
    public let name: String?
    public let description: String?
    public let createdOn: String?
    public let updatedOn: String?
    
    public init(id: String, key: String, name: String? = nil, description: String? = nil, createdOn: String? = nil, updatedOn: String? = nil) {
        self.id = id
        self.key = key
        self.name = name
        self.description = description
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case key
        case name
        case description
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
}

// MARK: - Application Models

/// Application model for Management API
public struct ManagementApplication: Codable, Identifiable {
    public let id: String
    public let name: String?
    public let type: String?
    public let isActive: Bool?
    public let createdOn: String?
    public let updatedOn: String?
    
    public init(id: String, name: String? = nil, type: String? = nil, isActive: Bool? = nil, createdOn: String? = nil, updatedOn: String? = nil) {
        self.id = id
        self.name = name
        self.type = type
        self.isActive = isActive
        self.createdOn = createdOn
        self.updatedOn = updatedOn
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case isActive = "is_active"
        case createdOn = "created_on"
        case updatedOn = "updated_on"
    }
}

// MARK: - API Response Models

/// Users API response
public struct UsersResponse: Codable {
    public let code: String?
    public let message: String?
    public let users: [ManagementUser]?
    public let nextToken: String?
    
    public init(code: String? = nil, message: String? = nil, users: [ManagementUser]? = nil, nextToken: String? = nil) {
        self.code = code
        self.message = message
        self.users = users
        self.nextToken = nextToken
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case users
        case nextToken = "next_token"
    }
}

/// Organizations API response
public struct OrganizationsResponse: Codable {
    public let code: String?
    public let message: String?
    public let organizations: [ManagementOrganization]?
    public let nextToken: String?
    
    public init(code: String? = nil, message: String? = nil, organizations: [ManagementOrganization]? = nil, nextToken: String? = nil) {
        self.code = code
        self.message = message
        self.organizations = organizations
        self.nextToken = nextToken
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case organizations
        case nextToken = "next_token"
    }
}

/// Permissions API response
public struct PermissionsResponse: Codable {
    public let code: String?
    public let message: String?
    public let permissions: [ManagementPermission]?
    public let nextToken: String?
    
    public init(code: String? = nil, message: String? = nil, permissions: [ManagementPermission]? = nil, nextToken: String? = nil) {
        self.code = code
        self.message = message
        self.permissions = permissions
        self.nextToken = nextToken
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case permissions
        case nextToken = "next_token"
    }
}

/// Roles API response
public struct RolesResponse: Codable {
    public let code: String?
    public let message: String?
    public let roles: [ManagementRole]?
    public let nextToken: String?
    
    public init(code: String? = nil, message: String? = nil, roles: [ManagementRole]? = nil, nextToken: String? = nil) {
        self.code = code
        self.message = message
        self.roles = roles
        self.nextToken = nextToken
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case roles
        case nextToken = "next_token"
    }
}

/// Applications API response
public struct ApplicationsResponse: Codable {
    public let code: String?
    public let message: String?
    public let applications: [ManagementApplication]?
    public let nextToken: String?
    
    public init(code: String? = nil, message: String? = nil, applications: [ManagementApplication]? = nil, nextToken: String? = nil) {
        self.code = code
        self.message = message
        self.applications = applications
        self.nextToken = nextToken
    }
    
    enum CodingKeys: String, CodingKey {
        case code
        case message
        case applications
        case nextToken = "next_token"
    }
}
