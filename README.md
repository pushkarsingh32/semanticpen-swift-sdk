# SemanticPen Swift SDK

[![Swift](https://img.shields.io/badge/Swift-5.5+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2013%2B%20%7C%20macOS%2010.15%2B%20%7C%20tvOS%2013%2B%20%7C%20watchOS%206%2B-lightgrey.svg)](https://developer.apple.com)
[![SPM](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)

Official Swift SDK for [SemanticPen](https://www.semanticpen.com) - AI-powered content generation platform. Generate high-quality articles and content using advanced AI technology with a simple and intuitive Swift interface.

## Features

- **Modern Swift API**: Built with async/await for clean asynchronous code
- **Type-safe**: Full Swift type safety with Codable models
- **Comprehensive Error Handling**: Detailed error types for different scenarios
- **Cross-platform**: Works on iOS, macOS, tvOS, and watchOS
- **Zero Dependencies**: Uses only Foundation and URLSession
- **Well Documented**: Extensive documentation and examples

## Requirements

- iOS 13.0+ / macOS 10.15+ / tvOS 13.0+ / watchOS 6.0+
- Xcode 12.0+
- Swift 5.5+

## Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/pushkarsingh32/semanticpen-swift-sdk.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter: `https://github.com/pushkarsingh32/semanticpen-swift-sdk.git`
3. Select version and add to your target

## Quick Start

### Initialize the Client

```swift
import SemanticPen

let client = SemanticPenClient(apiKey: "your-api-key-here")
```

### Generate an Article

```swift
do {
    let response = try await client.generateArticle(
        targetKeyword: "artificial intelligence",
        projectName: "Tech Blog"
    )
    
    if response.success {
        print("✅ Article generation started!")
        print("Article ID: \(response.firstArticleId ?? "N/A")")
        print("Message: \(response.message)")
    }
} catch {
    print("❌ Error: \(error)")
}
```

### Retrieve an Article

```swift
do {
    let response = try await client.getArticle(articleId: "your-article-id")
    
    if let article = response.article {
        print("📝 Article: \(article.title ?? "Untitled")")
        print("📊 Status: \(article.status)")
        print("📈 Progress: \(article.progress)%")
        
        if article.isCompleted {
            print("✅ Article is ready!")
            print("Content: \(article.content ?? "No content")")
        } else if article.isInProgress {
            print("⏳ Article is still being generated...")
        }
    }
} catch {
    print("❌ Error: \(error)")
}
```

## API Reference

### SemanticPenClient

The main client class for interacting with the SemanticPen API.

#### Initialization

```swift
// With API key only
let client = SemanticPenClient(apiKey: "your-api-key")

// With custom configuration
let config = Configuration(
    apiKey: "your-api-key",
    baseURL: URL(string: "https://api.semanticpen.com")!,
    timeoutInterval: 30
)
let client = SemanticPenClient(configuration: config)
```

#### Methods

- `generateArticle(targetKeyword:projectName:) async throws -> GenerateArticleResponse`
- `getArticle(articleId:) async throws -> GetArticleResponse`

### Models

#### Article

Represents an article with the following properties:

```swift
public struct Article {
    public let id: String
    public let title: String?
    public let content: String?
    public let status: String
    public let progress: Int
    public let targetKeyword: String
    public let projectName: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    // Convenience properties
    public var isCompleted: Bool
    public var isInProgress: Bool
    public var hasFailed: Bool
}
```

#### GenerateArticleResponse

Response from article generation:

```swift
public struct GenerateArticleResponse {
    public let success: Bool
    public let message: String
    public let articleIds: [String]?
    public let articleId: String?
    public let errorCode: String?
    
    // Convenience properties
    public var hasArticleIds: Bool
    public var firstArticleId: String?
    public var allArticleIds: [String]
}
```

### Error Handling

The SDK provides comprehensive error handling with specific error types:

```swift
do {
    let response = try await client.generateArticle(targetKeyword: "AI")
} catch let error as ValidationError {
    print("Validation error: \(error.message)")
} catch let error as AuthenticationError {
    print("Authentication error: \(error.message)")
} catch let error as NetworkError {
    print("Network error: \(error.message)")
} catch let error as RateLimitError {
    print("Rate limit error: \(error.message)")
    if let retryAfter = error.retryAfter {
        print("Retry after: \(retryAfter) seconds")
    }
} catch {
    print("Unknown error: \(error)")
}
```

#### Error Types

- `ValidationError`: Invalid input parameters
- `AuthenticationError`: Invalid API key or authentication issues
- `NetworkError`: Network connectivity issues
- `APIError`: Server-side errors
- `RateLimitError`: Rate limiting errors
- `SDKError`: General SDK errors

## Examples

### Basic Article Generation

```swift
import SemanticPen

class ArticleGenerator {
    private let client: SemanticPenClient
    
    init(apiKey: String) {
        self.client = SemanticPenClient(apiKey: apiKey)
    }
    
    func generateAndMonitorArticle(keyword: String) async {
        do {
            // Start generation
            let generateResponse = try await client.generateArticle(
                targetKeyword: keyword,
                projectName: "Sample Project"
            )
            
            guard let articleId = generateResponse.firstArticleId else {
                print("No article ID received")
                return
            }
            
            print("Article generation started with ID: \(articleId)")
            
            // Monitor progress
            while true {
                let articleResponse = try await client.getArticle(articleId: articleId)
                
                guard let article = articleResponse.article else {
                    print("Article not found")
                    break
                }
                
                print("Progress: \(article.progress)% - Status: \(article.status)")
                
                if article.isCompleted {
                    print("✅ Article completed!")
                    print("Title: \(article.title ?? "No title")")
                    break
                } else if article.hasFailed {
                    print("❌ Article generation failed")
                    break
                }
                
                // Wait before checking again
                try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            }
            
        } catch {
            print("Error: \(error)")
        }
    }
}

// Usage
let generator = ArticleGenerator(apiKey: "your-api-key")
await generator.generateAndMonitorArticle(keyword: "machine learning")
```

### SwiftUI Integration

```swift
import SwiftUI
import SemanticPen

class ArticleViewModel: ObservableObject {
    @Published var article: Article?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let client: SemanticPenClient
    
    init(apiKey: String) {
        self.client = SemanticPenClient(apiKey: apiKey)
    }
    
    func generateArticle(keyword: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let response = try await client.generateArticle(targetKeyword: keyword)
            
            if let articleId = response.firstArticleId {
                await monitorArticle(id: articleId)
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    private func monitorArticle(id: String) async {
        while isLoading {
            do {
                let response = try await client.getArticle(articleId: id)
                
                await MainActor.run {
                    self.article = response.article
                    
                    if let article = response.article {
                        if article.isCompleted || article.hasFailed {
                            self.isLoading = false
                        }
                    }
                }
                
                if !isLoading { break }
                
                try await Task.sleep(nanoseconds: 3_000_000_000) // 3 seconds
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
                break
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = ArticleViewModel(apiKey: "your-api-key")
    @State private var keyword = ""
    
    var body: some View {
        VStack {
            TextField("Enter keyword", text: $keyword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Generate Article") {
                Task {
                    await viewModel.generateArticle(keyword: keyword)
                }
            }
            .disabled(keyword.isEmpty || viewModel.isLoading)
            
            if viewModel.isLoading {
                ProgressView("Generating article...")
                    .padding()
            }
            
            if let article = viewModel.article {
                VStack(alignment: .leading) {
                    Text("Title: \(article.title ?? "No title")")
                        .font(.headline)
                    Text("Status: \(article.status)")
                    Text("Progress: \(article.progress)%")
                    
                    if let content = article.content {
                        ScrollView {
                            Text(content)
                                .padding()
                        }
                    }
                }
                .padding()
            }
            
            if let error = viewModel.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
    }
}
```

## Configuration

### Custom Configuration

```swift
let config = Configuration(
    apiKey: "your-api-key",
    baseURL: URL(string: "https://custom-api.example.com")!,
    timeoutInterval: 45
)

let client = SemanticPenClient(configuration: config)
```

### Environment Variables

For security, consider using environment variables or secure storage for API keys:

```swift
guard let apiKey = ProcessInfo.processInfo.environment["SEMANTIC_PEN_API_KEY"] else {
    fatalError("API key not found in environment")
}

let client = SemanticPenClient(apiKey: apiKey)
```

## Testing

The SDK includes comprehensive tests. Run them using:

```bash
swift test
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- **Documentation**: [https://docs.semanticpen.com](https://docs.semanticpen.com)
- **API Reference**: [https://api.semanticpen.com/docs](https://api.semanticpen.com/docs)
- **Issues**: [GitHub Issues](https://github.com/pushkarsingh32/semanticpen-swift-sdk/issues)
- **Email**: support@semanticpen.com

## Changelog

### v1.0.0
- Initial release
- Article generation and retrieval
- Comprehensive error handling
- SwiftUI and UIKit compatibility
- Full async/await support