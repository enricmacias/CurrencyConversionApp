import UIKit
import RxSwift

final class CurrencyConverterTableViewController: UITableViewController {

    let conversorHeaderView: CurrencyConverterHeaderView? = {
        let view = Bundle.main.loadNibNamed("CurrencyConverterHeaderView", owner: self, options: nil)?[0] as? CurrencyConverterHeaderView
        return view
    }()

    // TODO: Select USD as default
    lazy var currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        let frame = CGRect(x: 0.0,
                           y: view.frame.size.height - picker.frame.size.height,
                           width: view.frame.width,
                           height: picker.frame.size.height)
        picker.frame = frame
        return picker
    }()
    
    private lazy var viewStream: CurrencyConverterTableViewControllerStream = {
        let currencyButtonTriggered = conversorHeaderView?.currencyButton.rx.tap.map { _ in () } ?? .empty()
        let doneButtonTriggered = conversorHeaderView?.doneButton.rx.tap.map { _ in () } ?? .empty()
        let selectedRowInCurrencyPicker = currencyPicker.rx.itemSelected.map { $0.row }
        let amountTextFieldText = conversorHeaderView?.amountTextField.rx.text.asObservable() ?? .empty()
        return CurrencyConverterTableViewControllerStream(currencyButtonTriggered: currencyButtonTriggered,
                                                          doneButtonTriggered: doneButtonTriggered,
                                                          selectedRowInCurrencyPicker: selectedRowInCurrencyPicker,
                                                          amountTextFieldText: amountTextFieldText)
    }()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // TODO : Fetch currencies on app start?
        CurrencyConverterAction.shared.fetchCurrencies()
        // TODO : Fetch rates every 30 min and save it in user defaults
        CurrencyConverterAction.shared.fetchRates()
        
        // TODO: get store values from stream?
        CurrencyConverterStore.shared.currencies.asObservable()
            .map { $0.map { $0.name } }
            .bind(to: currencyPicker.rx.itemTitles) { _, item in
                return "\(item)"
            }
            .disposed(by: disposeBag)
        
        viewStream.reloadTableView
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.tableView.reloadData()
            }
            .disposed(by: disposeBag)

        viewStream.dismissKeyboard
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.view.endEditing(true)
            }
            .disposed(by: disposeBag)

        viewStream.isCurrencyPickerHidden
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] isHidden in
                guard let me = self else { return }
                me.conversorHeaderView?.amountTextField.inputView = isHidden ? nil : me.currencyPicker
                me.conversorHeaderView?.amountTextField.reloadInputViews()
            })
            .disposed(by: disposeBag)

        // TODO: Show symbol instead of currency code
        viewStream.selectedCurrency
            .bind(to: conversorHeaderView!.currencyButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CurrencyConverterStore.shared.convertedRates.value.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return conversorHeaderView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return conversorHeaderView?.frame.height ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath) as! CurrencyTableViewCell
        if let item = CurrencyConverterStore.shared.convertedRates.value[safe: indexPath.row] {
            cell.confiugure(amount: String(item.amount), currency: item.symbol ?? item.code)
        }

        return cell
    }

}
