//
//  Trade.swift
//  Univestal
//
//  Created by Nathan Egbuna on 12/9/24.
//

import SwiftUI
import CoreData

struct TradingView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @State private var showMenu: Bool = false
    @State private var activeAlert: TradeAlertType?
    @State private var selectedCoin: Coin?
    @State private var tradeErrorAlert: Bool = false
    @State private var isBuying: Bool = true
    @State private var selectedTimeFrame: TimeFrame = .day
    
    var filteredCoins: [Coin] {
        if tradedCoin.isEmpty {
            return environment.crypto.coins
        } else {
            return environment.crypto.coins.filter { $0.name.lowercased().contains(tradedCoin.lowercased()) }
        }
    }
    
    @State private var tradedCoin: String = ""
    @State private var tradedQuantity: String = ""
    
    enum TradeAlertType: Identifiable {
        var id: String { UUID().uuidString }
        case confirmTrade, insufficientFunds, insufficientHoldings, tradeError
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    if !showMenu {
                        portfolioView
                    }
                    tradeMenuView
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .onAppear {
                    startPeriodicFetching()
                }
                .navigationTitle("Trading Simulator")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink("History") {
                            PastTrades()
                        }
                    }
                }
                .globeOverlay()
            }
        }
    }

    private var portfolioView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Your Portfolio: \(environment.totalPortfolioValue, specifier: "$%.2f")")
                    .font(.title2)
                    .bold()
                
                if let change = environment.portfolioChange(for: selectedTimeFrame) {
                    Text("\(change.amount >= 0 ? "+" : "")\(change.amount, specifier: "$%.2f") (\(change.percentage, specifier: "%.1f")%)")
                        .font(.subheadline)
                        .foregroundColor(change.amount >= 0 ? .green : .red)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                }
            }
            
            Picker("Time Frame", selection: $selectedTimeFrame) {
                Text("24H").tag(TimeFrame.day)
                Text("7D").tag(TimeFrame.week)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            
            Text("Cash Available: \(environment.portfolioBalance, specifier: "$%.2f")")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            tradeButtons
        }
    }

    private func calculateTotalPortfolioValue() -> Double {
        let cashBalance = environment.portfolioBalance
        
        let fetchRequest: NSFetchRequest<CDTrade> = CDTrade.fetchRequest()
        let trades = try? environment.coreDataStack.context.fetch(fetchRequest)
        
        print("Found \(trades?.count ?? 0) trades")
        
        let holdingsValue = trades?.reduce(0.0) { total, trade in
            let currentPrice = environment.crypto.coins.first { $0.id == trade.coinId }?.current_price ?? trade.purchasePrice
            print("Trade: \(trade.quantity) \(String(describing: trade.coinSymbol)) at current price: \(currentPrice)")
            return total + (currentPrice * trade.quantity)
        } ?? 0.0
        
        print("Total holdings value: \(holdingsValue)")
        print("Cash balance: \(cashBalance)")
        
        return cashBalance + holdingsValue
    }

    private var tradeMenuView: some View {
        Group {
            if showMenu {
                VStack {
                    Text("Trade")
                        .foregroundStyle(.secondary)
                        .bold()

                    Divider()

                    TradeMenuView(
                        selectedCoin: $selectedCoin,
                        tradedCoin: $tradedCoin,
                        tradedQuantity: $tradedQuantity
                    )

                    Divider()

                    buttons
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.secondarySystemBackground))
                        .shadow(radius: 10)
                )
                .transition(.move(edge: .bottom))
            }
        }
    }

    private var buttons: some View {
        HStack {
            Button("Cancel") {
                withAnimation(.easeInOut) {
                    showMenu = false
                }
            }
            .foregroundStyle(.red)
            .bold()

            Spacer()

            Button("Confirm") {
                if !tradedCoin.isEmpty && !tradedQuantity.isEmpty {
                    executeTrade()
                }
            }
            .foregroundStyle(.green)
            .bold()
        }
        .padding(.horizontal)
        .alert(item: $activeAlert) { alertType in
            switch alertType {
            case .confirmTrade:
                return Alert(
                    title: Text("Confirm Trade"),
                    message: Text("Are you sure you want to execute this trade?"),
                    primaryButton: .default(Text("Confirm")) {
                        executeTrade()
                    },
                    secondaryButton: .cancel()
                )
            case .insufficientFunds:
                return Alert(
                    title: Text("Insufficient Funds"),
                    message: Text("You don't have enough funds to complete this trade."),
                    dismissButton: .default(Text("OK"))
                )
            case .insufficientHoldings:
                return Alert(
                    title: Text("Insufficient Holdings"),
                    message: Text("You don't have enough holdings to complete this trade."),
                    dismissButton: .default(Text("OK"))
                )
            case .tradeError:
                return Alert(
                    title: Text("Trade Error"),
                    message: Text("An error occurred while executing the trade."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    private func executeTrade() {
        guard let coin = selectedCoin,
              let quantity = Double(tradedQuantity) else {
            activeAlert = .tradeError
            return
        }

        do {
            if isBuying {
                try environment.executeTrade(
                    coinId: coin.id,
                    symbol: coin.symbol,
                    name: coin.name,
                    quantity: quantity,
                    currentPrice: coin.current_price
                )
            } else {
                try environment.executeSell(
                    coinId: coin.id,
                    symbol: coin.symbol,
                    name: coin.name,
                    quantity: quantity,
                    currentPrice: coin.current_price
                )
            }
            
            withAnimation(.easeInOut) {
                showMenu = false
            }
            
            // Reset fields
            selectedCoin = nil
            tradedCoin = ""
            tradedQuantity = ""
        } catch PaperTradingError.insufficientBalance {
            activeAlert = .insufficientFunds
        } catch PaperTradingError.insufficientHoldings {
            activeAlert = .insufficientHoldings
        } catch {
            activeAlert = .tradeError
            print("Trade error: \(error)")
        }
    }

    private func startPeriodicFetching() {
        environment.crypto.fetchCoins()
        
        Timer.publish(every: 20.0, on: .main, in: .common)
            .autoconnect()
            .sink { _ in
                environment.crypto.fetchCoins()
                
                // Update trade prices with latest coin prices
                let prices = Dictionary(
                    uniqueKeysWithValues: environment.crypto.coins.map { 
                        ($0.id, $0.current_price) 
                    }
                )
                environment.updatePrices(with: prices)
            }
            .store(in: &environment.crypto.cancellables)
    }

    private var tradeButtons: some View {
        HStack {
            Button("Buy") {
                withAnimation(.easeInOut) {
                    showMenu = true
                    isBuying = true
                }
            }
            .buttonStyle(.borderedProminent)

            Button("Sell") {
                withAnimation(.easeInOut) {
                    showMenu = true
                    isBuying = false
                }
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical)
    }
}

struct TradeMenuView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var environment: TradingEnvironment
    @Binding var selectedCoin: Coin?
    @Binding var tradedCoin: String
    @Binding var tradedQuantity: String
    
    var filteredCoins: [Coin] {
        if tradedCoin.isEmpty {
            return environment.crypto.coins
        } else {
            return environment.crypto.coins.filter {
                $0.name.lowercased().contains(tradedCoin.lowercased())
            }
        }
    }

    var body: some View {
        VStack {
            TextField("Enter Coin", text: $tradedCoin)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: UIScreen.relativeWidth(80))
            
            TextField("Quantity", text: $tradedQuantity)
               .textFieldStyle(RoundedBorderTextFieldStyle())
               .frame(width: UIScreen.relativeWidth(80))
            
            if !tradedCoin.isEmpty {
                Picker("Select a Coin", selection: $selectedCoin) {
                    ForEach(filteredCoins, id: \.id) { coin in
                        Text(coin.name)
                            .tag(coin as Coin?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .onChange(of: selectedCoin) {
                    if let coin = selectedCoin {
                        tradedCoin = coin.name
                    }
                }
                if let coin = selectedCoin,
                   let quantity = Double(tradedQuantity),
                   quantity > 0 {
                    VStack(spacing: 8) {
                        Text("Trade Summary")
                            .font(.headline)
                        Text("\(quantity) \(coin.symbol.uppercased()) = \(String(format: "$%.2f", coin.current_price * quantity))")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(UIColor.systemGroupedBackground))
                    )
                }
            }
        }
        .padding(UIScreen.relativeWidth(4))
        .onAppear {
            tradedCoin = ""
            tradedQuantity = ""
        }
    }
}

#Preview {
    TradingView()
        .environmentObject(AppData())
        .environmentObject(TradingEnvironment.shared)
}
