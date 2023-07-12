import Foundation
import Combine
import SwiftUI
import GroupActivities

@MainActor
class GroupActivitiesManager: ObservableObject {
    @Published var count: Int = 0

    var subscriptions = Set<AnyCancellable>()
    var tasks = Set<Task<Void, Never>>()

    func add() {
        count += 1
        if let messenger = messenger {
            Task {
                try? await messenger.send(CountMessage(count: count))
            }
        }
    }
    
    func minus() {
        count -= 1
        if let messenger = messenger {
            Task {
                try? await messenger.send(CountMessage(count: count))
            }
        }
    }
    
    func reset() {
        // Clear the local count.
        count = 0

        // Tear down the existing groupSession.
        messenger = nil
        tasks.forEach { $0.cancel() }
        tasks = []
        subscriptions = []
        if groupSession != nil {
            groupSession?.leave()
            groupSession = nil
            self.startSharing()
        }
    }

    @Published var groupSession: GroupSession<CountTogether>?
    var messenger: GroupSessionMessenger?

    func startSharing() {
        Task {
            _ = try? await CountTogether().activate()
        }
    }

    func configureGroupSession(_ groupSession: GroupSession<CountTogether>) {
        count = 0

        self.groupSession = groupSession
        let messenger = GroupSessionMessenger(session: groupSession)
        self.messenger = messenger

        groupSession.$state
            .sink { state in
                if case .invalidated = state {
                    self.groupSession = nil
                    self.reset()
                }
            }
            .store(in: &subscriptions)

        groupSession.$activeParticipants
            .sink { activeParticipants in
                let newParticipants = activeParticipants.subtracting(groupSession.activeParticipants)

                Task {
                    try? await messenger.send(CountMessage(count: self.count), to: .only(newParticipants))
                }
            }
            .store(in: &subscriptions)

        let task = Task {
            for await (message, _) in messenger.messages(of: CountMessage.self) {
                self.count = message.count
            }
        }
        tasks.insert(task)

        groupSession.join()
    }

}
