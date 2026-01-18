import WidgetKit
import SwiftUI

@main
struct PrepFlowWidgetBundle: WidgetBundle {
    var body: some Widget {
        PrepFlowSmallWidget()
        PrepFlowMediumWidget()
        PrepFlowLockScreenWidgets()
    }
}
