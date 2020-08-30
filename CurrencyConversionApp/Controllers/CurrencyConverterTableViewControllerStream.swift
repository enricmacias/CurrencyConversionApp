import RxSwift
import RxCocoa

final class CurrencyConverterTableViewControllerStream {

    let reloadTableView: Observable<Void>
    private let _reloadTableView = BehaviorRelay<Void>.init(value: ())
    
    fileprivate let disposeBag = DisposeBag()
    
    init(currencyConverterAction: CurrencyConverterAction = .shared,
         currencyConverterStore: CurrencyConverterStore = .shared) {
        
        self.reloadTableView = _reloadTableView.asObservable()
        
        currencyConverterStore.convertedRates.changed
            .map { _ in () }
            .bind(to: _reloadTableView)
            .disposed(by: disposeBag)
        
    }
}
