import RxSwift
import RxCocoa

final class CurrencyCoverterStore {
    
    static let shared = CurrencyCoverterStore()
    
    let currencies: Observable<[Currency]>
    private let _currencies = BehaviorRelay<[Currency]>.init(value: [])

    let usdRates: Observable<[String: Double]>
    private let _usdRates = BehaviorRelay<[String: Double]>.init(value: [:])
    
    let disposeBag = DisposeBag()
    
    init(dispatcher: CurrencyConverterDispatcher = .shared) {
        self.currencies = _currencies.asObservable()
        self.usdRates = _usdRates.asObservable()
        
        dispatcher.currencies
            .bind(to: _currencies)
            .disposed(by: disposeBag)

        dispatcher.usdRates
            .bind(to: _usdRates)
            .disposed(by: disposeBag)
    }
}
