import XCTest
@testable import KindeSDK

final class ManagementPaginationSpec: XCTestCase {
    
    var auth: Auth!
    var management: ManagementClient!
    var mockAuthStateRepository: MockAuthStateRepository!
    var mockLogger: MockLogger!
    
    override func setUp() {
        super.setUp()
        mockAuthStateRepository = MockAuthStateRepository()
        mockLogger = MockLogger()
        
        let config = Config(
            clientId: "test_client_id",
            domain: "test.kinde.com",
            redirectUrl: URL(string: "https://test.com/callback")!,
            logoutRedirectUrl: URL(string: "https://test.com/logout")!,
            scope: "openid profile email"
        )
        
        auth = Auth(config: config, authStateRepository: mockAuthStateRepository, logger: mockLogger)
        management = auth.management
    }
    
    override func tearDown() {
        auth = nil
        management = nil
        mockAuthStateRepository = nil
        mockLogger = nil
        super.tearDown()
    }
    
    // MARK: - Test Pagination Models
    
    func testPaginationParams() {
        let params = PaginationParams(pageSize: 20, nextToken: "next_token_123")
        XCTAssertEqual(params.pageSize, 20)
        XCTAssertEqual(params.nextToken, "next_token_123")
    }
    
    func testPaginatedResponse() {
        let users = [
            ManagementUser(id: "1", email: "user1@test.com"),
            ManagementUser(id: "2", email: "user2@test.com")
        ]
        
        let response = PaginatedResponse(
            code: "200",
            message: "Success",
            items: users,
            nextToken: "next_token_456"
        )
        
        XCTAssertEqual(response.code, "200")
        XCTAssertEqual(response.message, "Success")
        XCTAssertEqual(response.items.count, 2)
        XCTAssertEqual(response.nextToken, "next_token_456")
        XCTAssertTrue(response.hasNextPage)
    }
    
    func testPaginatedResponseNoNextPage() {
        let users = [ManagementUser(id: "1", email: "user1@test.com")]
        
        let response = PaginatedResponse(
            code: "200",
            message: "Success",
            items: users,
            nextToken: nil
        )
        
        XCTAssertFalse(response.hasNextPage)
    }
    
    // MARK: - Test PaginationHelper
    
    func testPaginationHelper() {
        var callCount = 0
        let helper = PaginationHelper<ManagementUser>(pageSize: 5) { params in
            callCount += 1
            
            if callCount == 1 {
                // First page
                XCTAssertNil(params.nextToken)
                XCTAssertEqual(params.pageSize, 5)
                return PaginatedResponse(
                    items: [ManagementUser(id: "1", email: "user1@test.com")],
                    nextToken: "token_2"
                )
            } else if callCount == 2 {
                // Second page
                XCTAssertEqual(params.nextToken, "token_2")
                return PaginatedResponse(
                    items: [ManagementUser(id: "2", email: "user2@test.com")],
                    nextToken: nil
                )
            } else {
                XCTFail("Unexpected call")
                return PaginatedResponse(items: [], nextToken: nil)
            }
        }
        
        // Test first page
        let firstPage = try await helper.getFirstPage()
        XCTAssertEqual(firstPage.items.count, 1)
        XCTAssertEqual(firstPage.items.first?.id, "1")
        XCTAssertTrue(helper.hasNextPage)
        
        // Test second page
        let secondPage = try await helper.getNextPage()
        XCTAssertNotNil(secondPage)
        XCTAssertEqual(secondPage?.items.count, 1)
        XCTAssertEqual(secondPage?.items.first?.id, "2")
        XCTAssertFalse(helper.hasNextPage)
        
        // Test no more pages
        let thirdPage = try await helper.getNextPage()
        XCTAssertNil(thirdPage)
        
        XCTAssertEqual(callCount, 2)
    }
    
    func testPaginationHelperGetAllPages() {
        var callCount = 0
        let helper = PaginationHelper<ManagementUser>(pageSize: 2) { params in
            callCount += 1
            
            if callCount == 1 {
                return PaginatedResponse(
                    items: [
                        ManagementUser(id: "1", email: "user1@test.com"),
                        ManagementUser(id: "2", email: "user2@test.com")
                    ],
                    nextToken: "token_2"
                )
            } else if callCount == 2 {
                return PaginatedResponse(
                    items: [
                        ManagementUser(id: "3", email: "user3@test.com")
                    ],
                    nextToken: nil
                )
            } else {
                XCTFail("Unexpected call")
                return PaginatedResponse(items: [], nextToken: nil)
            }
        }
        
        let allUsers = try await helper.getAllPages()
        XCTAssertEqual(allUsers.count, 3)
        XCTAssertEqual(allUsers[0].id, "1")
        XCTAssertEqual(allUsers[1].id, "2")
        XCTAssertEqual(allUsers[2].id, "3")
        XCTAssertEqual(callCount, 2)
    }
    
    func testPaginationHelperReset() {
        let helper = PaginationHelper<ManagementUser> { params in
            if params.nextToken == nil {
                return PaginatedResponse(
                    items: [ManagementUser(id: "1", email: "user1@test.com")],
                    nextToken: "token_2"
                )
            } else {
                return PaginatedResponse(
                    items: [ManagementUser(id: "2", email: "user2@test.com")],
                    nextToken: nil
                )
            }
        }
        
        // Get first page
        _ = try await helper.getFirstPage()
        XCTAssertTrue(helper.hasNextPage)
        
        // Reset
        helper.reset()
        XCTAssertFalse(helper.hasNextPage)
        
        // Get first page again
        _ = try await helper.getFirstPage()
        XCTAssertTrue(helper.hasNextPage)
    }
    
    // MARK: - Test Management Models
    
    func testManagementUser() {
        let user = ManagementUser(
            id: "123",
            email: "test@example.com",
            firstName: "John",
            lastName: "Doe",
            fullName: "John Doe",
            isSuspended: false,
            picture: "https://example.com/picture.jpg"
        )
        
        XCTAssertEqual(user.id, "123")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.firstName, "John")
        XCTAssertEqual(user.lastName, "Doe")
        XCTAssertEqual(user.fullName, "John Doe")
        XCTAssertEqual(user.isSuspended, false)
        XCTAssertEqual(user.picture, "https://example.com/picture.jpg")
    }
    
    func testManagementOrganization() {
        let org = ManagementOrganization(
            id: "456",
            code: "org_123",
            name: "Test Organization",
            isDefault: true
        )
        
        XCTAssertEqual(org.id, "456")
        XCTAssertEqual(org.code, "org_123")
        XCTAssertEqual(org.name, "Test Organization")
        XCTAssertEqual(org.isDefault, true)
    }
    
    func testManagementPermission() {
        let permission = ManagementPermission(
            id: "789",
            key: "read:users",
            name: "Read Users",
            description: "Permission to read user data"
        )
        
        XCTAssertEqual(permission.id, "789")
        XCTAssertEqual(permission.key, "read:users")
        XCTAssertEqual(permission.name, "Read Users")
        XCTAssertEqual(permission.description, "Permission to read user data")
    }
    
    func testManagementRole() {
        let role = ManagementRole(
            id: "101",
            key: "admin",
            name: "Administrator",
            description: "Full administrative access"
        )
        
        XCTAssertEqual(role.id, "101")
        XCTAssertEqual(role.key, "admin")
        XCTAssertEqual(role.name, "Administrator")
        XCTAssertEqual(role.description, "Full administrative access")
    }
    
    func testManagementApplication() {
        let app = ManagementApplication(
            id: "202",
            name: "Test App",
            type: "web",
            isActive: true
        )
        
        XCTAssertEqual(app.id, "202")
        XCTAssertEqual(app.name, "Test App")
        XCTAssertEqual(app.type, "web")
        XCTAssertEqual(app.isActive, true)
    }
    
    // MARK: - Test Management Errors
    
    func testManagementErrors() {
        let errors: [ManagementError] = [
            .invalidURL,
            .invalidResponse,
            .httpError(404),
            .decodingError(NSError(domain: "test", code: 1)),
            .clientDeallocated,
            .notAuthenticated
        ]
        
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertFalse(error.errorDescription!.isEmpty)
        }
    }
    
    // MARK: - Test Management Client Creation
    
    func testManagementClientCreation() {
        XCTAssertNotNil(management)
        XCTAssertEqual(management.auth, auth)
    }
    
    func testPaginationHelperCreation() {
        let usersHelper = management.createUsersPaginationHelper(pageSize: 10)
        XCTAssertNotNil(usersHelper)
        
        let orgsHelper = management.createOrganizationsPaginationHelper(pageSize: 20)
        XCTAssertNotNil(orgsHelper)
        
        let permsHelper = management.createPermissionsPaginationHelper()
        XCTAssertNotNil(permsHelper)
        
        let rolesHelper = management.createRolesPaginationHelper()
        XCTAssertNotNil(rolesHelper)
        
        let appsHelper = management.createApplicationsPaginationHelper()
        XCTAssertNotNil(appsHelper)
    }
}

// MARK: - Mock Classes (reusing from ClaimsSpec)

class MockAuthStateRepository: AuthStateRepository {
    var mockState: OIDAuthState?
    
    override var state: OIDAuthState? {
        return mockState
    }
    
    func setupMockState(accessTokenClaims: [String: Any], idTokenClaims: [String: Any]) {
        let mockTokenResponse = MockTokenResponse(
            accessTokenClaims: accessTokenClaims,
            idTokenClaims: idTokenClaims
        )
        
        let mockAuthState = MockAuthState(tokenResponse: mockTokenResponse)
        mockState = mockAuthState
    }
}

class MockAuthState: OIDAuthState {
    private let mockTokenResponse: MockTokenResponse
    
    init(tokenResponse: MockTokenResponse) {
        self.mockTokenResponse = tokenResponse
        super.init()
    }
    
    override var isAuthorized: Bool {
        return true
    }
    
    override var lastTokenResponse: OIDTokenResponse? {
        return mockTokenResponse
    }
}

class MockTokenResponse: OIDTokenResponse {
    private let accessTokenClaims: [String: Any]
    private let idTokenClaims: [String: Any]
    
    init(accessTokenClaims: [String: Any], idTokenClaims: [String: Any]) {
        self.accessTokenClaims = accessTokenClaims
        self.idTokenClaims = idTokenClaims
        super.init()
    }
    
    override var accessToken: String? {
        return "mock_access_token"
    }
    
    override var idToken: String? {
        return "mock_id_token"
    }
    
    override var accessTokenExpirationDate: Date? {
        return Date().addingTimeInterval(3600)
    }
}

extension String {
    var parsedJWT: [String: Any] {
        if self == "mock_access_token" {
            return [
                "aud": ["api.yourapp.com"],
                "iss": "https://test.kinde.com",
                "sub": "user_123",
                "exp": Date().addingTimeInterval(3600).timeIntervalSince1970,
                "iat": Date().timeIntervalSince1970,
                "org_code": "org_123",
                "org_name": "Test Organization",
                "custom:role": "admin"
            ]
        } else if self == "mock_id_token" {
            return [
                "sub": "user_123",
                "email": "john.doe@example.com",
                "given_name": "John",
                "family_name": "Doe",
                "name": "John Doe",
                "picture": "https://example.com/picture.jpg",
                "email_verified": true
            ]
        }
        return [:]
    }
}

class MockLogger: LoggerProtocol {
    var debugMessages: [String] = []
    var errorMessages: [String] = []
    
    func debug(message: String) {
        debugMessages.append(message)
    }
    
    func error(message: String) {
        errorMessages.append(message)
    }
}
