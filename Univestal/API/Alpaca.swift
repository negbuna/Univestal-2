//
//  Alpaca.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/11/24.
//

import Foundation
import Combine

// Model for Stock Data

struct Stock: Hashable, Codable {
    let symbol: String
    let price: Double
}

struct Account: Hashable, Codable {
    let id: String
    let cash: String
    let portfolioValue: String
}

struct Order: Hashable, Codable {
    let id: String
    let symbol: String
    let qty: Int
    let filledQty: Int
    let status: String
}

class NetworkManager: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var account: Account?
    @Published var orders: [Order] = []

    private let apiKey = Config.apiKey
    private let secretKey = Config.secretKey
    private let baseURL = "https://paper-api.alpaca.markets"

    private func createRequest(endpoint: String) -> URLRequest {
        let url = URL(string: "\(baseURL)\(endpoint)")!
        var request = URLRequest(url: url)
        request.addValue(apiKey, forHTTPHeaderField: "APCA-API-KEY-ID")
        request.addValue(secretKey, forHTTPHeaderField: "APCA-API-SECRET-KEY")
        return request
    }

    func fetchStockData() {
        let request = createRequest(endpoint: "/v2/stocks/AAPL/quote")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Stock].self, from: data)
                    DispatchQueue.main.async {
                        self.stocks = decodedData
                    }
                } catch let error {
                    print("Error decoding stock data: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("HTTP request error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func fetchAccountInfo() {
        let request = createRequest(endpoint: "/v2/account")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode(Account.self, from: data)
                    DispatchQueue.main.async {
                        self.account = decodedData
                    }
                } catch let error {
                    print("Error decoding account data: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("HTTP request error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func fetchOrders() {
        let request = createRequest(endpoint: "/v2/orders")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Order].self, from: data)
                    DispatchQueue.main.async {
                        self.orders = decodedData
                    }
                } catch let error {
                    print("Error decoding orders data: \(error.localizedDescription)")
                }
            } else if let error = error {
                print("HTTP request error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
