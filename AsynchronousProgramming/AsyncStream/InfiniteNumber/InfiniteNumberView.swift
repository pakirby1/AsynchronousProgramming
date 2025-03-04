import SwiftUI
import Charts

struct InfiniteNumberView: View {
    @StateObject var viewModel = InfiniteNumberViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Infinite Number View").font(.system(size: 36))
            HStack {
                CustomButtonView(text: "Start", color: .green) {
                    print("Start button tapped")
                    Task {
                        await viewModel.getNumbers()
                    }
                }
            
                CustomButtonView(text:"Stop", color: .red) {
                    print("Stop button tapped")
                    viewModel.stopNumbers()
                }
            }
            
            Text("\(viewModel.currentNumber)")
        }
        
        Spacer()
    }
}

@MainActor
class InfiniteNumberViewModel : ObservableObject {
    @Published var currentNumber: Int = -1
    @Published var numberHistory: [Int] = []
    
    let service = InfiniteNumberService()

    private func buildPoint(_ model: Double) -> LineChartPoint {
        return LineChartPoint(x: Date.now, y: model)
    }
    
    func getNumbers() async {
        for await model in service.start() {
            guard let num = model else {
                service.stop()
                return
            }
            
            currentNumber = num
            numberHistory.append(num)
        }
    }
    
    func stopNumbers() {
        self.service.stop()
    }
}

class InfiniteNumberService {
    private(set) var stocks: [Stock] = []
    private var currentIndex: Int = 0
    
    lazy var stream = Stream<Int?>() { [weak self] in
        guard let self = self else {
            return nil
        }
        
        // Just return a random Integer, forever
        let ran = Int.random(in: 0..<Int.max)
        print("data: \(ran)")
        return ran
    }
    
    func start() -> AsyncStream<Int?> {
        Task {
            print("attempting to start stream.")
            stream.start()
            print("stream started.")
        }
        
        return stream.stream
    }
    
    func stop() {
        stream.stop()
    }
}

