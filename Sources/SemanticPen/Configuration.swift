import Foundation

/// Configuration for the SemanticPen SDK
public struct Configuration {
    /// API key for authentication
    public let apiKey: String
    
    /// Base URL for the SemanticPen API
    public let baseURL: URL
    
    /// Request timeout in seconds
    public let timeoutInterval: TimeInterval
    
    /// Creates a new configuration
    /// - Parameters:
    ///   - apiKey: Your SemanticPen API key
    ///   - baseURL: Base URL for the API (defaults to production)
    ///   - timeoutInterval: Request timeout in seconds (defaults to 60)
    public init(
        apiKey: String,
        baseURL: URL = URL(string: "https://www.semanticpen.com")!,
        timeoutInterval: TimeInterval = 60
    ) {
        self.apiKey = apiKey
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
    }
}