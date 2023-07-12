import Foundation
import GroupActivities

struct CountTogether: GroupActivity {
    var metadata: GroupActivityMetadata {
        var metadata = GroupActivityMetadata()
        metadata.title = "Count Together"
        metadata.type = .generic
        return metadata
    }
}
