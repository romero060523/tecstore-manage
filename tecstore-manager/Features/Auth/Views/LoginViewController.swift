// Pantalla de inicio de sesión 100% programática: solo bindings y UI, cero lógica de negocio.
import Combine
import UIKit
import SwiftUI

final class LoginViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: LoginViewModel
    private var cancellables = Set<AnyCancellable>()
    var onLoginSuccess: (() -> Void)?

    private var centerYConstraint: NSLayoutConstraint?
    private var bgGradientLayer: CAGradientLayer?
    private var buttonGradientLayer: CAGradientLayer?

    // MARK: - UI Elements

    private let logoImageView: UIImageView = {
        let iv = UIImageView()
        let config = UIImage.SymbolConfiguration(pointSize: 52, weight: .medium)
        iv.image = UIImage(systemName: "storefront.fill", withConfiguration: config)
        iv.tintColor = UIColor(AppColors.primary)
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "TecStore Manager"
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textColor = UIColor(AppColors.textPrimary)
        label.textAlignment = .center
        return label
    }()

    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Inicia sesión para continuar"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor(AppColors.textSecondary)
        label.textAlignment = .center
        return label
    }()

    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()

    private let loginButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("INICIAR SESIÓN", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.isEnabled = false
        button.alpha = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(AppColors.danger)
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        label.font = .systemFont(ofSize: 11, weight: .light)
        label.textColor = UIColor(AppColors.textTertiary)
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
        setupBackground()
        setupDecorativeElements()
        setupUI()
        bindViewModel()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        bgGradientLayer?.frame = view.bounds
        buttonGradientLayer?.frame = loginButton.bounds
    }

    // MARK: - Background

    private func setupBackground() {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.94, green: 0.96, blue: 1.00, alpha: 1).cgColor,
            UIColor.systemBackground.cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)
        gradient.frame      = view.bounds
        view.layer.insertSublayer(gradient, at: 0)
        bgGradientLayer = gradient
    }

    private func setupDecorativeElements() {
        // Large decorative circle (top-right)
        let circleView = UIView()
        circleView.backgroundColor = UIColor(AppColors.primary).withAlphaComponent(0.06)
        circleView.layer.cornerRadius = 160
        circleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circleView)
        NSLayoutConstraint.activate([
            circleView.widthAnchor.constraint(equalToConstant: 320),
            circleView.heightAnchor.constraint(equalToConstant: 320),
            circleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 100),
            circleView.topAnchor.constraint(equalTo: view.topAnchor, constant: -80)
        ])

        // Small decorative circle (bottom-left)
        let circleSmall = UIView()
        circleSmall.backgroundColor = UIColor(AppColors.purple).withAlphaComponent(0.06)
        circleSmall.layer.cornerRadius = 100
        circleSmall.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(circleSmall)
        NSLayoutConstraint.activate([
            circleSmall.widthAnchor.constraint(equalToConstant: 200),
            circleSmall.heightAnchor.constraint(equalToConstant: 200),
            circleSmall.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: -60),
            circleSmall.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 40)
        ])

        // Blur effect for depth
        let blurEffect = UIBlurEffect(style: .systemThinMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.alpha = 0.4
        blurView.layer.cornerRadius = 120
        blurView.clipsToBounds = true
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurView)
        NSLayoutConstraint.activate([
            blurView.widthAnchor.constraint(equalToConstant: 240),
            blurView.heightAnchor.constraint(equalToConstant: 240),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 80),
            blurView.topAnchor.constraint(equalTo: view.topAnchor, constant: -60)
        ])
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

        // Gradient button background
        let btnGradient = CAGradientLayer()
        btnGradient.colors = [
            UIColor(AppColors.primary).cgColor,
            UIColor(AppColors.purple).cgColor
        ]
        btnGradient.startPoint = CGPoint(x: 0, y: 0)
        btnGradient.endPoint   = CGPoint(x: 1, y: 1)
        loginButton.layer.insertSublayer(btnGradient, at: 0)
        buttonGradientLayer = btnGradient

        loginButton.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)

        // Activity indicator inside button
        loginButton.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loginButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: loginButton.centerYAnchor),

            usernameTextField.heightAnchor.constraint(equalToConstant: 54),
            passwordTextField.heightAnchor.constraint(equalToConstant: 54),
            loginButton.heightAnchor.constraint(equalToConstant: 54),
            logoImageView.heightAnchor.constraint(equalToConstant: 80)
        ])

        // Card container
        let cardView = UIView()
        cardView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.85)
        cardView.layer.cornerRadius = 24
        cardView.layer.shadowColor  = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset  = CGSize(width: 0, height: 8)
        cardView.layer.shadowRadius  = 20
        cardView.translatesAutoresizingMaskIntoConstraints = false

        let innerStack = UIStackView(arrangedSubviews: [
            usernameTextField,
            passwordTextField,
            loginButton,
            errorLabel
        ])
        innerStack.axis      = .vertical
        innerStack.spacing   = 16
        innerStack.alignment = .fill
        innerStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(innerStack)
        NSLayoutConstraint.activate([
            innerStack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            innerStack.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            innerStack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            innerStack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])

        // Main stack
        let stackView = UIStackView(arrangedSubviews: [
            logoImageView,
            titleLabel,
            subtitleLabel,
            makeSpacer(height: 8),
            cardView,
            makeFlexibleSpacer(),
            versionLabel
        ])
        stackView.axis      = .vertical
        stackView.spacing   = 12
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)

        centerYConstraint = stackView.centerYAnchor.constraint(
            equalTo: view.centerYAnchor, constant: -40
        )
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32),
            stackView.topAnchor.constraint(
                greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(
                lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            centerYConstraint!
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - ViewModel Bindings

    private func bindViewModel() {
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

        viewModel.$isLoginEnabled
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.loginButton.isEnabled = enabled
                UIView.animate(withDuration: 0.2) {
                    self?.loginButton.alpha = enabled ? 1.0 : 0.5
                }
            }
            .store(in: &cancellables)

        viewModel.$errorMessage
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.errorLabel.text = message
                UIView.animate(withDuration: 0.2) {
                    self?.errorLabel.isHidden = message == nil
                }
            }
            .store(in: &cancellables)

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
            self.centerYConstraint?.constant = -40
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
        textField.placeholder         = placeholder
        textField.isSecureTextEntry   = isSecure
        textField.autocapitalizationType = .none
        textField.autocorrectionType  = .no
        textField.returnKeyType       = returnKey
        textField.backgroundColor     = UIColor.systemGray6
        textField.layer.cornerRadius  = 14
        textField.layer.masksToBounds = false
        textField.layer.shadowColor   = UIColor.black.cgColor
        textField.layer.shadowOpacity = 0.04
        textField.layer.shadowOffset  = CGSize(width: 0, height: 2)
        textField.layer.shadowRadius  = 4
        textField.translatesAutoresizingMaskIntoConstraints = false

        let iconContainer = UIView(frame: CGRect(x: 0, y: 0, width: 46, height: 54))
        let iconView      = UIImageView(image: UIImage(systemName: iconName))
        iconView.tintColor     = UIColor(AppColors.textSecondary)
        iconView.contentMode   = .scaleAspectFit
        iconView.frame         = CGRect(x: 12, y: 15, width: 22, height: 24)
        iconContainer.addSubview(iconView)
        textField.leftView     = iconContainer
        textField.leftViewMode = .always

        let rightPad = UIView(frame: CGRect(x: 0, y: 0, width: 14, height: 54))
        textField.rightView     = rightPad
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
