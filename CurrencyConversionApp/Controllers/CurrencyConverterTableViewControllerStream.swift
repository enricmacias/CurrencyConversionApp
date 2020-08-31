import RxSwift
import RxCocoa
import Action

final class CurrencyConverterTableViewControllerStream {

    // Output
    /// Variable containing all currencies names
    let currenciesNames: Observable<[String]>
    private let _currenciesNames = BehaviorRelay<[String]>.init(value:[])
    
    /// Variable containing the amount exchanged in all currencies
    let convertedRates: Property<[Currency]>
    private let _convertedRates = BehaviorRelay<[Currency]>.init(value:[])
    
    /// Variable that fires when the table view should be reloaded
    let reloadTableView: Observable<Void>
    private let _reloadTableView = BehaviorRelay<Void>.init(value: ())

    /// Variable that fires when the keyboard should be dismissed
    let dismissKeyboard: Observable<Void>
    private let _dismissKeyboard = BehaviorRelay<Void>.init(value: ())
    
    /// Variable that tells if the currency picker should be hidden or not
    let isCurrencyPickerHidden: Observable<Bool>
    private let _isCurrencyPickerHidden = BehaviorRelay<Bool>.init(value: true)

    /// Variable that tells if the loading should be hidden or not
    let isLoadingHidden: Observable<Bool>
    private let _isLoadingHidden = BehaviorRelay<Bool>.init(value: false)

    /// Variable containing the current selected currency
    let selectedCurrency: Observable<String>
    private let _selectedCurrency = BehaviorRelay<String>.init(value: "USD")
    
    let showError: Observable<Void?>
    private let _showError = BehaviorRelay<Void?>.init(value: nil)
    
    // State
    /// Variable containing all existent currencies to make a conversion
    let currencies: Observable<[Currency]>
    private let _currencies = BehaviorRelay<[Currency]>.init(value: [])
    
    /// Variable containing the most recent usd rates, can be used to exchange amount between currencies
    /// Rates are persisted locally (CurrencyConverterStore) and updated every 30 minutes
    let usdRates: Observable<[String: Double]>
    private let _usdRates = BehaviorRelay<[String: Double]>.init(value: [:])
    
    // Extra
    var fetchCurrencies: Action<Void, [Currency]>
    
    var fetchRates: Action<Void, [String: Double]>
    
    fileprivate let disposeBag = DisposeBag()
    
    init(currencyButtonTriggered: Observable<Void>,
         doneButtonTriggered: Observable<Void>,
         selectedRowInCurrencyPicker: Observable<Int>,
         amountTextFieldText: Observable<String?>) {
        
        self.currenciesNames = _currenciesNames.asObservable()
        self.convertedRates = Property(_convertedRates)
        self.reloadTableView = _reloadTableView.asObservable()
        self.dismissKeyboard = _dismissKeyboard.asObservable()
        self.isCurrencyPickerHidden = _isCurrencyPickerHidden.asObservable()
        self.isLoadingHidden = _isLoadingHidden.asObservable()
        self.selectedCurrency = _selectedCurrency.asObservable()
        self.showError = _showError.asObservable()
        
        self.usdRates = _usdRates.asObservable()
        self.currencies = _currencies.asObservable()
        
        // MARK - Fetching
        self.fetchCurrencies = Action { _ in
            return CurrencyLayerAPI.requestCurrenciesList()
                .map { $0.map { Currency(name: $0.value, code: $0.key) }}
        }

        self.fetchRates = Action { _ in
            return CurrencyLayerAPI.requestRates()
                .map { dic in
                    Dictionary<String, Double>(uniqueKeysWithValues: dic.map { item in
                        let key = item.key.replacingOccurrences(of: "USD", with: "")
                        return (key.isEmpty ? "USD" : key, item.value)
                    })
                }
        }
        
        // I assume that while the app is on the background rates don't need to be updated.
        // The timer will fire once if the app becomes active and the time has elapsed during background mode.
        Observable<Int>.interval(.seconds(1800), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] timer in
                guard let me = self else { return }
                me.fetchRates.execute()
            })
            .disposed(by: disposeBag)
        
        self.fetchCurrencies.elements
            .bind(to: _currencies)
            .disposed(by: disposeBag)
        
        self.fetchRates.elements
            .bind(to: _usdRates)
            .disposed(by: disposeBag)
        
        Observable.merge(self.fetchCurrencies.errors,
                         self.fetchRates.errors)
            .map { _ in () }
            .bind(to: _showError)
            .disposed(by: disposeBag)

        // MARK - Outputs
        Observable.merge(self.fetchCurrencies.executing,
            self.fetchRates.executing)
            .map{ !$0 }
            .bind(to: _isLoadingHidden)
            .disposed(by: disposeBag)
        
        _currencies
            .map { $0.map { $0.name } }
            .bind(to: _currenciesNames)
            .disposed(by: disposeBag)
        
        _convertedRates.skip(1)
            .map { _ in () }
            .bind(to: _reloadTableView)
            .disposed(by: disposeBag)

        Observable.merge(currencyButtonTriggered.map { _ in false },
                         doneButtonTriggered.map { _ in true })
            .bind(to: _isCurrencyPickerHidden)
            .disposed(by: disposeBag)

        doneButtonTriggered
            .bind(to: _dismissKeyboard)
            .disposed(by: disposeBag)

        selectedRowInCurrencyPicker
            .withLatestFrom(_currencies.asObservable()) { ($0, $1) }
            .map { $1[safe: $0]?.code }
            .filterNil()
            .bind(to: _selectedCurrency)
            .disposed(by: disposeBag)

        Observable.combineLatest(amountTextFieldText.filterNil().map { Double($0) ?? 0 },
                                 _selectedCurrency)
            .withLatestFrom(_usdRates) { ($0.0, $0.1, $1) }
            .map { amount, currency, usdRates in
                guard let currencyRate = usdRates[currency] else { return [] }
                let amountInUSD = currency == "USD" ? amount : amount/currencyRate
                return usdRates.map { Currency(code: $0.key, amount: $0.value * amountInUSD) }
            }
            .bind(to: _convertedRates)
            .disposed(by: disposeBag)
    }
}
