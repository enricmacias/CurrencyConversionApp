import UIKit
import RxSwift

final class CurrencyConverterTableViewController: UITableViewController {

    // TODO: Make status bar opaque
    
    let conversorHeaderView: CurrencyConverterHeaderView? = {
        let view = Bundle.main.loadNibNamed("CurrencyConverterHeaderView", owner: self, options: nil)?[0] as? CurrencyConverterHeaderView
        return view
    }()

    lazy var currencyPicker: UIPickerView = {
        let picker = UIPickerView()
        let frame = CGRect(x: 0.0,
                           y: view.frame.size.height - picker.frame.size.height,
                           width: view.frame.width,
                           height: picker.frame.size.height)
        picker.frame = frame
        return picker
    }()
    
    lazy var loading: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0))
        indicator.style = .large
        indicator.center = self.tableView.center
        indicator.startAnimating()
        self.view.addSubview(indicator)
        return indicator
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
        
        navigationController?.navigationBar.isHidden = true
        viewStream.fetchCurrencies.execute()
        viewStream.fetchRates.execute()
        
        viewStream.currenciesNames
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
                if !isHidden {
                    me.conversorHeaderView?.amountTextField.becomeFirstResponder()
                }
            })
            .disposed(by: disposeBag)

        viewStream.isLoadingHidden
            .bind(to: loading.rx.isHidden)
            .disposed(by: disposeBag)
        
        viewStream.showError
            .filterNil()
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                guard let me = self else { return }
                let alert = UIAlertController(title: "Error",
                                              message: "Something went wrong! Please try again later!",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK",
                                              style: .default,
                                              handler: nil))
                me.present(alert, animated: true)
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
        return viewStream.convertedRates.value.count
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return conversorHeaderView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return conversorHeaderView?.frame.height ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath) as! CurrencyTableViewCell
        if let item = viewStream.convertedRates.value[safe: indexPath.row] {
            cell.confiugure(amount: String(item.amount), currency: item.symbol ?? item.code)
        }

        return cell
    }

}
