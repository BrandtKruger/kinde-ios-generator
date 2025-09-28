//
// Claims.swift
//
// Kinde SDK Claims Model
//

import Foundation

/// Represents a claim from a JWT token
public struct Claim {
    /// The name of the claim
    public let name: String
    /// The value of the claim
    public let value: Any?
    
    public init(name: String, value: Any?) {
        self.name = name
        self.value = value
    }
}

/// Represents all claims from a token
public struct Claims {
    /// Dictionary of all claims
    public let claims: [String: Any]
    
    public init(claims: [String: Any]) {
        self.claims = claims
    }
    
    /// Get a specific claim by name
    /// - Parameter name: The name of the claim to retrieve
    /// - Returns: A Claim object with the name and value, or nil if not found
    public func getClaim(name: String) -> Claim? {
        guard let value = claims[name] else {
            return nil
        }
        return Claim(name: name, value: value)
    }
    
    /// Get all claim names
    /// - Returns: Array of claim names
    public func getClaimNames() -> [String] {
        return Array(claims.keys)
    }
    
    /// Check if a claim exists
    /// - Parameter name: The name of the claim to check
    /// - Returns: True if the claim exists, false otherwise
    public func hasClaim(name: String) -> Bool {
        return claims[name] != nil
    }
    
    /// Get the count of claims
    /// - Returns: Number of claims
    public var count: Int {
        return claims.count
    }
}

/// Common claim keys used in Kinde tokens
public enum ClaimKey: String, CaseIterable {
    // Standard JWT claims
    case audience = "aud"
    case issuer = "iss"
    case subject = "sub"
    case expiration = "exp"
    case issuedAt = "iat"
    case notBefore = "nbf"
    
    // User information (typically in ID token)
    case email = "email"
    case givenName = "given_name"
    case familyName = "family_name"
    case name = "name"
    case picture = "picture"
    case emailVerified = "email_verified"
    
    // Organization information
    case organizationCode = "org_code"
    case organizationName = "org_name"
    case organizationId = "org_id"
    case organizationCodes = "org_codes"
    
    // Permissions and roles
    case permissions = "permissions"
    case roles = "roles"
    
    // Feature flags
    case featureFlags = "feature_flags"
    
    // Custom claims (prefixed with custom:)
    case customRole = "custom:role"
    case customPreferences = "custom:preferences"
    case customSettings = "custom:settings"
}

// MARK: - Claims Service

import Foundation
import os.log

/// The Kinde claims service for accessing user claims from tokens
public final class ClaimsService {
    private unowned let auth: Auth
    private let logger: LoggerProtocol
    
    init(auth: Auth, logger: LoggerProtocol) {
        self.auth = auth
        self.logger = logger
    }
    
    /// Get a specific claim from the user's tokens
    /// - Parameters:
    ///   - claimName: The name of the claim to retrieve (e.g. "aud", "given_name")
    ///   - tokenType: The type of token to get the claim from (accessToken or idToken)
    /// - Returns: A Claim object containing the claim name and value, or nil if not found
    public func getClaim(claimName: String, tokenType: TokenType = .accessToken) -> Claim? {
        guard auth.isAuthenticated() else {
            logger.debug(message: "User not authenticated, cannot retrieve claim: \(claimName)")
            return nil
        }
        
        // Validate claim name - hard check
        guard !claimName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger.error(message: "Invalid claim name: claim name cannot be empty or whitespace")
            return nil
        }
        
        // Validate token type - hard check like Python SDK
        let validTokenTypes: [TokenType] = [.accessToken, .idToken]
        guard validTokenTypes.contains(tokenType) else {
            logger.error(message: "Invalid token_type '\(tokenType.rawValue)'. Valid types are: \(validTokenTypes.map { $0.rawValue })")
            return nil
        }
        
        // Use the existing getClaim method from Auth
        return auth.getClaim(forKey: claimName, token: tokenType)
    }
    
    /// Get all claims from the user's tokens
    /// - Parameter tokenType: The type of token to get claims from (accessToken or idToken)
    /// - Returns: A Claims object containing all claims from the token, or empty claims if not available
    public func getAllClaims(tokenType: TokenType = .accessToken) -> Claims {
        guard auth.isAuthenticated() else {
            logger.debug(message: "User not authenticated, cannot retrieve claims")
            return Claims(claims: [:])
        }
        
        // Validate token type - hard check like Python SDK
        let validTokenTypes: [TokenType] = [.accessToken, .idToken]
        guard validTokenTypes.contains(tokenType) else {
            logger.error(message: "Invalid token_type '\(tokenType.rawValue)'. Valid types are: \(validTokenTypes.map { $0.rawValue })")
            return Claims(claims: [:])
        }
        
        let lastTokenResponse = auth.getTokenResponse()
        let tokenToParse = tokenType == .accessToken ? lastTokenResponse?.accessToken : lastTokenResponse?.idToken
        
        guard let token = tokenToParse else {
            logger.error(message: "No token available for token type: \(tokenType.rawValue)")
            return Claims(claims: [:])
        }
        
        let parsedJWT = token.parsedJWT
        
        // Hard check: Warn if no claims are available - like Python SDK
        if parsedJWT.isEmpty {
            logger.error(message: "No claims available for token type: \(tokenType.rawValue)")
        }
        
        return Claims(claims: parsedJWT as [String: Any])
    }
    
    /// Get a claim using a predefined claim key
    /// - Parameters:
    ///   - claimKey: The predefined claim key to retrieve
    ///   - tokenType: The type of token to get the claim from
    /// - Returns: A Claim object containing the claim name and value, or nil if not found
    public func getClaim(claimKey: ClaimKey, tokenType: TokenType = .accessToken) -> Claim? {
        return getClaim(claimName: claimKey.rawValue, tokenType: tokenType)
    }
    
    /// Get user information claims from the ID token
    /// - Returns: A dictionary containing user information claims
    public func getUserInfo() -> [String: Any] {
        let idTokenClaims = getAllClaims(tokenType: .idToken)
        let userInfoKeys: [ClaimKey] = [.email, .givenName, .familyName, .name, .picture, .emailVerified]
        
        var userInfo: [String: Any] = [:]
        for key in userInfoKeys {
            if let claim = idTokenClaims.getClaim(name: key.rawValue) {
                userInfo[key.rawValue] = claim.value
            }
        }
        
        return userInfo
    }
    
    /// Get organization information claims
    /// - Returns: A dictionary containing organization information claims
    public func getOrganizationInfo() -> [String: Any] {
        let accessTokenClaims = getAllClaims(tokenType: .accessToken)
        let orgKeys: [ClaimKey] = [.organizationCode, .organizationName, .organizationId, .organizationCodes]
        
        var orgInfo: [String: Any] = [:]
        for key in orgKeys {
            if let claim = accessTokenClaims.getClaim(name: key.rawValue) {
                orgInfo[key.rawValue] = claim.value
            }
        }
        
        return orgInfo
    }
    
    /// Get token validation claims (audience, issuer, expiration, etc.)
    /// - Returns: A dictionary containing token validation claims
    public func getTokenValidationInfo() -> [String: Any] {
        let accessTokenClaims = getAllClaims(tokenType: .accessToken)
        let validationKeys: [ClaimKey] = [.audience, .issuer, .subject, .expiration, .issuedAt, .notBefore]
        
        var validationInfo: [String: Any] = [:]
        for key in validationKeys {
            if let claim = accessTokenClaims.getClaim(name: key.rawValue) {
                validationInfo[key.rawValue] = claim.value
            }
        }
        
        return validationInfo
    }
    
    /// Check if a specific claim exists
    /// - Parameters:
    ///   - claimName: The name of the claim to check
    ///   - tokenType: The type of token to check
    /// - Returns: True if the claim exists, false otherwise
    public func hasClaim(claimName: String, tokenType: TokenType = .accessToken) -> Bool {
        // Validate claim name - hard check
        guard !claimName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger.error(message: "Invalid claim name: claim name cannot be empty or whitespace")
            return false
        }
        
        // Validate token type - hard check like Python SDK
        let validTokenTypes: [TokenType] = [.accessToken, .idToken]
        guard validTokenTypes.contains(tokenType) else {
            logger.error(message: "Invalid token_type '\(tokenType.rawValue)'. Valid types are: \(validTokenTypes.map { $0.rawValue })")
            return false
        }
        
        return getClaim(claimName: claimName, tokenType: tokenType) != nil
    }
    
    /// Check if a specific claim exists using a predefined claim key
    /// - Parameters:
    ///   - claimKey: The predefined claim key to check
    ///   - tokenType: The type of token to check
    /// - Returns: True if the claim exists, false otherwise
    public func hasClaim(claimKey: ClaimKey, tokenType: TokenType = .accessToken) -> Bool {
        return hasClaim(claimName: claimKey.rawValue, tokenType: tokenType)
    }
    
    /// Get custom claims (claims prefixed with "custom:")
    /// - Returns: A dictionary containing all custom claims
    public func getCustomClaims() -> [String: Any] {
        let accessTokenClaims = getAllClaims(tokenType: .accessToken)
        var customClaims: [String: Any] = [:]
        
        for (key, value) in accessTokenClaims.claims {
            if key.hasPrefix("custom:") {
                customClaims[key] = value
            }
        }
        
        return customClaims
    }
    
    /// Get a specific custom claim
    /// - Parameter claimName: The name of the custom claim (with or without "custom:" prefix)
    /// - Returns: A Claim object containing the claim name and value, or nil if not found
    public func getCustomClaim(claimName: String) -> Claim? {
        // Validate claim name - hard check
        guard !claimName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            logger.error(message: "Invalid custom claim name: claim name cannot be empty or whitespace")
            return nil
        }
        
        let fullClaimName = claimName.hasPrefix("custom:") ? claimName : "custom:\(claimName)"
        return getClaim(claimName: fullClaimName, tokenType: .accessToken)
    }
}

// MARK: - Convenience Methods
extension ClaimsService {
    
    /// Get the user's email from the ID token
    /// - Returns: The user's email address, or nil if not available
    public func getEmail() -> String? {
        return getClaim(claimKey: .email, tokenType: .idToken)?.value as? String
    }
    
    /// Get the user's given name from the ID token
    /// - Returns: The user's given name, or nil if not available
    public func getGivenName() -> String? {
        return getClaim(claimKey: .givenName, tokenType: .idToken)?.value as? String
    }
    
    /// Get the user's family name from the ID token
    /// - Returns: The user's family name, or nil if not available
    public func getFamilyName() -> String? {
        return getClaim(claimKey: .familyName, tokenType: .idToken)?.value as? String
    }
    
    /// Get the user's full name from the ID token
    /// - Returns: The user's full name, or nil if not available
    public func getFullName() -> String? {
        return getClaim(claimKey: .name, tokenType: .idToken)?.value as? String
    }
    
    /// Get the user's picture URL from the ID token
    /// - Returns: The user's picture URL, or nil if not available
    public func getPicture() -> String? {
        return getClaim(claimKey: .picture, tokenType: .idToken)?.value as? String
    }
    
    /// Get the organization code from the access token
    /// - Returns: The organization code, or nil if not available
    public func getOrganizationCode() -> String? {
        return getClaim(claimKey: .organizationCode, tokenType: .accessToken)?.value as? String
    }
    
    /// Get the organization name from the access token
    /// - Returns: The organization name, or nil if not available
    public func getOrganizationName() -> String? {
        return getClaim(claimKey: .organizationName, tokenType: .accessToken)?.value as? String
    }
    
    /// Get the token audience from the access token
    /// - Returns: The token audience, or nil if not available
    public func getAudience() -> [String]? {
        return getClaim(claimKey: .audience, tokenType: .accessToken)?.value as? [String]
    }
    
    /// Get the token issuer from the access token
    /// - Returns: The token issuer, or nil if not available
    public func getIssuer() -> String? {
        return getClaim(claimKey: .issuer, tokenType: .accessToken)?.value as? String
    }
    
    /// Get the token expiration time from the access token
    /// - Returns: The token expiration time as a Date, or nil if not available
    public func getExpirationTime() -> Date? {
        guard let expValue = getClaim(claimKey: .expiration, tokenType: .accessToken)?.value else {
            return nil
        }
        
        if let expTimestamp = expValue as? TimeInterval {
            return Date(timeIntervalSince1970: expTimestamp)
        } else if let expTimestamp = expValue as? Int {
            return Date(timeIntervalSince1970: TimeInterval(expTimestamp))
        }
        
        return nil
    }
    
    /// Check if the token is expired
    /// - Returns: True if the token is expired, false otherwise
    public func isTokenExpired() -> Bool {
        guard let expirationTime = getExpirationTime() else {
            return true // If we can't determine expiration, assume it's expired
        }
        return Date() > expirationTime
    }
}
