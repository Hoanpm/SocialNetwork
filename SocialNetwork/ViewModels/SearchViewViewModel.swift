import Foundation
import Combine

class SearchViewViewModel {

    var subscriptions: Set<AnyCancellable> = []

    func search(with query: String, _ completion: @escaping ([SnsUser]) -> Void) {
        DatabaseManager.shared.collectionUsers(search: query)
            .sink { completion in
                if case .failure(let error) = completion {
                    print(error.localizedDescription)
                }
            } receiveValue: { users in
                completion(users)
            }
            .store(in: &subscriptions)
    }
}
