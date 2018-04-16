import UIKit

typealias SearchVenueViewControllerType = (UITableViewController & UISearchBarDelegate)

class SearchVenueViewController<T: SearchVenuePresenterType>: SearchVenueViewControllerType {
    
    let presenter: T

    init(presenter: T) {
        self.presenter = presenter
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var emptyBackgroundView: UIView!
    var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()

         searchBar = UISearchBar(frame: CGRect(x: 0,
                                                  y: 0,
                                                  width: view.bounds.width,
                                                  height: 44.0))
        searchBar.delegate = self
        
        tableView.tableHeaderView = searchBar
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 44
        tableView.tableFooterView = UIView(frame: .zero)
        
        tableView.register(VenueCell.self,
                           forCellReuseIdentifier: VenueCell.identifier)

        emptyBackgroundView = UIView(frame: .zero)
        emptyBackgroundView.backgroundColor = UIColor.groupTableViewBackground

        let tapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                          action: #selector(tapped))
        tapGestureRecognizer.cancelsTouchesInView = false

        view.addGestureRecognizer(tapGestureRecognizer)

        let emptyLabel = UILabel(frame: .zero)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyLabel.text = "No result"
        emptyLabel.font = UIFont(name: "Arial", size: 20.0)

        emptyBackgroundView.addSubview(emptyLabel)

        NSLayoutConstraint.activate([emptyLabel.centerXAnchor.constraint(equalTo: emptyBackgroundView.centerXAnchor),
        emptyLabel.centerYAnchor.constraint(equalTo: emptyBackgroundView.centerYAnchor)])

        presenter.attach(view: self)
    }

    @objc func tapped() {
        if searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }

    // MARK: UITableViewDataSource
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter.numberOfItems()
    }

    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: VenueCell.identifier,
                                                       for: indexPath)
        guard let venueCell = cell as? VenueCell else {
            return cell
        }

        let displayResult = presenter.item(at: indexPath.row)
        venueCell.titleLabel?.text = displayResult.name
        venueCell.addressLabel.text = displayResult.address
        venueCell.descriptionLabel.text = displayResult.categoryName
        venueCell.iconImageView.image = presenter.image(at: indexPath.row)?.withRenderingMode(.alwaysTemplate)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.itemSelected(at: indexPath.row)
    }

    // MARK: UISearchBarDelegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter.search(for: searchText)
    }
}

// MARK: SearchVenueViewType
extension SearchVenueViewController: SearchVenueViewType {

    func searchResultChanged() {
        
        if presenter.numberOfItems() == 0 {
            tableView.backgroundView = emptyBackgroundView
        } else {
            tableView.backgroundView = nil
        }

        tableView.reloadData()
    }

    func imageDownloadFinished(image: UIImage, for urlString: String) {
        // multiple cells and items can have same image url and same image
        tableView.indexPathsForVisibleRows?.forEach { [unowned self]  indexPath in

            let displayResult = self.presenter.item(at: indexPath.row)

            guard let imageUrl = displayResult.imageUrl else {
                return
            }

            guard let cell = self.tableView.cellForRow(at: indexPath) as? VenueCell else {
                return
            }

            if imageUrl == urlString {
                cell.iconImageView.image = image.withRenderingMode(.alwaysTemplate)
            }
        }
    }
}
