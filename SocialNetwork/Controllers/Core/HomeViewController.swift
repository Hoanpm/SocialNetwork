

import UIKit

class HomeViewController: UIViewController {
    
    private let timelineTableView = {
        let tableView = UITableView()
        tableView.register(TweetTableViewCell.self,  forCellReuseIdentifier: TweetTableViewCell.identifier)
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(timelineTableView)
        timelineTableView.dataSource = self
        timelineTableView.delegate = self
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        timelineTableView.frame = view.frame
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.identifier , for: indexPath) as? TweetTableViewCell else {	 
            return UITableViewCell()
        }
        cell.selectionStyle = .none
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
