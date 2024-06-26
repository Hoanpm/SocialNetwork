import Firebase
import Foundation
import FirebaseFirestoreSwift
import FirebaseFirestoreCombineSwift
import Combine

class DatabaseManager {
    static let shared = DatabaseManager()
    
    let tweetsPath : String = "tweet"
    let db = Firestore.firestore()
    let userPath: String = "user"
    let followingPath: String = "followings"
    func collectionUsers(add user: User) -> AnyPublisher<Bool, Error> {
        let snsUser = SnsUser(from: user)
        return db.collection(userPath).document(snsUser.id).setData(from: snsUser)
            .map{ _ in
                return true
            }
            .eraseToAnyPublisher()
    }
    
    func collectionUsers(retreive id : String) -> AnyPublisher<SnsUser, Error> {
        db.collection(userPath).document(id).getDocument()
            .tryMap {
                try $0.data(as: SnsUser.self)
            }
            .eraseToAnyPublisher()
    }
    
    func collectionUsers(updateFields: [String: Any], for id: String) -> AnyPublisher<Bool, Error> {
        db.collection(userPath).document(id).updateData(updateFields)
            .map{ _ in true }
            .eraseToAnyPublisher()
    }
    
    func collectionTweets(dispatch tweet : Tweet) -> AnyPublisher<Bool, Error> {
        db.collection(tweetsPath).document(tweet.id).setData(from: tweet)
            .map{ _ in true }
            .eraseToAnyPublisher()
    }
    
    func collectionUsers(search query: String) -> AnyPublisher<[SnsUser], Error> {
            db.collection(userPath).whereField("username", isEqualTo: query)
                .getDocuments()
                .map(\.documents)
                .tryMap { snapshots in
                    try snapshots.map({
                        try $0.data(as: SnsUser.self)
                    })
                }
                .eraseToAnyPublisher()
        }
    
    func collectionTweets(retreiveTweets forUserID: String) -> AnyPublisher<[Tweet], Error> {
        db.collection(tweetsPath).whereField("authorID", isEqualTo: forUserID)
            .getDocuments()
            .tryMap(\.documents)
            .tryMap{ snapshots in
                try snapshots.map({
                    try $0.data(as: Tweet.self)
                })
            }
            .eraseToAnyPublisher()
    }
    
    func collectionFollowings(isFollower: String, following: String) -> AnyPublisher<Bool, Error> {
        db.collection(followingPath)
            .whereField("follower", isEqualTo: isFollower)
            .whereField("following", isEqualTo: following)
            .getDocuments()
            .map(\.count)
            .map {
                $0 != 0
            }
            .eraseToAnyPublisher()
    }
    
    func collectionFollowings(follower: String, following: String) -> AnyPublisher<Bool, Error> {
        db.collection(followingPath).document().setData([
            "follower" : follower,
            "following": following
        ])
        .map { true }
        .eraseToAnyPublisher()
    }
    
    func collectionFollowings(delete follower: String, following: String) -> AnyPublisher <Bool, Error> {
        db.collection(followingPath)
            .whereField("follower", isEqualTo: follower)
            .whereField("following", isEqualTo: following)
            .getDocuments()
            .map(\.documents.first)
            .map { query in
                query?.reference.delete(completion: nil)
                return true
            }
            .eraseToAnyPublisher()
    }
}
