
import Combine
import UIKit
import FirebaseAuth

class HomeViewController: UIViewController {
    
    private var viewmodel = HomeViewViewModel()
    
    private var subscriptions: Set<AnyCancellable> = []
    
    private lazy var composeTweetButton: UIButton = {
        let button = UIButton(type: .system, primaryAction: UIAction { [weak self] _ in
            self?.navigateToTweetComposer()
        })
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .SnsBlueColor
        button.tintColor = .white
        let plusSign = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        button.setImage(plusSign, for: .normal)
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
    
    private func configureNavigationBar() {
        let size = 20
//        let logoImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: size, height: size))
//        logoImageView.contentMode = .scaleAspectFill
//        logoImageView.image = UIImage(named:"imagename1")
        
        let middleView = UIView(frame: CGRect(x: 0, y: 0, width: size, height: size))
        //		middleView.addSubview(logoImageView)
        navigationItem.titleView = middleView
        
        let profileImage = UIImage(systemName: "person")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: profileImage, style: .plain, target: self, action: #selector(didTapProfile))
    }
    
    @objc func didTapProfile() {
        guard let user = viewmodel.user else { return }
        let profileViewModel = ProfileViewViewModel(user: user)
        let vc = ProfileViewController(viewModel: profileViewModel)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private let timelineTableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self,  forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(timelineTableView)
        view.addSubview(composeTweetButton)
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        configureNavigationBar()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), style: .plain, target: self, action: #selector(didTapSignOut))
        bindViews()
        
    }
    
    @objc func didTapSignOut() {
        try? Auth.auth().signOut()
        handleAuthentication()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
        configureConstraints()
    }
    
    private func handleAuthentication() {
        if Auth.auth().currentUser == nil {
            let vc = UINavigationController(rootViewController: OnboardingViewController())
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: false)
        }
    }
    
    private func navigateToTweetComposer() {
        let vc = UINavigationController(rootViewController: TweetComposeViewController())
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        handleAuthentication()
        viewmodel.retreiveUser()
    }
    
    func completeUserOnBoarding() {
        let vc =  ProfileDataFormViewController()
        present(vc, animated: true)
    }
    
    func bindViews() {
        viewmodel.$user.sink { [weak self] user in
            guard let user = user else { return }
            if !user.isUserOnboarded {
                self?.completeUserOnBoarding()
            }
        }
        .store(in: &subscriptions)
        
        viewmodel.$tweets.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.timelineTableView.reloadData()
            }
        }
        .store(in: &subscriptions)
    }
    
    private func configureConstraints() {
        let composeTweetButtonConstraint = [
            composeTweetButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -25),
            composeTweetButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -120),
            composeTweetButton.widthAnchor.constraint(equalToConstant: 60),
            composeTweetButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        NSLayoutConstraint.activate(composeTweetButtonConstraint)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewmodel.tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier , for: indexPath) as? TweetTableViewCell else {
            return UITableViewCell()
        }
        
        let tweetModel = viewmodel.tweets[indexPath.row]
        cell.configureTweet(with: tweetModel.author.displayName,
                            userName: tweetModel.author.username,
                            tweetTextContent: tweetModel.tweetContent,
                            avatarPath: tweetModel.author.avatarPath)
        cell.delegate = self
        return cell
    }
}

extension HomeViewController: TweetTableViewCellDelegate {
    func tweetTableViewCellDidTapReply() {
        print("oke")
    }
    
    func tweetTableViewCellDidTapRetweet() {
        print("oke1")
    }
    
    func tweetTableViewCellDidTapLike() {
        print("oke2")
    }
    
    func tweetTableViewCellDidTapShare() {
        print("oke3")
    }
    
    
}
