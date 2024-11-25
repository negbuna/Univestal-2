//
//  AlpacaModel.swift
//  Univestal
//
//  Created by Nathan Egbuna on 7/11/24.
//

import SwiftUI

class AlpacaModel: ObservableObject {
    @Published var stocks: [Stock] = []
    @Published var account: Account?
    @Published var orders: [Order] = []
    
    func fetchStocks() {
        guard let url = URL(string: "https://paper-api.alpaca.markets/v2/stocks") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch stocks: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON Response: \(jsonString)")
            }

            
            // Converting to JSON
            do {
                let stocks = try JSONDecoder().decode([Stock].self, from: data)
                DispatchQueue.main.async {
                    self?.stocks = stocks
                    print("Fetched stocks: \(stocks)")
                }
            } catch {
                print("Failed to decode stocks: \(error)")
            }
        }
        task.resume()
    }
    
    func fetchAccount() {
        guard let url = URL(string: "https://paper-api.alpaca.markets/v2/account") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch account: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Converting to JSON
            do {
                let account = try JSONDecoder().decode(Account.self, from: data)
                DispatchQueue.main.async {
                    self?.account = account
                    print("Fetched account: \(account)")
                }
            } catch {
                print("Failed to decode account: \(error)")
            }
        }
        task.resume()
    }
    
    func fetchOrders() {
        guard let url = URL(string: "https://paper-api.alpaca.markets/v2/orders") else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch orders: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Converting to JSON
            do {
                let orders = try JSONDecoder().decode([Order].self, from: data)
                DispatchQueue.main.async {
                    self?.orders = orders
                    print("Fetched orders: \(orders)")
                }
            } catch {
                print("Failed to decode orders: \(error)")
            }
        }
        task.resume()
    }
}



struct NetworkManagerView: View {
    @StateObject var alpacaModel = AlpacaModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                    // Display Stocks
                    if !alpacaModel.stocks.isEmpty {
                        Text("Stocks")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(alpacaModel.stocks, id: \.self) { stock in
                            VStack(alignment: .leading) {
                                Text("Symbol: \(stock.symbol)")
                                Text("Price: \(stock.price)")
                            }
                            .padding()
                        }
                    } else {
                        Text("No stocks available.")
                            .padding()
                    }
                    
                    // Display Account Info
                    if let account = alpacaModel.account {
                        Text("Account Info")
                            .font(.headline)
                            .padding(.top)
                        
                        VStack(alignment: .leading) {
                            Text("Account ID: \(account.id)")
                            Text("Cash: \(account.cash)")
                            Text("Portfolio Value: \(account.portfolioValue)")
                        }
                        .padding()
                    } else {
                        Text("No account info available.")
                            .padding()
                    }
                    
                    // Display Orders
                    if !alpacaModel.orders.isEmpty {
                        Text("Orders")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(alpacaModel.orders, id: \.id) { order in
                            VStack(alignment: .leading) {
                                Text("Order ID: \(order.id)")
                                Text("Symbol: \(order.symbol)")
                                Text("Quantity: \(order.qty)")
                                Text("Filled Quantity: \(order.filledQty)")
                                Text("Status: \(order.status)")
                            }
                            .padding()
                        }
                    } else {
                        Text("No orders available.")
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("API Integration Example")
            .onAppear {
                // Fetch data when view appears
                alpacaModel.fetchStocks()
                alpacaModel.fetchAccount()
                alpacaModel.fetchOrders()
            }
        }
    }
}

struct NetworkManagerView_Previews: PreviewProvider {
    static var previews: some View {
        NetworkManagerView()
    }
}
