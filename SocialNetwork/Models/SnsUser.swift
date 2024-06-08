import Firebase
import Foundation

struct SnsUser: Codable {
    let id : String
    var displayName: String = ""
    var username: String = ""
    var followersCount: Int = 0
    var FollowingCount: Int = 0
    var createOn : Date = Date()
    var bio: String = ""
    var avatarPath: String = ""
    var isUserOnboarded: Bool = false
    
    init(from user: User) {
        self.id = user.uid
    }
    
}
