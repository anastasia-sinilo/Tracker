import UIKit

extension UIColor {
    
    //MARK: - init
    
    convenience init?(hex: String) {
            let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)

            guard hex.count == 6 else { return nil }

            var int: UInt64 = 0

            Scanner(string: hex).scanHexInt64(&int)

            let red = CGFloat((int >> 16) & 0xFF) / 255
            let green = CGFloat((int >> 8) & 0xFF) / 255
            let blue = CGFloat(int & 0xFF) / 255

            self.init(red: red, green: green, blue: blue, alpha: 1.0)
        }
    
    //MARK: - Other functions
    
    func toHex() -> String? {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return nil }

        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(red * 255)),
            lroundf(Float(green * 255)),
            lroundf(Float(blue * 255))
        )
    }
}
