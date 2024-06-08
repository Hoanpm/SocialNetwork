import Combine
import Foundation
import FirebaseAuth

final class TweetComposeViewViewModel: ObservableObject {
    private var subsciptions : Set<AnyCancellable> = []
    
    @Published var isValidToTweet: Bool = false
    @Published var error : String = ""
    @Published var shouldDismissComposer: Bool = false
    private var user : SnsUser?
    var tweetContent: String = ""
    
    func getUserData() {
        
        guard let userID = Auth.auth().currentUser?.uid else { return }
        DatabaseManager.shared.collectionUsers(retreive: userID)
            .sink{ [ weak self ] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] twitteruser in
                self?.user = twitteruser
            }
            .store(in: &subsciptions)
    }
    
    func validateToTweet() {
        isValidToTweet = !tweetContent.isEmpty
    }
    
    func dispatchTweet() {
        guard let user = user else { return }
        let tweet = Tweet(author: user, authorID : user.id, tweetContent: tweetContent, likeCount: 0, likers: [], isReply: false, parentReference: nil)
        DatabaseManager.shared.collectionTweets(dispatch: tweet)
            .sink{ [ weak self ] completion in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                }
            } receiveValue: { [weak self] state in
                self?.shouldDismissComposer = state
            }
            .store(in: &subsciptions)
    }
    
}
