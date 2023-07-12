import SwiftUI
import GroupActivities
import PhotosUI

struct ControlBar: View {
    @ObservedObject var groupActivitiesManager: GroupActivitiesManager
    @StateObject var groupStateObserver = GroupStateObserver()

    var body: some View {
        HStack {
            if groupActivitiesManager.groupSession == nil && groupStateObserver.isEligibleForGroupSession {
                Button {
                    groupActivitiesManager.startSharing()
                } label: {
                    Image(systemName: "person.2.fill")
                }
                .buttonStyle(.borderedProminent)
            }

            Spacer()
        }
        .buttonStyle(.bordered)
        .controlSize(.large)
    }
}
