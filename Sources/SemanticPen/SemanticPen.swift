import Foundation

/// SemanticPen Swift SDK
/// 
/// A Swift package for interacting with the SemanticPen API to generate AI-powered content.
/// 
/// ## Usage
/// 
/// ```swift
/// import SemanticPen
/// 
/// let client = SemanticPenClient(apiKey: "your-api-key")
/// 
/// // Generate an article
/// do {
///     let response = try await client.generateArticle(
///         targetKeyword: "artificial intelligence",
///         projectName: "My Blog"
///     )
///     print("Article generated with ID: \(response.firstArticleId ?? "unknown")")
/// } catch {
///     print("Error: \(error)")
/// }
/// 
/// // Retrieve an article
/// do {
///     let response = try await client.getArticle(articleId: "article-id")
///     if let article = response.article {
///         print("Title: \(article.title ?? "No title")")
///         print("Status: \(article.status)")
///         print("Progress: \(article.progress)%")
///     }
/// } catch {
///     print("Error: \(error)")
/// }
/// ```

// Re-export main types for convenience
@_exported import struct Foundation.URL
@_exported import struct Foundation.TimeInterval

/// Version of the SemanticPen Swift SDK
public let version = "1.0.0"