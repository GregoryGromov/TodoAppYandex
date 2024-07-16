import SwiftUI

struct ContentView: View {

    let manager = DefaultNetworkingService()

    var body: some View {
        TaskListView()
            .onAppear {
                Task {
                    try await manager.postTODOs()
                }

            }
    }
}
