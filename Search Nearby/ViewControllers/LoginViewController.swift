import UIKit

class LoginViewController<T: LoginViewPresenterType>: UIViewController {

    let loginButton = CustomButton(type: .custom)
    let progressView = ProgressView(frame: .zero)
    let errorLabel = UILabel(frame: .zero)

    let presenter: T

    init(presenter: T) {
        self.presenter = presenter
        super.init(nibName: nil,
                   bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presenter.attach(view: self)

        setupViews()
        createConstraints()
    }

    fileprivate func setupViews() {
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        progressView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(loginButton)
        view.addSubview(progressView)
        view.addSubview(errorLabel)
        
        loginButton.backgroundColor = .loginButtonBackground
        loginButton.unhighlightedColor = .loginButtonBackground
        loginButton.highlightedColor = .loginButtonHighlighted
        loginButton.addTarget(self,
                              action: #selector(touchUpInside),
                              for: .touchUpInside)

        loginButton.setTitleColor(.white,
                                  for: .normal)
        loginButton.titleLabel?.font = .loginButtonTitle
        loginButton.setTitle("Authorize FourSquare",
                             for: .normal)

        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorLabel.lineBreakMode = .byWordWrapping
        errorLabel.textColor = .red
        errorLabel.font = .smallButtonTitle

        loginButton.isHidden = false
        progressView.isHidden = true
        errorLabel.isHidden = true
    }

    fileprivate func createConstraints() {
        NSLayoutConstraint.activate([
            loginButton.widthAnchor.constraint(equalTo: view.widthAnchor,
                                               multiplier: 0.75),
            loginButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])

        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalTo: view.widthAnchor,
                                                multiplier: 0.5),
            progressView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            progressView.heightAnchor.constraint(equalTo: progressView.widthAnchor)
            ])

        NSLayoutConstraint.activate([
            errorLabel.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -20),
            errorLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8),
            errorLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8)
            ])
    }

    @objc func touchUpInside() {
        presenter.startAuthorization()
    }
}

extension LoginViewController: LoginViewType {

    func toggleProgress(from: UIView, to: UIView) {
        UIView.animate(withDuration: 0.25) {
            from.isHidden = true
            to.isHidden = false
        }
    }

    func handleLoginSuccess() {
        errorLabel.text = nil
        errorLabel.isHidden = true

        toggleProgress(from: progressView,
                       to: loginButton)

    }

    func showProgress() {
        toggleProgress(from: loginButton,
                            to: progressView)
    }

    func showError(error: String) {
        toggleProgress(from: progressView,
                       to: loginButton)
        errorLabel.text = error
        errorLabel.isHidden = false
    }
}
