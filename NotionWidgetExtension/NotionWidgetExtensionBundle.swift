import WidgetKit
import SwiftUI

@main
struct NotionWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        NotionWidgetExtension()
        NotionWidgetExtensionControl()
    }
}
