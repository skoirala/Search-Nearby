import UIKit
import MapKit

class VenueDetailViewController<T: VenuDetailPresenterType>: UIViewController {

    var imageView: UIImageView = UIImageView(frame: .zero)
    let openInMapsButton = CustomButton(frame: .zero)
    let showDirections = CustomButton(frame: .zero)
    let buttonContainer = UIStackView(frame: .zero)

    let presenter: T

    init(presenter: T) {
        self.presenter = presenter
        super.init(nibName: nil,
                   bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        openInMapsButton.layer.cornerRadius = openInMapsButton.bounds.height * 0.25
        showDirections.layer.cornerRadius = showDirections.bounds.height * 0.25
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter.attach(view: self)
        setupViews()
        setupConstraints()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.generateImage(size: CGSize(width: view.bounds.width,
                                             height: 200))
    }

    func setupViews() {
        view.backgroundColor = .white
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        openInMapsButton.translatesAutoresizingMaskIntoConstraints = false
        showDirections.translatesAutoresizingMaskIntoConstraints = false
        buttonContainer.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(imageView)
        view.addSubview(openInMapsButton)
        view.addSubview(showDirections)
        view.addSubview(buttonContainer)

        buttonContainer.addArrangedSubview(openInMapsButton)
        buttonContainer.addArrangedSubview(showDirections)

        buttonContainer.axis = .horizontal
        buttonContainer.distribution = .equalSpacing

        openInMapsButton.backgroundColor = .loginButtonBackground
        openInMapsButton.unhighlightedColor = .loginButtonBackground
        openInMapsButton.highlightedColor = .loginButtonHighlighted
        openInMapsButton.addTarget(self,
                                   action: #selector(openInMaps),
                                   for: .touchUpInside)

        openInMapsButton.setTitleColor(.white,
                                       for: .normal)
        openInMapsButton.titleLabel?.font = .smallButtonTitle
        openInMapsButton.setTitle("Open in maps",
                                  for: .normal)

        showDirections.backgroundColor = .loginButtonBackground
        showDirections.unhighlightedColor = .loginButtonBackground
        showDirections.highlightedColor = .loginButtonHighlighted
        showDirections.addTarget(self,
                                 action: #selector(showDirection),
                                 for: .touchUpInside)

        showDirections.setTitleColor(.white,
                                     for: .normal)
        showDirections.titleLabel?.font = .smallButtonTitle
        showDirections.setTitle("Show directions",
                                for: .normal)
    }

    func setupConstraints() {

        NSLayoutConstraint.activate([
            imageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            imageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 200)
            ])

        NSLayoutConstraint.activate([
            buttonContainer.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            buttonContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            buttonContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20)
            ])
    }

    @objc
    func openInMaps() {
        presenter.showInMaps()
    }

    @objc
    func showDirection() {
        presenter.showDirections()
    }
}

extension VenueDetailViewController: VenueDetailViewType {
    func detailSnapshotGenerated(image: UIImage) {
        DispatchQueue.main.async { [unowned self] in
            self.imageView.image = image
        }
    }
}
