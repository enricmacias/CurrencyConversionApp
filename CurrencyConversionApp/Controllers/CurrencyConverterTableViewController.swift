import UIKit
import RxSwift

final class CurrencyConverterTableViewController: UITableViewController {

    lazy var conversorHeaderView: CurrencyConverterHeaderView? = {
        let view = Bundle.main.loadNibNamed("CurrencyConverterHeaderView", owner: self, options: nil)?[0] as? CurrencyConverterHeaderView
        view?.amountTextField.delegate = self
        return view
    }()
    
    private lazy var viewStream: CurrencyConverterTableViewControllerStream = {
        return CurrencyConverterTableViewControllerStream()
    }()
    
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        CurrencyConverterAction.shared.fetchCurrencies()
        CurrencyConverterAction.shared.fetchRates()
        
        viewStream.reloadTableView
            .observeOn(ConcurrentMainScheduler.instance)
            .subscribe { [weak self] _ in
                guard let me = self else { return }
                me.tableView.reloadData()
            }
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

extension CurrencyConverterTableViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text,
           let textRange = Range(range, in: text) {
           let updatedText = text.replacingCharacters(in: textRange,
                                                       with: string)
           CurrencyConverterAction.shared.convert(Double(updatedText) ?? 0, from: "USD")
        }
        return true
    }
}
