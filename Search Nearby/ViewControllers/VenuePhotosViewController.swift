import UIKit

class VenuePhotoViewController<T: VenuePhotoPresenterType>: UICollectionViewController, PinterestLayoutDelegate {

    var emptyBackgroundView: UIView!
    var responseIndicatorLabel: UILabel!

    var loadingIndicatorView: UIActivityIndicatorView!

    let presenter: T

    init(presenter: T) {
        self.presenter = presenter
        let layout = PinterestLayout()
        super.init(collectionViewLayout: layout)
        layout.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        presenter.attach(view: self)

        title = presenter.venueTitle()
    }

    func setupViews() {
        let mapButton = UIBarButtonItem(title: "Maps",
                                        style: .plain,
                                        target: self,
                                        action: #selector(showMaps))
        navigationItem.rightBarButtonItem = mapButton

        collectionView?.register(VenuePhotoCollectionCell.self,
                                 forCellWithReuseIdentifier: VenuePhotoCollectionCell.identifier)
        loadingIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicatorView.color = .white
        loadingIndicatorView.hidesWhenStopped = true
        view.addSubview(loadingIndicatorView)

        emptyBackgroundView = UIView(frame: .zero)
        emptyBackgroundView.backgroundColor = UIColor.clear

        responseIndicatorLabel = UILabel(frame: .zero)
        responseIndicatorLabel.textColor = .white
        responseIndicatorLabel.translatesAutoresizingMaskIntoConstraints = false
        responseIndicatorLabel.text = "No photos"
        responseIndicatorLabel.font = UIFont(name: "ArialRoundedMTBold", size: 20.0)

        emptyBackgroundView.addSubview(responseIndicatorLabel)

        NSLayoutConstraint.activate([responseIndicatorLabel.centerXAnchor.constraint(equalTo: emptyBackgroundView.centerXAnchor),
                                     responseIndicatorLabel.centerYAnchor.constraint(equalTo: emptyBackgroundView.centerYAnchor)])

        NSLayoutConstraint.activate([loadingIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                                     loadingIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)])
    }

    @objc func showMaps() {
        presenter.showMaps()
    }

    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView,
                                 numberOfItemsInSection section: Int) -> Int {
        return presenter.numberOfVenuePhotos()
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VenuePhotoCollectionCell.identifier,
                                                      for: indexPath) as! VenuePhotoCollectionCell
        if let image = presenter.imageForVenuePhoto(at: indexPath.item) {
            cell.imageView.image = image
            cell.activityIndicatorView.stopAnimating()
        } else {
            cell.activityIndicatorView.startAnimating()
            cell.imageView.image = nil
        }
        return cell
    }

    override func collectionView(_ collectionView: UICollectionView,
                                 didSelectItemAt indexPath: IndexPath) {
        presenter.showPhotoViewer(at: indexPath.item)
    }

    // MARK: UISrollViewDelegate
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            setImageForVisibleIndexPaths()
        }
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if !scrollView.isDragging && !scrollView.isDecelerating {
            setImageForVisibleIndexPaths()
        }
    }

    func setImageForVisibleIndexPaths() {
        for indexPath in collectionView?.indexPathsForVisibleItems ?? [] {

            guard let cell = collectionView?.cellForItem(at: indexPath) as? VenuePhotoCollectionCell, let image = presenter.imageForVenuePhoto(at: indexPath.item) else {
                continue
            }
            if cell.imageView.image == nil {
                UIView.transition(with: cell.imageView, duration: 0.33, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {

                    cell.activityIndicatorView.stopAnimating()
                    cell.imageView.image = image
                })
            }
        }
    }

    // MARK: PinInterestLayoutDelegate

    func heightOfItem(at layout: PinterestLayout, indexPath: IndexPath) -> CGFloat {
        let size = presenter.sizeForVenuePhoto(at: indexPath.item)

        let width = collectionView!.bounds.width

        let itemsInColumn: CGFloat = 2
        let itemWidth = (width  - collectionView!.contentInset.left - collectionView!.contentInset.right - layout.sectionInset.left - layout.sectionInset.right - layout.interItemSpacing) / itemsInColumn

        let sizeRatio = CGFloat(size.height) / CGFloat(size.width)
        return sizeRatio * itemWidth
    }
}

extension VenuePhotoViewController: VenuePhotoViewType {

    func venuePhotosLoadingStarted() {
        collectionView?.backgroundView = nil
        loadingIndicatorView.startAnimating()
    }

    func venuePhotosLoaded() {
        loadingIndicatorView.stopAnimating()
        collectionView?.backgroundView = nil
        collectionView?.reloadData()
    }

    func venuePhotoLoading(failed error: Error) {
        responseIndicatorLabel.text = error.localizedDescription
        collectionView?.backgroundView = emptyBackgroundView
        loadingIndicatorView.stopAnimating()
    }

    func venuePhotoLoadingReturnedEmpty() {
        loadingIndicatorView.stopAnimating()
        responseIndicatorLabel.text = "No photos"
        collectionView?.backgroundView = emptyBackgroundView
    }

    func image(_ image: UIImage, downloadedAt index: Int) {
        let indexPath = IndexPath(row: index, section: 0)

        guard let cell = collectionView?.cellForItem(at: indexPath) as? VenuePhotoCollectionCell else {
            return
        }

        UIView.transition(with: cell.imageView, duration: 0.33, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
            cell.imageView.image = image
            cell.activityIndicatorView.stopAnimating()
        }, completion: nil)
    }
}
