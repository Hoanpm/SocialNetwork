import Combine
import FirebaseAuth
import Foundation

enum ProfileFollowingState {
    case userIsFollowed
    case userIsUnFollowed
    case personal
}

final class ProfileViewViewModel: ObservableObject {

    @Published var user : SnsUser
    @Published var error : String?
    @Published var tweets: [Tweet] = []
    @Published var currentFollowingState: ProfileFollowingState = .personal
    
    private var subscriptions: Set <AnyCancellable> = []
    
    init(user: SnsUser) {
        self.user = user
        checkIfFollowed()
    }
    
    private func checkIfFollowed() {
        guard let personalUserID = Auth.auth().currentUser?.uid, personalUserID != user.id
        else {
            currentFollowingState = .personal
            return
        }
        DatabaseManager.shared.collectionFollowings(isFollower: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isFollowed in
                self?.currentFollowingState =  isFollowed ? .userIsFollowed : .userIsUnFollowed
            }
            .store(in: &subscriptions)
    }
    
    func unFollow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionFollowings(delete: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] _ in
                self?.currentFollowingState = .userIsUnFollowed
            }
            .store(in: &subscriptions)
    }
    
    func follow() {
        guard let personalUserID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionFollowings(follower: personalUserID, following: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isFollowed in
                self?.currentFollowingState = .userIsFollowed
            }
            .store(in: &subscriptions)
    }
    
    func fetchUserTweet() {
        DatabaseManager.shared.collectionTweets(retreiveTweets: user.id)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] tweets in
                self?.tweets = tweets
            }
            .store(in: &subscriptions)
    }
    
    func getFormattedDate(with date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM YYYY"
        return dateFormatter.string(from: date)
    }
    
}
