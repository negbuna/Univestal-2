//
//  News.swift
//  Univestal
//
//  Created by Nathan Egbuna on 11/28/24.
//

import Foundation
import Combine
import SwiftUI

class News: ObservableObject {
    @Published var articles: [Article] = []
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var isLoading = false
    @Published var currentPage = 1
    @Published var totalArticlesFound = 0
    
    let baseUrl = "https://api.thenewsapi.com/v1/news/all"
    let apiKey = Config.newsKey
    let articlesPerPage = 3 // Match the API's default limit

    func fetchArticles(query: String, page: Int = 1) {
        // Prevent multiple simultaneous requests
        guard !isLoading else { return }
        
        isLoading = true
        
        let queryEncoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        guard let url = URL(string: "\(baseUrl)?api_token=\(apiKey)&search=\(queryEncoded)&categories=business,general&published_after=\(oneWeekBack())&language=en&page=\(page)&limit=\(articlesPerPage)") else {
            print("Invalid URL")
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            defer {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "No data received from the server."
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                decoder.dateDecodingStrategy = .custom { decoder -> Date in
                    let container = try decoder.singleValueContainer()
                    let dateString = try container.decode(String.self)
                    
                    let formatter = ISO8601DateFormatter()
                    formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                    
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                    
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string: \(dateString)")
                }
                
                let decodedResponse = try decoder.decode(NewsResponse.self, from: data)
                
                DispatchQueue.main.async {
                    // If it's the first page, replace articles
                    // If it's a subsequent page, append articles
                    if page == 1 {
                        self.articles = decodedResponse.data
                    } else {
                        self.articles.append(contentsOf: decodedResponse.data)
                    }
                    
                    self.totalArticlesFound = decodedResponse.meta.found
                    self.currentPage = page
                    
                    if decodedResponse.data.isEmpty {
                        self.showAlert = true
                        self.alertMessage = "No more articles found."
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert = true
                    self.alertMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
    
    func loadMoreArticlesIfNeeded(currentArticle article: Article, query: String) {
        // Check if the current article is the last one and there are more articles to load
        guard articles.count < totalArticlesFound else {
            return
        }
        
        // Load next page
        fetchArticles(query: query, page: currentPage + 1)
    }
    
    private func oneWeekBack() -> String {
        let calendar = Calendar.current
        let date = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    func loadMockData() {
        self.articles = [
            Article(
                id: "1",
                title: "Trump's Election Brings Crypto Bros to Power",
                description: "This is a mock description for article 1.",
                keywords: "crypto",
                snippet: "New crypto-friendly legislators are in town to bring new legislation with hands-free government.",
                url: "https://example.com",
                imageUrl: "https://african.business/wp-content/uploads/2024/11/000_36m4738-1024x683.jpg",
                language: "en",
                publishedAt: Date(),
                source: "NBC Finance",
                categories: ["Finance"],
                relevanceScore: 17.241
            ),
            Article(
                id: "2",
                title: "Bitcoin Raises $99K at Close",
                description: "This is a mock description for article 2.",
                keywords: "crypto",
                snippet: "Mock snippet for article 2.",
                url: "https://example.com",
                imageUrl: "https://www.manilatimes.net/2024/11/29/tmt-newswire/globenewswire/bullionz-launches-revolutionary-new-crypto-exchange/2013291",
                language: "en",
                publishedAt: Date(),
                source: "HK Times",
                categories: ["Finance"],
                relevanceScore: 18.761
            ),
            Article(
                id: "3",
                title: "Ethereum and Litecoin among new approved coins in El Salvador",
                description: "This is a mock description for article 3.",
                keywords: "crypto",
                snippet: "Mock snippet for article 3.",
                url: "https://example.com",
                imageUrl: "https://miro.medium.com/v2/resize:fit:1200/1*gpX1hc1ubTjnjbvLjMJ22w.png",
                language: "en",
                publishedAt: Date(),
                source: "Mock Source",
                categories: ["Finance"],
                relevanceScore: 19.2331
            ),
            Article(
                id: "a2c0777b-25c2-4c33-aec8-427e94be3148",
                title: "What Crypto Investors Can Expect From A Pro-Crypto SEC",
                description: "A pro-crypto SEC will reshape crypto markets around the globe",
                keywords: "crypto, finance",
                snippet: "A pro-crypto SEC has the potential to reshape crypto markets.",
                url: "https://www.forbes.com/sites/digital-assets/2024/12/01/what-crypto-investors-can-expect-from-a-pro-crypto-sec/",
                imageUrl: "https://imageio.forbes.com/specials-images/imageserve/674c905ae5ab54939401baa2/0x0.jpg?format=jpg&crop=2816,1320,x0,y336,safe&height=900&width=1600&fit=bounds",
                language: "en",
                publishedAt: ISO8601DateFormatter().date(from: "2024-12-01T16:36:46.000000Z") ?? Date(),
                source: "forbes.com",
                categories: ["business", "general"],
                relevanceScore: 20.1122
            ),
            Article(
                id: "f0b46188-1f42-440a-95b6-32dc71607238",
                title: "Crypto Week at a Glance: Global crypto sentiment shifts with rising Bitcoin value",
                description: "Bitcoin witnesses a brief correction to $90,000 before bouncing back to $95,000.",
                keywords: "crypto",
                snippet: "Stellar is up 100.33%. The Sandbox is up 76.4%.",
                url: "https://economictimes.indiatimes.com/markets/cryptocurrency/crypto-week-at-a-glance-global-crypto-sentiment-shifts-with-rising-bitcoin-value/articleshow/115813490.cms",
                imageUrl: "https://img.etimg.com/thumb/msid-115813749,width-1200,height-630,imgsize-66104,overlay-etmarkets/articleshow.jpg",
                language: "en",
                publishedAt: ISO8601DateFormatter().date(from: "2024-11-30T05:30:00.000000Z") ?? Date(),
                source: "economictimes.indiatimes.com",
                categories: ["business", "general"],
                relevanceScore: 19.23345
            ),
            Article(
                id: "9bbc2a54-a037-4393-8e53-f8ad3f48e3fc",
                title: "Simplifying crypto: Take ownership of your financial future with Crypto ki Paathshala",
                description: "The volatile world of crypto decoded at Crypto ki Paathshala by Mudrex.",
                keywords: "crypto",
                snippet: "ET Spotlight. Why crypto matters.",
                url: "https://economictimes.indiatimes.com/markets/cryptocurrency/simplifying-crypto-take-ownership-of-your-financial-future-with-crypto-ki-paathshala/articleshow/115755962.cms",
                imageUrl: "https://img.etimg.com/thumb/msid-115756700,width-1200,height-630,imgsize-798068,overlay-etmarkets/articleshow.jpg",
                language: "en",
                publishedAt: ISO8601DateFormatter().date(from: "2024-11-28T05:34:25.000000Z") ?? Date(),
                source: "economictimes.indiatimes.com",
                categories: ["business", "general"],
                relevanceScore: 18.245
            )
        ]
    }
}
