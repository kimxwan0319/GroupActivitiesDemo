import SwiftUI
import GroupActivities

struct ContentView: View {
    @StateObject var groupActivitiesManager = GroupActivitiesManager()

    var body: some View {
        VStack {

            Spacer()
            
            Text(String(groupActivitiesManager.count))
            HStack {
                Button("up", action: { groupActivitiesManager.add() })
                Button("down", action: { groupActivitiesManager.minus() })
            }
            
            Spacer()

            ControlBar(groupActivitiesManager: groupActivitiesManager)
                .padding()

        }
        .task {
            for await session in CountTogether.sessions() {
                groupActivitiesManager.configureGroupSession(session)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
