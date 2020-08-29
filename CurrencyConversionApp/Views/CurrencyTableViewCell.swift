import UIKit

class CurrencyTableViewCell: UITableViewCell {

    @IBOutlet private weak var amountLabel: UILabel!
    @IBOutlet private weak var currencyLabel: UILabel!
    
    func confiugure(amount: String,
                    currency: String) {
        amountLabel.text = amount
        currencyLabel.text = currency
    }

}
