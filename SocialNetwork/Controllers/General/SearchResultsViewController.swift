

import UIKit

class SearchResultsViewController: UIViewController {
    
    var users: [SnsUser] = []
    
    private let searchResultsTableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.identifier)
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(searchResultsTableView)
        configureConstraints()
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
    }
    
    func update(users: [SnsUser]) {
           self.users = users
           DispatchQueue.main.async { [weak self] in
               self?.searchResultsTableView.reloadData()
           }
       }
    
    private func configureConstraints() {
            let searchResultsTableViewConstraints = [
                searchResultsTableView.topAnchor.constraint(equalTo: view.topAnchor),
                searchResultsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                searchResultsTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                searchResultsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ]

            NSLayoutConstraint.activate(searchResultsTableViewConstraints)
        }

}

extension SearchResultsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier, for: indexPath) as? UserTableViewCell
        else {
            print("bug here")
            return UITableViewCell()
        }
        let user = users[indexPath.row]
        cell.configure(with: user)
        return cell
    }


}

extension SearchResultsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        let profileViewModel = ProfileViewViewModel(user: user)
        let vc = ProfileViewController(viewModel: profileViewModel)
        present(vc, animated : true)
    }
}
