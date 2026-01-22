import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeGenerator {
    static func generate(from string: String) -> Image? {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(string.utf8)
        
        if let outputImage = filter.outputImage {
            // Skalowanie QR kodu (domyślnie jest malutki)
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            let scaledImage = outputImage.transformed(by: transform)
            
            if let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) {
                #if os(iOS)
                return Image(uiImage: UIImage(cgImage: cgImage))
                #elseif os(macOS)
                return Image(nsImage: NSImage(cgImage: cgImage, size: .zero))
                #endif
            }
        }
        return nil
    }
}
