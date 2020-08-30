import RxSwift
import RxCocoa

final class CurrencyConverterStore {
    
    static let shared = CurrencyConverterStore()
    
    let currencies: Property<[Currency]>
    private let _currencies = BehaviorRelay<[Currency]>.init(value: [])

    let usdRates: Property<[String: Double]>
    private let _usdRates = BehaviorRelay<[String: Double]>.init(value: [:])

    let convertedRates: Property<[Currency]>
    private let _convertedRates = BehaviorRelay<[Currency]>.init(value: [])
    
    let disposeBag = DisposeBag()
    
    init(dispatcher: CurrencyConverterDispatcher = .shared) {
        self.currencies = Property(_currencies)
        self.usdRates = Property(_usdRates)
        self.convertedRates = Property(_convertedRates)
        
        dispatcher.currencies
            .bind(to: _currencies)
            .disposed(by: disposeBag)

        dispatcher.usdRates
            .bind(to: _usdRates)
            .disposed(by: disposeBag)

        dispatcher.convertedRates
            .bind(to: _convertedRates)
            .disposed(by: disposeBag)
    }
}
