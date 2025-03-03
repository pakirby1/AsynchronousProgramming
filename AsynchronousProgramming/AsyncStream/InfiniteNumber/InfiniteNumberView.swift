import SwiftUI
import Charts

struct InfiniteNumberView: View {
    @StateObject var viewModel = InfiniteNumberViewModel()
    
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

@MainActor
class InfiniteNumberViewModel : ObservableObject {
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
