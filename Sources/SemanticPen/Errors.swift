import Foundation

/// Base error type for SemanticPen SDK
public protocol SemanticPenError: Error {
    var errorCode: String { get }
    var message: String { get }
    var httpStatusCode: Int? { get }
}

/// General SDK error
public struct SDKError: SemanticPenError {
    public let errorCode: String
    public let message: String
    public let httpStatusCode: Int?
    
    public init(message: String, errorCode: String = "SDK_ERROR", httpStatusCode: Int? = nil) {
        self.message = message
        self.errorCode = errorCode
        self.httpStatusCode = httpStatusCode
    }
}

/// Network-related errors
public struct NetworkError: SemanticPenError {
    public let errorCode: String = "NETWORK_ERROR"
    public let message: String
    public let httpStatusCode: Int?
    public let underlyingError: Error?
    
    public init(message: String, httpStatusCode: Int? = nil, underlyingError: Error? = nil) {
        self.message = message
        self.httpStatusCode = httpStatusCode
        self.underlyingError = underlyingError
    }
}

/// API-related errors
public struct APIError: SemanticPenError {
    public let errorCode: String
    public let message: String
    public let httpStatusCode: Int?
    
    public init(message: String, errorCode: String = "API_ERROR", httpStatusCode: Int? = nil) {
        self.message = message
        self.errorCode = errorCode
        self.httpStatusCode = httpStatusCode
    }
}

/// Authentication errors
public struct AuthenticationError: SemanticPenError {
    public let errorCode: String = "AUTHENTICATION_ERROR"
    public let message: String
    public let httpStatusCode: Int?
    
    public init(message: String = "Invalid API key", httpStatusCode: Int? = 401) {
        self.message = message
        self.httpStatusCode = httpStatusCode
    }
}

/// Validation errors
public struct ValidationError: SemanticPenError {
    public let errorCode: String = "VALIDATION_ERROR"
    public let message: String
    public let httpStatusCode: Int?
    
    public init(message: String, httpStatusCode: Int? = 400) {
        self.message = message
        self.httpStatusCode = httpStatusCode
    }
}

/// Rate limiting errors
public struct RateLimitError: SemanticPenError {
    public let errorCode: String = "RATE_LIMIT_ERROR"
    public let message: String
    public let httpStatusCode: Int?
    public let retryAfter: TimeInterval?
    
    public init(message: String = "Rate limit exceeded", httpStatusCode: Int? = 429, retryAfter: TimeInterval? = nil) {
        self.message = message
        self.httpStatusCode = httpStatusCode
        self.retryAfter = retryAfter
    }
}