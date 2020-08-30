import Foundation

struct Currency {
    let name: String
    let code: String
    let amount: Double
    let symbol: String?
    
    init(name: String, code: String) {
        self.name = name
        self.code = code
        self.symbol = NSLocale(localeIdentifier: code).displayName(forKey: .currencySymbol,
                                                                   value: code)
        self.amount = 0.0
    }
    
    init(code: String, amount: Double) {
        self.code = code
        self.symbol = NSLocale(localeIdentifier: code).displayName(forKey: .currencySymbol,
                                                                   value: code)
        self.amount = amount
        self.name = ""
    }
}
