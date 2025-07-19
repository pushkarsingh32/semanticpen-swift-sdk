import Foundation

/// Main client for interacting with the SemanticPen API
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public class SemanticPenClient {
    private let configuration: Configuration
    private let urlSession: URLSession
    private let jsonDecoder: JSONDecoder
    private let jsonEncoder: JSONEncoder
    
    /// Initialize the SemanticPen client
    /// - Parameter configuration: Client configuration
    public init(configuration: Configuration) {
        self.configuration = configuration
        
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = configuration.timeoutInterval
        sessionConfig.timeoutIntervalForResource = configuration.timeoutInterval
        self.urlSession = URLSession(configuration: sessionConfig)
        
        self.jsonDecoder = JSONDecoder()
        self.jsonEncoder = JSONEncoder()
        
        // Configure date formatting
        let dateFormatter = ISO8601DateFormatter()
        jsonDecoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format")
        }
    }
    
    /// Convenience initializer with API key
    /// - Parameter apiKey: Your SemanticPen API key
    public convenience init(apiKey: String) {
        let config = Configuration(apiKey: apiKey)
        self.init(configuration: config)
    }
    
    /// Generate an article with the given parameters
    /// - Parameters:
    ///   - targetKeyword: The target keyword for the article
    ///   - projectName: Optional project name
    /// - Returns: Response containing article generation details
    public func generateArticle(
        targetKeyword: String,
        projectName: String? = nil
    ) async throws -> GenerateArticleResponse {
        guard !targetKeyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError(message: "Target keyword cannot be empty")
        }
        
        var requestBody: [String: Any] = [
            "target_keyword": targetKeyword.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        if let projectName = projectName {
            requestBody["project_name"] = projectName
        }
        
        return try await performRequest(
            endpoint: "/api/articles",
            method: "POST",
            body: requestBody,
            responseType: GenerateArticleResponse.self
        )
    }
    
    /// Retrieve an article by ID
    /// - Parameter articleId: The ID of the article to retrieve
    /// - Returns: Response containing the article details
    public func getArticle(articleId: String) async throws -> GetArticleResponse {
        guard !articleId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError(message: "Article ID cannot be empty")
        }
        
        return try await performRequest(
            endpoint: "/api/articles/\(articleId)",
            method: "GET",
            body: nil,
            responseType: GetArticleResponse.self
        )
    }
    
    // MARK: - Private Methods
    
    private func performRequest<T: Codable>(
        endpoint: String,
        method: String,
        body: [String: Any]?,
        responseType: T.Type
    ) async throws -> T {
        guard let url = URL(string: endpoint, relativeTo: configuration.baseURL) else {
            throw NetworkError(message: "Invalid URL")
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(configuration.apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("semantic-pen-swift-sdk/1.0.0", forHTTPHeaderField: "User-Agent")
        
        if let body = body {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: body)
            } catch {
                throw ValidationError(message: "Failed to encode request body")
            }
        }
        
        do {
            let (data, response) = try await urlSession.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError(message: "Invalid response type")
            }
            
            // Handle different HTTP status codes
            switch httpResponse.statusCode {
            case 200...299:
                // Success
                break
            case 401:
                throw AuthenticationError(httpStatusCode: httpResponse.statusCode)
            case 429:
                let retryAfter = httpResponse.value(forHTTPHeaderField: "Retry-After")
                    .flatMap(Double.init)
                throw RateLimitError(httpStatusCode: httpResponse.statusCode, retryAfter: retryAfter)
            case 400...499:
                let errorMessage = try parseErrorMessage(from: data) ?? "Client error"
                throw ValidationError(message: errorMessage, httpStatusCode: httpResponse.statusCode)
            case 500...599:
                let errorMessage = try parseErrorMessage(from: data) ?? "Server error"
                throw APIError(message: errorMessage, httpStatusCode: httpResponse.statusCode)
            default:
                throw NetworkError(
                    message: "Unexpected status code: \(httpResponse.statusCode)",
                    httpStatusCode: httpResponse.statusCode
                )
            }
            
            do {
                return try jsonDecoder.decode(responseType, from: data)
            } catch {
                throw APIError(
                    message: "Failed to decode response: \(error.localizedDescription)",
                    httpStatusCode: httpResponse.statusCode
                )
            }
            
        } catch let error as SemanticPenError {
            throw error
        } catch {
            throw NetworkError(
                message: "Network request failed: \(error.localizedDescription)",
                underlyingError: error
            )
        }
    }
    
    private func parseErrorMessage(from data: Data) throws -> String? {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json["message"] as? String ?? json["error"] as? String
    }
}