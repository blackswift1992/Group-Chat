import UIKit

extension UIColor {
    static let brandBlue = UIColor(named: "BrandBlue")
    static let brandDarkGray = UIColor(named: "BrandDarkGray")
    static let brandDarkMint = UIColor(named: "BrandDarkMint")
    static let brandGray = UIColor(named: "BrandGray")
    static let brandGray3 = UIColor(named: "BrandGray3")
    static let brandGray5 = UIColor(named: "BrandGray5")
    static let brandGray6 = UIColor(named: "BrandGray6")
    static let brandLightBlue = UIColor(named: "BrandLightBlue")
    static let brandMint = UIColor(named: "BrandMint")
    static let brandLightMint = UIColor(named: "BrandLightMint")
    static let brandRed = UIColor(named: "BrandRed")
    
    
    static func getRandomRGBString() -> String {
        let red = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        let green = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        let blue = round(Double.random(in: 0.4...1.0) * 100) / 100.0
        
        return "\(red),\(green),\(blue)"
    }
    
    
    static func getColorFromRGBString(_ rgbString: String) -> UIColor {
        let rgb = rgbString.components(separatedBy: ",").compactMap{Double($0)}
        
        return UIColor(red: rgb[0], green: rgb[1], blue: rgb[2], alpha: 1.0)
    }
}
