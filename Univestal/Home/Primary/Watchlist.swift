//
//  Watchlist.swift
//  Univestal
//
//  Created by Nathan Egbuna on 11/25/24.
//

import SwiftUI

struct Watchlist: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @State private var searchText = ""
    @State private var selectedCoinID: String? = nil

    var filteredWatchlistCoins: [Coin] {
        let watchlistCoins = environment.crypto.coins.filter { appData.watchlist.contains($0.id) }
        if searchText.isEmpty {
            return watchlistCoins
        } else {
            return watchlistCoins.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var selectedCoin: Coin? {
        environment.crypto.coins.first { $0.id == selectedCoinID }
    }

    var body: some View {
        NavigationStack {
            VStack {
                if !appData.watchlist.isEmpty {
                    List(filteredWatchlistCoins) { coin in
                        HStack {
                            Button(action: {
                                appData.toggleWatchlist(for: coin.id)
                            }) {
                                Image(systemName: appData.watchlist.contains(coin.id) ? "star.fill" : "star")
                                    .foregroundColor(appData.watchlist.contains(coin.id) ? .yellow : .gray)
                            }
                            .buttonStyle(BorderlessButtonStyle())
                            
                            VStack(alignment: .leading) {
                                Text(coin.name)
                                    .font(.headline)
                                Text(coin.symbol.uppercased())
                                    .font(.subheadline)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                Text(String(format: "$%.2f", coin.current_price))
                                    .font(.headline)
                                Text(String(format: "%.2f%%", coin.price_change_percentage_24h ?? 0.00))
                                    .font(.subheadline)
                                    .foregroundColor(appData.percentColor(coin.price_change_percentage_24h ?? 0))
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCoinID = coin.id
                        }
                    }
                    .searchable(text: $searchText)
                    .navigationDestination(isPresented: .constant(selectedCoinID != nil)) {
                        if let coin = selectedCoin {
                            CoinDetailView(coin: coin)
                        }
                    }
                } else {
                    Text("Your watchlist is empty")
                        .font(.headline)
                        .foregroundColor(.gray)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: Search()) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.blue)
                    }
                }
            }
            .navigationTitle("Watchlist")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    Watchlist()
        .environmentObject(AppData())
        .environmentObject(TradingEnvironment.shared)
}
