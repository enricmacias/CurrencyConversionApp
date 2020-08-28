import RxSwift
import RxCocoa

final class CurrencyCoverterStore {
    
    static let shared = CurrencyCoverterStore()
    
    let currencies: Observable<[String: String]>
    private let _currencies = BehaviorRelay<[String: String]>.init(value: [:])

    let usdRates: Observable<[String: Float]>
    private let _usdRates = BehaviorRelay<[String: Float]>.init(value: [:])
    
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
