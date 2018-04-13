import UIKit

class LoginViewController<T: LoginViewPresenterType>: UIViewController {

    let loginButton = CustomButton(type: .custom)
    let progressView = ProgressView(frame: .zero)

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

        view.addSubview(loginButton)
        view.addSubview(progressView)

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

        loginButton.isHidden = false
        progressView.isHidden = true
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
    }

    @objc func touchUpInside() {
        presenter.startAuthorization()
    }
}

extension LoginViewController: LoginViewType {

    func toggleLoginProgress() {
        UIView.transition(from: loginButton,
                          to: progressView,
                          duration: 0.5,
                          options: .showHideTransitionViews)

    }

    func handleLoginSuccess(with credentials: OauthCredential) {
        toggleLoginProgress()
        presenter.handleLoginSuccess()
    }

    func showProgress() {
        toggleLoginProgress()
    }

    func showError(error: String) {
        toggleLoginProgress()
    }
}
