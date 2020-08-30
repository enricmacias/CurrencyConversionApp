import UIKit

class CurrencyConverterHeaderView: UIView {
    
    @IBOutlet weak var amountTextField: UITextField! {
        didSet{
            let toolbar = UIToolbar(frame:  CGRect(origin: .zero,
                                                   size: .init(width: frame.size.width, height: 30)))
            let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil,
                                            action: nil)
            toolbar.setItems([flexSpace, doneButton], animated: false)
            toolbar.sizeToFit()
            
            amountTextField.inputAccessoryView = toolbar
        }
    }
    @IBOutlet weak var currencyButton: UIButton!
    
    lazy var doneButton: UIBarButtonItem = {
        return UIBarButtonItem(title: "Done",
                               style: .done,
                               target: nil,
                               action: nil)
    }()
}
