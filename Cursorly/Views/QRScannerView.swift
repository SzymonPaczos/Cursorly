import SwiftUI
import VisionKit

#if os(iOS)
struct QRScannerView: UIViewControllerRepresentable {
    var didFindCode: (String) -> Void
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode(symbologies: [.qr])],
            qualityLevel: .balanced,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        try? scanner.startScanning()
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: QRScannerView
        
        init(parent: QRScannerView) {
            self.parent = parent
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            handleItem(item)
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            if let item = addedItems.first {
                handleItem(item)
            }
        }
        
        private func handleItem(_ item: RecognizedItem) {
            switch item {
            case .barcode(let code):
                if let stringValue = code.payloadStringValue {
                    parent.didFindCode(stringValue)
                    parent.dismiss()
                }
            default:
                break
            }
        }
    }
}
#else
struct QRScannerView: View {
    var didFindCode: (String) -> Void
    var body: some View {
        Text("QR Scanning not supported on macOS")
    }
}
#endif
