import UIKit
import RxSwift

final class CurrencyConverterTableViewController: UITableViewController {

    let conversorHeaderView = Bundle.main.loadNibNamed("CurrencyConverterHeaderView", owner: self, options: nil)?[0] as? UIView
    
    private lazy var viewStream: CurrencyConverterTableViewControllerStream = {
        return CurrencyConverterTableViewControllerStream()
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 100
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return conversorHeaderView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return conversorHeaderView?.frame.height ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrencyTableViewCell", for: indexPath)

        // Configure the cell...

        return cell
    }

}
