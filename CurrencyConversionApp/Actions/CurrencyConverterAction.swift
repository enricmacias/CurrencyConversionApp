import Foundation

protocol CurrencyConverterActionType: class {
    func fetchCurrencies()
    func fetchRates()
    func convert(_ amount: Float, from fromCurrency: String, to toCurrency: String)
}

final class CurrencyConverterAction: CurrencyConverterActionType {
    static let shared = CurrencyConverterAction()
    
    func fetchCurrencies() {
        // TODO: fetchCurrencies
    }
    
    func fetchRates() {
        // TODO: fetchRates
    }
    
    func convert(_ amount: Float, from fromCurrency: String, to toCurrency: String) {
        // TODO: convert amount
    }
    
}
