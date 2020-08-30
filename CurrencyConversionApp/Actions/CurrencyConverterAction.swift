import RxSwift

protocol CurrencyConverterActionType: class {
    func fetchCurrencies()
    func fetchRates()
    func convert(_ amount: Double, from currency: String)
}

final class CurrencyConverterAction: CurrencyConverterActionType {
    static let shared = CurrencyConverterAction()
    
    private let dispatcher: CurrencyConverterDispatcher
    private let store: CurrencyConverterStore
    
    fileprivate let disposeBag = DisposeBag()
    
    init(dispatcher: CurrencyConverterDispatcher = .shared,
         store: CurrencyConverterStore = .shared) {
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
            .map { dic in
                Dictionary<String, Double>(uniqueKeysWithValues: dic.map { item in
                    let key = item.key.replacingOccurrences(of: "USD", with: "")
                    return (key.isEmpty ? "USD" : key, item.value)
                })
            }
            .subscribe(onNext: { [weak self] rates in
                guard let me = self else { return }
                me.dispatcher.usdRates.dispatch(rates)
            })
            .disposed(by: disposeBag)
    }
    
    func convert(_ amount: Double, from currency: String) {
        store.usdRates.asObservable()
            .map { usdRates -> [Currency] in
                guard let currencyRate = usdRates[currency] else { return [] }
                let amountInUSD = currency == "USD" ? amount : amount/currencyRate
                return usdRates.map { Currency(code: $0.key, amount: $0.value * amountInUSD) }
            }
            .subscribe(onNext: { [weak self] rates in
                guard let me = self else { return }
                me.dispatcher.convertedRates.dispatch(rates)
            })
            .disposed(by: disposeBag)
    }
    
}
