import SwiftUI
import Charts

struct StockView: View {
    @StateObject var viewModel = StockViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Stock View").font(.system(size: 36))
            HStack {
                CustomButtonView(text: "Start", color: .green) {
                    print("Start button tapped")
                    Task {
                        await viewModel.getStocks()
                    }
                }
            
                CustomButtonView(text:"Stop", color: .red) {
                    print("Stop button tapped")
                    viewModel.stopStockStream()
                }
            }
            
            StockDetailView(stock: viewModel.currentStock)
        }
        
        Spacer()
    }
}

struct StockDetailView: View {
    let stock: Stock

    var body: some View {
        Text(stock.symbol)
        Text(stock.company)
        Text(stock.description)
        Text("Initial Price: \(stock.initial_price)")
        Text("2002 Price: \(stock.price_2002)")
        Text("2007 Price: \(stock.price_2007)")
    }
}

@MainActor
class StockViewModel : ObservableObject {
    @Published var currentStock: Stock = Stock.defaultStock
    @Published var stockHistory: [Stock?] = []
    
    let service = StockService()

    private func buildPoint(_ model: Double) -> LineChartPoint {
        return LineChartPoint(x: Date.now, y: model)
    }
    
    func getStocks() async {
        for await model in service.start() {
            guard let stock = model else {
                service.stop()
                return
            }
            
            currentStock = stock
            stockHistory.append(currentStock)
        }
    }
    
    func stopStockStream() {
        self.service.stop()
    }
}
