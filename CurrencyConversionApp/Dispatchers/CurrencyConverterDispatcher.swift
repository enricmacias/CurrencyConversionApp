final class CurrencyConverterDispatcher {

    static let shared = CurrencyConverterDispatcher()

    let currencies = DispatchSubject<[Currency]>()
    let usdRates = DispatchSubject<[String: Double]>()
    let covertedRates = DispatchSubject<[String: Double]>()

}
