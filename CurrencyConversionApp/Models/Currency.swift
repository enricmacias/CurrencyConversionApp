import Foundation

struct Currency {
    let name: String
    let code: String
    let symbol: String?
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
        let locale = NSLocale(localeIdentifier: code)
        self.symbol = locale.displayName(forKey: .currencySymbol, value: code)
    }
}
