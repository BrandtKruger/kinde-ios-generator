//
// ManagementClient.swift
//
// Kinde SDK Management API Client
//

import Foundation
import os.log

/// Client for the Kinde Management API
@available(iOS 15.0, *)
public final class ManagementClient {
    private let auth: Auth
    private let logger: LoggerProtocol
    private let baseURL: String
    
    public init(auth: Auth, logger: LoggerProtocol, baseURL: String? = nil) {
        self.auth = auth
        self.logger = logger
        self.baseURL = baseURL ?? "https://api.kinde.com"
    }
    
    // MARK: - Users API
    
    /// Get users with pagination support
    /// - Parameters:
    ///   - pageSize: Number of results per page (default: 10)
    ///   - nextToken: Token to get the next page of results
    ///   - userId: Filter by user ID
    ///   - email: Filter by email address
    ///   - username: Filter by username
    ///   - expand: Specify additional data to retrieve
    ///   - hasOrganization: Filter by users with at least one organization
    /// - Returns: Paginated response with users
    public func getUsers(
        pageSize: Int? = nil,
        nextToken: String? = nil,
        userId: String? = nil,
        email: String? = nil,
        username: String? = nil,
        expand: String? = nil,
        hasOrganization: Bool? = nil
    ) async throws -> PaginatedResponse<ManagementUser> {
        let params = PaginationParams(pageSize: pageSize, nextToken: nextToken)
        return try await performPaginatedRequest(
            endpoint: "/api/v1/users",
            params: params,
            additionalQueryParams: [
                "user_id": userId,
                "email": email,
                "username": username,
                "expand": expand,
                "has_organization": hasOrganization?.description
            ].compactMapValues { $0 },
            responseType: UsersResponse.self
        ) { response in
            PaginatedResponse(
                code: response.code,
                message: response.message,
                items: response.users ?? [],
                nextToken: response.nextToken
            )
        }
    }
    
    /// Get a specific user by ID
    /// - Parameter userId: The user ID
    /// - Returns: The user details
    public func getUser(userId: String) async throws -> ManagementUser {
        let url = "\(baseURL)/api/v1/users/\(userId)"
        let response: ManagementUser = try await performRequest(url: url, method: "GET")
        return response
    }
    
    // MARK: - Organizations API
    
    /// Get organizations with pagination support
    /// - Parameters:
    ///   - pageSize: Number of results per page (default: 10)
    ///   - nextToken: Token to get the next page of results
    ///   - sort: Field and order to sort the result by
    /// - Returns: Paginated response with organizations
    public func getOrganizations(
        pageSize: Int? = nil,
        nextToken: String? = nil,
        sort: String? = nil
    ) async throws -> PaginatedResponse<ManagementOrganization> {
        let params = PaginationParams(pageSize: pageSize, nextToken: nextToken)
        return try await performPaginatedRequest(
            endpoint: "/api/v1/organizations",
            params: params,
            additionalQueryParams: [
                "sort": sort
            ].compactMapValues { $0 },
            responseType: OrganizationsResponse.self
        ) { response in
            PaginatedResponse(
                code: response.code,
                message: response.message,
                items: response.organizations ?? [],
                nextToken: response.nextToken
            )
        }
    }
    
    /// Get a specific organization by code
    /// - Parameter orgCode: The organization code
    /// - Returns: The organization details
    public func getOrganization(orgCode: String) async throws -> ManagementOrganization {
        let url = "\(baseURL)/api/v1/organizations/\(orgCode)"
        let response: ManagementOrganization = try await performRequest(url: url, method: "GET")
        return response
    }
    
    // MARK: - Permissions API
    
    /// Get permissions with pagination support
    /// - Parameters:
    ///   - pageSize: Number of results per page (default: 10)
    ///   - nextToken: Token to get the next page of results
    ///   - sort: Field and order to sort the result by
    /// - Returns: Paginated response with permissions
    public func getPermissions(
        pageSize: Int? = nil,
        nextToken: String? = nil,
        sort: String? = nil
    ) async throws -> PaginatedResponse<ManagementPermission> {
        let params = PaginationParams(pageSize: pageSize, nextToken: nextToken)
        return try await performPaginatedRequest(
            endpoint: "/api/v1/permissions",
            params: params,
            additionalQueryParams: [
                "sort": sort
            ].compactMapValues { $0 },
            responseType: PermissionsResponse.self
        ) { response in
            PaginatedResponse(
                code: response.code,
                message: response.message,
                items: response.permissions ?? [],
                nextToken: response.nextToken
            )
        }
    }
    
    // MARK: - Roles API
    
    /// Get roles with pagination support
    /// - Parameters:
    ///   - pageSize: Number of results per page (default: 10)
    ///   - nextToken: Token to get the next page of results
    ///   - sort: Field and order to sort the result by
    /// - Returns: Paginated response with roles
    public func getRoles(
        pageSize: Int? = nil,
        nextToken: String? = nil,
        sort: String? = nil
    ) async throws -> PaginatedResponse<ManagementRole> {
        let params = PaginationParams(pageSize: pageSize, nextToken: nextToken)
        return try await performPaginatedRequest(
            endpoint: "/api/v1/roles",
            params: params,
            additionalQueryParams: [
                "sort": sort
            ].compactMapValues { $0 },
            responseType: RolesResponse.self
        ) { response in
            PaginatedResponse(
                code: response.code,
                message: response.message,
                items: response.roles ?? [],
                nextToken: response.nextToken
            )
        }
    }
    
    // MARK: - Applications API
    
    /// Get applications with pagination support
    /// - Parameters:
    ///   - pageSize: Number of results per page (default: 10)
    ///   - nextToken: Token to get the next page of results
    ///   - sort: Field and order to sort the result by
    /// - Returns: Paginated response with applications
    public func getApplications(
        pageSize: Int? = nil,
        nextToken: String? = nil,
        sort: String? = nil
    ) async throws -> PaginatedResponse<ManagementApplication> {
        let params = PaginationParams(pageSize: pageSize, nextToken: nextToken)
        return try await performPaginatedRequest(
            endpoint: "/api/v1/applications",
            params: params,
            additionalQueryParams: [
                "sort": sort
            ].compactMapValues { $0 },
            responseType: ApplicationsResponse.self
        ) { response in
            PaginatedResponse(
                code: response.code,
                message: response.message,
                items: response.applications ?? [],
                nextToken: response.nextToken
            )
        }
    }
    
    // MARK: - Pagination Helpers
    
    /// Create a pagination helper for users
    /// - Parameter pageSize: Number of results per page
    /// - Returns: Pagination helper for users
    public func createUsersPaginationHelper(pageSize: Int? = nil) -> PaginationHelper<ManagementUser> {
        return PaginationHelper(pageSize: pageSize) { [weak self] params in
            guard let self = self else {
                throw ManagementError.clientDeallocated
            }
            return try await self.getUsers(
                pageSize: params.pageSize,
                nextToken: params.nextToken
            )
        }
    }
    
    /// Create a pagination helper for organizations
    /// - Parameter pageSize: Number of results per page
    /// - Returns: Pagination helper for organizations
    public func createOrganizationsPaginationHelper(pageSize: Int? = nil) -> PaginationHelper<ManagementOrganization> {
        return PaginationHelper(pageSize: pageSize) { [weak self] params in
            guard let self = self else {
                throw ManagementError.clientDeallocated
            }
            return try await self.getOrganizations(
                pageSize: params.pageSize,
                nextToken: params.nextToken
            )
        }
    }
    
    /// Create a pagination helper for permissions
    /// - Parameter pageSize: Number of results per page
    /// - Returns: Pagination helper for permissions
    public func createPermissionsPaginationHelper(pageSize: Int? = nil) -> PaginationHelper<ManagementPermission> {
        return PaginationHelper(pageSize: pageSize) { [weak self] params in
            guard let self = self else {
                throw ManagementError.clientDeallocated
            }
            return try await self.getPermissions(
                pageSize: params.pageSize,
                nextToken: params.nextToken
            )
        }
    }
    
    /// Create a pagination helper for roles
    /// - Parameter pageSize: Number of results per page
    /// - Returns: Pagination helper for roles
    public func createRolesPaginationHelper(pageSize: Int? = nil) -> PaginationHelper<ManagementRole> {
        return PaginationHelper(pageSize: pageSize) { [weak self] params in
            guard let self = self else {
                throw ManagementError.clientDeallocated
            }
            return try await self.getRoles(
                pageSize: params.pageSize,
                nextToken: params.nextToken
            )
        }
    }
    
    /// Create a pagination helper for applications
    /// - Parameter pageSize: Number of results per page
    /// - Returns: Pagination helper for applications
    public func createApplicationsPaginationHelper(pageSize: Int? = nil) -> PaginationHelper<ManagementApplication> {
        return PaginationHelper(pageSize: pageSize) { [weak self] params in
            guard let self = self else {
                throw ManagementError.clientDeallocated
            }
            return try await self.getApplications(
                pageSize: params.pageSize,
                nextToken: params.nextToken
            )
        }
    }
    
    // MARK: - Private Methods
    
    private func performPaginatedRequest<T: Codable, R: Codable>(
        endpoint: String,
        params: PaginationParams,
        additionalQueryParams: [String: String],
        responseType: R.Type,
        transform: @escaping (R) -> PaginatedResponse<T>
    ) async throws -> PaginatedResponse<T> {
        var queryParams: [String: String] = additionalQueryParams
        
        if let pageSize = params.pageSize {
            queryParams["page_size"] = String(pageSize)
        }
        
        if let nextToken = params.nextToken {
            queryParams["next_token"] = nextToken
        }
        
        let url = buildURL(endpoint: endpoint, queryParams: queryParams)
        let response: R = try await performRequest(url: url, method: "GET")
        return transform(response)
    }
    
    private func performRequest<T: Codable>(url: String, method: String) async throws -> T {
        guard let url = URL(string: url) else {
            throw ManagementError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add authorization header
        let token = try await auth.getToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ManagementError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw ManagementError.httpError(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error(message: "Failed to decode response: \(error.localizedDescription)")
            throw ManagementError.decodingError(error)
        }
    }
    
    private func buildURL(endpoint: String, queryParams: [String: String]) -> String {
        var url = "\(baseURL)\(endpoint)"
        
        if !queryParams.isEmpty {
            let queryItems = queryParams.map { "\($0.key)=\($0.value)" }
            url += "?" + queryItems.joined(separator: "&")
        }
        
        return url
    }
}

// MARK: - Management Errors

public enum ManagementError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingError(Error)
    case clientDeallocated
    case notAuthenticated
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .clientDeallocated:
            return "Management client was deallocated"
        case .notAuthenticated:
            return "User not authenticated"
        }
    }
}
