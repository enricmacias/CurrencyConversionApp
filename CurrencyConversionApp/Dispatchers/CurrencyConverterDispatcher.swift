final class CurrencyConverterDispatcher {

    static let shared = CurrencyConverterDispatcher()

    let currencies = DispatchSubject<[String: String]>()
    let usdRates = DispatchSubject<[String: Float]>()

}
