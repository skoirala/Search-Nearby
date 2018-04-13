import UIKit

class VenueCell: UITableViewCell {
    static let identifier = "VenueCellIdentifier"

    var iconImageView: UIImageView!
    var titleLabel: UILabel!
    var descriptionLabel: UILabel!
    var addressLabel: UILabel!

    var containerView: UIStackView!
    var labelsContainer: UIStackView!

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle,
                   reuseIdentifier: reuseIdentifier)
        createViews()
    }

    func createViews() {
        iconImageView = UIImageView(frame: .zero)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = UIColor.red

        titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byWordWrapping

        descriptionLabel = UILabel(frame: .zero)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping

        addressLabel = UILabel(frame: .zero)
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.numberOfLines = 0
        addressLabel.lineBreakMode = .byWordWrapping

        let spacingView = UIView()
        spacingView.translatesAutoresizingMaskIntoConstraints = false

        containerView = UIStackView(frame: .zero)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.axis = .horizontal
        containerView.addArrangedSubview(iconImageView)
        contentView.addSubview(containerView)

        labelsContainer = UIStackView(frame: .zero)
        labelsContainer.translatesAutoresizingMaskIntoConstraints = false
        labelsContainer.axis = .vertical
        labelsContainer.spacing = 4
        labelsContainer.addArrangedSubview(titleLabel)
        labelsContainer.addArrangedSubview(descriptionLabel)
        labelsContainer.addArrangedSubview(addressLabel)
        containerView.addArrangedSubview(labelsContainer)

        iconImageView.widthAnchor.constraint(equalToConstant: 88.0).isActive = true

        let views: [String: Any] = ["containerView": containerView]
        let hFormat = "H:|[containerView]|"
        let vFormat = "V:|-[containerView]-|"

        [hFormat, vFormat].forEach { format in
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format,
                                                                      options: [],
                                                                      metrics: nil,
                                                                      views: views))
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.titleLabel.preferredMaxLayoutWidth = labelsContainer.bounds.width
        self.descriptionLabel.preferredMaxLayoutWidth = labelsContainer.bounds.width
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
}
