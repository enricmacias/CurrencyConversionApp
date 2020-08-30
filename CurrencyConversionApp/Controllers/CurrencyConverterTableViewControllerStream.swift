import RxSwift
import RxCocoa

final class CurrencyConverterTableViewControllerStream {

    let currenciesNames: Observable<[String]>
    private let _currenciesNames = BehaviorRelay<[String]>.init(value:[])
    
    let convertedRates: Property<[Currency]>
    private let _convertedRates = BehaviorRelay<[Currency]>.init(value:[])
    
    let reloadTableView: Observable<Void>
    private let _reloadTableView = BehaviorRelay<Void>.init(value: ())

    let dismissKeyboard: Observable<Void>
    private let _dismissKeyboard = BehaviorRelay<Void>.init(value: ())
    
    let isCurrencyPickerHidden: Observable<Bool>
    private let _isCurrencyPickerHidden = BehaviorRelay<Bool>.init(value: true)

    let selectedCurrency: Observable<String>
    private let _selectedCurrency = BehaviorRelay<String>.init(value: "USD")
    
    fileprivate let disposeBag = DisposeBag()
    
    init(currencyButtonTriggered: Observable<Void>,
         doneButtonTriggered: Observable<Void>,
         selectedRowInCurrencyPicker: Observable<Int>,
         amountTextFieldText: Observable<String?>,
         currencyConverterAction: CurrencyConverterAction = .shared,
         currencyConverterStore: CurrencyConverterStore = .shared) {
        
        self.currenciesNames = _currenciesNames.asObservable()
        self.convertedRates = Property(_convertedRates)
        self.reloadTableView = _reloadTableView.asObservable()
        self.dismissKeyboard = _dismissKeyboard.asObservable()
        self.isCurrencyPickerHidden = _isCurrencyPickerHidden.asObservable()
        self.selectedCurrency = _selectedCurrency.asObservable()
        
        currencyConverterStore.currencies.asObservable()
            .map { $0.map { $0.name } }
            .bind(to: _currenciesNames)
            .disposed(by: disposeBag)

        currencyConverterStore.convertedRates.asObservable()
            .bind(to: _convertedRates)
            .disposed(by: disposeBag)
        
        currencyConverterStore.convertedRates.changed
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
            .withLatestFrom(currencyConverterStore.currencies.asObservable()) { ($0, $1) }
            .map { $1[safe: $0]?.code }
            .filterNil()
            .bind(to: _selectedCurrency)
            .disposed(by: disposeBag)

        Observable.combineLatest(amountTextFieldText.filterNil().map { Double($0) ?? 0 },
                                 _selectedCurrency)
            .subscribe(onNext: { [currencyConverterAction] amount, currencyCode in
                currencyConverterAction.convert(amount, from: currencyCode)
            })
            .disposed(by: disposeBag)
    }
}
