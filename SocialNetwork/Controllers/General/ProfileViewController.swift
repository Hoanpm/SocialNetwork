import Combine
import UIKit
import SDWebImage

class ProfileViewController: UIViewController {
    
    private var viewModel: ProfileViewViewModel
    
    init(viewModel: ProfileViewViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    private var subscriptions : Set<AnyCancellable> =  []
    
    private let statusBar: UIView = {
       let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerView = ProfileTableViewHeader(frame: CGRect(x: 0, y: 0, width: profileTableView.frame.width, height: 390))
    
    private let profileTableView: UITableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: TweetTableViewCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Profile"
        view.addSubview(profileTableView)
        view.addSubview(statusBar)
        profileTableView.delegate = self
        profileTableView.dataSource = self
        profileTableView.tableHeaderView = headerView
        //profileTableView.contentInsetAdjustmentBehavior = .never
        navigationController?.navigationBar.isHidden = true
        configureConstraint()
        bindViews()
        viewModel.fetchUserTweet()
    }
    
    private func bindViews() {
        
        viewModel.$tweets.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.profileTableView.reloadData()
            }
        }
        .store(in: &subscriptions)
        
        viewModel.$user.sink{[weak self] user in
            
            self?.headerView.displayNameLabel.text = user.displayName
            self?.headerView.usernameLabel.text = "@\(user.username)"
            self?.headerView.followersCountLabel.text = "\(user.followersCount)"
            self?.headerView.followingCountLabel.text = "\(user.FollowingCount)"
            self?.headerView.userBioLabel.text = user.bio
            self?.headerView.profileAvatarImageView.sd_setImage(with: URL(string: user.avatarPath))
            self?.headerView.joinedDateLabel.text = "Joined \(self?.viewModel.getFormattedDate(with: user.createOn) ?? "")"
        }
        .store(in: &subscriptions)
        
        viewModel.$currentFollowingState.sink { [weak self] state in
            switch state {
            case .personal:
                self?.headerView.configureAsPersonal()
            case .userIsFollowed:
                self?.headerView.configureButtonAsUnFollowed()
            case .userIsUnFollowed:
                self?.headerView.configureButtonAsFollowed()
            }
        }
        .store(in: &subscriptions)
        
        headerView.followButtonActionPublisher.sink { [weak self] state in
            switch state {
            case .userIsFollowed:
                self?.viewModel.unFollow()
            case .userIsUnFollowed:
                self?.viewModel.follow()
            case .personal:
                return
            }
        }
        .store(in: &subscriptions)
    }
    
    private func configureConstraint() {
        let profileTableViewConstraint = [
            profileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            profileTableView.topAnchor.constraint(equalTo: view.topAnchor),
            profileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            profileTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
        let statusBarConstraint = [
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.topAnchor.constraint(equalTo: view.topAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: view.bounds.height > 800 ? 40 : 20)
        ]
        
        NSLayoutConstraint.activate(profileTableViewConstraint)
        NSLayoutConstraint.activate(statusBarConstraint)
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tweets.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier, for: indexPath) as? TweetTableViewCell else {
                return UITableViewCell()
            
        }
        
        let tweet = viewModel.tweets[indexPath.row]
        cell.configureTweet(with: tweet.author.displayName, userName: tweet.author.username, tweetTextContent: tweet.tweetContent, avatarPath: tweet.author.avatarPath)
        return cell
    }
    
}
