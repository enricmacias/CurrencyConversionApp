import RxSwift

protocol CurrencyConverterActionType: class {
    func fetchCurrencies()
    func fetchRates()
    func convert(_ amount: Float, from fromCurrency: String, to toCurrency: String)
}

final class CurrencyConverterAction: CurrencyConverterActionType {
    static let shared = CurrencyConverterAction()
    
    private let dispatcher: CurrencyConverterDispatcher
    
    fileprivate let disposeBag = DisposeBag()
    
    init(dispatcher: CurrencyConverterDispatcher = .shared) {
        self.dispatcher = dispatcher
    }
    
    func fetchCurrencies() {
        CurrencyLayerAPI.requestCurrenciesList()
            .map { $0.map { Currency(name: $0.value, code: $0.key)}}
            .subscribe(onNext: { [weak self] currencies in
                guard let me = self else { return }
                me.dispatcher.currencies.dispatch(currencies)
            })
            .disposed(by: disposeBag)
    }
    
    func fetchRates() {
        // TODO: fetchRates
    }
    
    func convert(_ amount: Float, from fromCurrency: String, to toCurrency: String) {
        // TODO: convert amount
    }
    
}
