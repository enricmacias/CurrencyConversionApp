import RxSwift

protocol CurrencyConverterActionType: class {
    func fetchCurrencies()
    func fetchRates()
    func convert(_ amount: Double, from currency: String)
}

final class CurrencyConverterAction: CurrencyConverterActionType {
    static let shared = CurrencyConverterAction()
    
    private let dispatcher: CurrencyConverterDispatcher
    private let store: CurrencyCoverterStore
    
    fileprivate let disposeBag = DisposeBag()
    
    init(dispatcher: CurrencyConverterDispatcher = .shared,
         store: CurrencyCoverterStore = .shared) {
        self.dispatcher = dispatcher
        self.store = store
    }
    
    func fetchCurrencies() {
        CurrencyLayerAPI.requestCurrenciesList()
            .map { $0.map { Currency(name: $0.value, code: $0.key) }}
            .subscribe(onNext: { [weak self] currencies in
                guard let me = self else { return }
                me.dispatcher.currencies.dispatch(currencies)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchRates() {
        CurrencyLayerAPI.requestRates()
            .map { Dictionary(uniqueKeysWithValues: $0.map { ($0.key.replacingOccurrences(of: "USD", with: ""), $0.value) }) }
            .subscribe(onNext: { [weak self] rates in
                guard let me = self else { return }
                me.dispatcher.usdRates.dispatch(rates)
            })
            .disposed(by: disposeBag)
    }
    
    func convert(_ amount: Double, from currency: String) {
        store.usdRates
            .map { usdRates -> [String:Double] in
                guard let currencyRate = usdRates[currency] else { return [:] }
                let amountInUSD = currency == "USD" ? amount : amount/currencyRate
                return Dictionary(uniqueKeysWithValues: usdRates.map { ($0.key, $0.value * amountInUSD) })
            }
            .subscribe(onNext: { [weak self] rates in
                guard let me = self else { return }
                me.dispatcher.covertedRates.dispatch(rates)
            })
            .disposed(by: disposeBag)
    }
    
}
