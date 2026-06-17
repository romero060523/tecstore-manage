// Pantalla de inicio de sesión 100% programática: solo bindings y UI, cero lógica de negocio.
import Combine
import UIKit

final class LoginViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    var onLoginSuccess: (() -> Void)?

    private var centerYConstraint: NSLayoutConstraint?

    // MARK: - UI Elements

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .medium)
        iv.image = UIImage(systemName: "storefront.fill", withConfiguration: config)
        iv.tintColor = AppColors.primary
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TecStore Manager"
        label.font = AppFonts.title()
        label.textColor = AppColors.textPrimary
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()

    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("INICIAR SESIÓN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = AppFonts.body()
        button.backgroundColor = AppColors.primary
        button.layer.cornerRadius = 12
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = AppColors.error
        label.font = AppFonts.caption()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .medium)
        ai.color = .white
        ai.hidesWhenStopped = true
        ai.translatesAutoresizingMaskIntoConstraints = false
        return ai
    }()

    private let versionLabel: UILabel = {
        let label = UILabel()
        label.text = "v\(AppConstants.appVersion) — TECSUP 2026"
        label.font = AppFonts.caption()
        label.textColor = AppColors.textSecondary
        label.textAlignment = .center
        return label
    }()

    // MARK: - Init

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("LoginViewController must be initialized with init(viewModel:)")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColors.background
        setupUI()
        bindViewModel()
    }

    // MARK: - Setup

    private func setupUI() {
        configureTextField(
            usernameTextField,
            placeholder: "Usuario",
            iconName: "person.fill",
            returnKey: .next
        )
        configureTextField(
            passwordTextField,
            placeholder: "Contraseña",
            iconName: "lock.fill",
            isSecure: true,
            returnKey: .go
        )

        usernameTextField.delegate = self
        passwordTextField.delegate = self

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        // Activity indicator inside button
        loginButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            // Fixed heights
            usernameTextField.heightAnchor.constraint(equalToConstant: 50),
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Build stack
        let stackView = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            makeSpacer(height: 20),
            usernameTextField,
            passwordTextField,
            loginButton,
            errorLabel,
            makeFlexibleSpacer(),
            versionLabel
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        centerYConstraint = stackView.centerYAnchor.constraint(
            equalTo: view.centerYAnchor, constant: -50
        )
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            centerYConstraint!
        ])

        // Dismiss keyboard on tap
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        // Keyboard notifications
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
        // TextField → ViewModel
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: usernameTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .assign(to: \.username, on: viewModel)
            .store(in: &cancellables)

        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: passwordTextField)
            .map { ($0.object as? UITextField)?.text ?? "" }
            .assign(to: \.password, on: viewModel)
            .store(in: &cancellables)

        // isLoginEnabled → button appearance
        viewModel.$isLoginEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.loginButton.isEnabled = enabled
                UIView.animate(withDuration: 0.2) {
                    self?.loginButton.alpha = enabled ? 1.0 : 0.5
                }
            }
            .store(in: &cancellables)

        // errorMessage → error label
        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                UIView.animate(withDuration: 0.2) {
                    self?.errorLabel.isHidden = message == nil
                }
            }
            .store(in: &cancellables)

        // isLoading → activity indicator + button title
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] loading in
                guard let self else { return }
                if loading {
                    self.activityIndicator.startAnimating()
                    self.loginButton.setTitle("", for: .normal)
                    self.loginButton.isEnabled = false
                } else {
                    self.activityIndicator.stopAnimating()
                    self.loginButton.setTitle("INICIAR SESIÓN", for: .normal)
                    self.loginButton.isEnabled = self.viewModel.isLoginEnabled
                }
            }
            .store(in: &cancellables)

        // Propagate login success up to coordinator
        viewModel.onLoginSuccess = { [weak self] in
            self?.onLoginSuccess?()
        }
    }

    // MARK: - Actions

    @objc private func loginTapped() {
        viewModel.login()
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK: - Keyboard

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard
            let info     = notification.userInfo,
            let frame    = info[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.centerYConstraint?.constant = -(frame.height / 2)
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard
            let info     = notification.userInfo,
            let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double
        else { return }

        UIView.animate(withDuration: duration) {
            self.centerYConstraint?.constant = -50
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Helpers

    private func configureTextField(
        _ textField: UITextField,
        placeholder: String,
        iconName: String,
        isSecure: Bool = false,
        returnKey: UIReturnKeyType = .default
    ) {
        textField.placeholder = placeholder
        textField.isSecureTextEntry = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.returnKeyType = returnKey
        textField.backgroundColor = AppColors.secondaryBackground
        textField.layer.cornerRadius = 10
        textField.layer.masksToBounds = true
        textField.translatesAutoresizingMaskIntoConstraints = false

        // Left icon
        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 50))
        let iconView = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor = .secondaryLabel
        iconView.contentMode = .scaleAspectFit
        iconView.frame = CGRect(x: 10, y: 13, width: 22, height: 24)
        iconContainer.addSubview(iconView)
        textField.leftView = iconContainer
        textField.leftViewMode = .always

        // Right padding
        let rightPad = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 50))
        textField.rightView = rightPad
        textField.rightViewMode = .always
    }

    private func makeSpacer(height: CGFloat) -> UIView {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: height).isActive = true
        return v
    }

    private func makeFlexibleSpacer() -> UIView {
        let v = UIView()
        v.setContentHuggingPriority(.defaultLow - 1, for: .vertical)
        v.setContentCompressionResistancePriority(.defaultLow - 1, for: .vertical)
        return v
    }
}

// MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case usernameTextField:
            passwordTextField.becomeFirstResponder()
        case passwordTextField:
            textField.resignFirstResponder()
            if viewModel.isLoginEnabled { viewModel.login() }
        default:
            textField.resignFirstResponder()
        }
        return true
    }
}
