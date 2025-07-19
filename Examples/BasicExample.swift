import Foundation
import SemanticPen

/// Basic example demonstrating SemanticPen SDK usage
@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
class BasicExample {
    private let client: SemanticPenClient
    
    init(apiKey: String) {
        self.client = SemanticPenClient(apiKey: apiKey)
    }
    
    /// Generate and monitor an article
    func generateAndMonitorArticle(keyword: String, projectName: String? = nil) async {
        print("🚀 Starting article generation...")
        print("Target keyword: \(keyword)")
        if let projectName = projectName {
            print("Project: \(projectName)")
        }
        print("---")
        
        do {
            // Step 1: Generate article
            let generateResponse = try await client.generateArticle(
                targetKeyword: keyword,
                projectName: projectName
            )
            
            print("✅ Generation request successful!")
            print("Message: \(generateResponse.message)")
            
            guard let articleId = generateResponse.firstArticleId else {
                print("❌ No article ID received")
                return
            }
            
            print("📝 Article ID: \(articleId)")
            print("---")
            
            // Step 2: Monitor progress
            await monitorArticleProgress(articleId: articleId)
            
        } catch let error as ValidationError {
            print("❌ Validation Error: \(error.message)")
        } catch let error as AuthenticationError {
            print("❌ Authentication Error: \(error.message)")
        } catch let error as NetworkError {
            print("❌ Network Error: \(error.message)")
        } catch let error as RateLimitError {
            print("❌ Rate Limit Error: \(error.message)")
            if let retryAfter = error.retryAfter {
                print("   Retry after: \(retryAfter) seconds")
            }
        } catch {
            print("❌ Unexpected Error: \(error)")
        }
    }
    
    /// Monitor article progress until completion
    private func monitorArticleProgress(articleId: String) async {
        print("📊 Monitoring article progress...")
        
        var attempts = 0
        let maxAttempts = 60 // Maximum 5 minutes with 5-second intervals
        
        while attempts < maxAttempts {
            do {
                let response = try await client.getArticle(articleId: articleId)
                
                guard let article = response.article else {
                    print("❌ Article not found")
                    return
                }
                
                print("📈 Progress: \(article.progress)% | Status: \(article.status)")
                
                if article.isCompleted {
                    print("🎉 Article completed successfully!")
                    await displayArticleDetails(article)
                    return
                } else if article.hasFailed {
                    print("❌ Article generation failed")
                    print("   Status: \(article.status)")
                    return
                }
                
                // Wait 5 seconds before next check
                try await Task.sleep(nanoseconds: 5_000_000_000)
                attempts += 1
                
            } catch {
                print("❌ Error checking article status: \(error)")
                return
            }
        }
        
        print("⏰ Timeout: Article generation is taking longer than expected")
    }
    
    /// Display detailed article information
    private func displayArticleDetails(_ article: Article) async {
        print("📄 Article Details:")
        print("   ID: \(article.id)")
        print("   Title: \(article.title ?? "No title")")
        print("   Target Keyword: \(article.targetKeyword)")
        print("   Project: \(article.projectName ?? "No project")")
        print("   Status: \(article.status)")
        print("   Progress: \(article.progress)%")
        
        if let createdAt = article.createdAt {
            print("   Created: \(createdAt)")
        }
        
        if let updatedAt = article.updatedAt {
            print("   Updated: \(updatedAt)")
        }
        
        if let content = article.content, !content.isEmpty {
            print("---")
            print("📝 Content Preview:")
            let preview = String(content.prefix(200))
            print(preview)
            if content.count > 200 {
                print("... (\(content.count - 200) more characters)")
            }
        }
    }
    
    /// Retrieve and display an existing article
    func retrieveArticle(articleId: String) async {
        print("🔍 Retrieving article: \(articleId)")
        
        do {
            let response = try await client.getArticle(articleId: articleId)
            
            if let article = response.article {
                await displayArticleDetails(article)
            } else {
                print("❌ Article not found")
            }
            
        } catch {
            print("❌ Error retrieving article: \(error)")
        }
    }
}

// MARK: - Command Line Interface

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
@main
struct SemanticPenExample {
    static func main() async {
        print("🤖 SemanticPen Swift SDK Example")
        print("===============================\n")
        
        // Check for API key
        guard let apiKey = ProcessInfo.processInfo.environment["SEMANTIC_PEN_API_KEY"] else {
            print("❌ Error: SEMANTIC_PEN_API_KEY environment variable not set")
            print("   Please set your API key: export SEMANTIC_PEN_API_KEY='your-api-key'")
            return
        }
        
        let example = BasicExample(apiKey: apiKey)
        
        // Parse command line arguments
        let arguments = CommandLine.arguments
        
        if arguments.count < 2 {
            printUsage()
            return
        }
        
        let command = arguments[1]
        
        switch command {
        case "generate":
            if arguments.count < 3 {
                print("❌ Error: Missing target keyword")
                printUsage()
                return
            }
            
            let keyword = arguments[2]
            let projectName = arguments.count > 3 ? arguments[3] : nil
            
            await example.generateAndMonitorArticle(
                keyword: keyword,
                projectName: projectName
            )
            
        case "get":
            if arguments.count < 3 {
                print("❌ Error: Missing article ID")
                printUsage()
                return
            }
            
            let articleId = arguments[2]
            await example.retrieveArticle(articleId: articleId)
            
        default:
            print("❌ Error: Unknown command '\(command)'")
            printUsage()
        }
    }
    
    static func printUsage() {
        print("Usage:")
        print("  swift run BasicExample generate <keyword> [project_name]")
        print("  swift run BasicExample get <article_id>")
        print("")
        print("Examples:")
        print("  swift run BasicExample generate \"artificial intelligence\" \"Tech Blog\"")
        print("  swift run BasicExample get \"article-id-123\"")
        print("")
        print("Environment Variables:")
        print("  SEMANTIC_PEN_API_KEY - Your SemanticPen API key (required)")
    }
}