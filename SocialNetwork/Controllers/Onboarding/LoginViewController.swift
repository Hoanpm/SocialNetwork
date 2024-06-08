
import Combine
import UIKit

class LoginViewController: UIViewController {
    
    private var viewmodel = AuthenticationViewViewModel()
    
    private var subscription : Set<AnyCancellable> = []
    
    private let LoginTittleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Login to your account"
        label.font = .systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    
    private let emailTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = .emailAddress
        textField.attributedPlaceholder = NSAttributedString (
            string: "Email",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray]
        )
        return textField
    }()
    
    private let passwordTextField : UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.attributedPlaceholder = NSAttributedString (
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.gray]
        )
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let LoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Login", for: .normal)
        button.tintColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        button.backgroundColor = .SnsBlueColor
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 25
        button.isEnabled = false
        return button
    }()
    
    @objc private func didChangeEmailField() {
        viewmodel.email = emailTextField.text
        viewmodel.validateAuthenticationForm()
    }
    
    @objc private func didChangePasswordField() {
        viewmodel.password = passwordTextField.text
        viewmodel.validateAuthenticationForm()
    }
    
    private func bindView() {
        emailTextField.addTarget(self, action: #selector(didChangeEmailField), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(didChangePasswordField), for: .editingChanged)
        viewmodel.$isAuthenticationFormValid.sink { [weak self] validationState in
            self?.LoginButton.isEnabled = validationState
        }
        
        .store(in: &subscription)
        
        viewmodel.$user.sink { [weak self] user in
            guard user != nil else  { return }
            guard let vc = self?.navigationController?.viewControllers.first as? OnboardingViewController else { return }
            vc.dismiss(animated: true)
        }
        .store(in: &subscription)
        
        viewmodel.$error.sink { [weak self] errorString in
            guard let error = errorString else { return }
            self?.presentAlert(with: error)
        }
        .store(in: &subscription)
    }
    
    private func presentAlert(with error :String) {
        let alert = UIAlertController(title: "Error", message: "Login information is not correct", preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(LoginTittleLabel)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(LoginButton)
        LoginButton.addTarget(self, action: #selector(didTapLogin), for: .touchUpInside)
        configureConstraint()
        bindView()
    }
    
    @objc private func didTapLogin() {
        viewmodel.loginUser()
    }
    
    private func configureConstraint() {
        let LoginTittleLabelConstraint = [
            LoginTittleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            LoginTittleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor,constant: 20),
        ]
        
        let emailTextFieldConstraint = [
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 20),
            emailTextField.topAnchor.constraint(equalTo: LoginTittleLabel.bottomAnchor, constant: 20),
            emailTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let passwordFieldConstraint = [
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 15),
            passwordTextField.widthAnchor.constraint(equalToConstant: view.frame.width - 40),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let LoginButtonConstraint = [
            LoginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            LoginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            LoginButton.widthAnchor.constraint(equalToConstant: 180),
            LoginButton.heightAnchor.constraint(equalToConstant: 50)
        ]
        
        NSLayoutConstraint.activate(LoginTittleLabelConstraint)
        NSLayoutConstraint.activate(emailTextFieldConstraint)
        NSLayoutConstraint.activate(passwordFieldConstraint)
        NSLayoutConstraint.activate(LoginButtonConstraint)
    }
    
}
