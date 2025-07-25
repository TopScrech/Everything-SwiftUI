import SwiftUI

struct TopicToggle: View {
    @State private var isOn = true
    
    var body: some View {
        VStack(spacing: 25) {
            Text("Toggle")
            
            Toggle("Toggle", isOn: $isOn)
            
            SimpleCodeBlockView(.toggle)
            
            TopicHeading("Style Details")
            
            TopicDisclosureGroup("Style") {
                VStack(spacing: 25) {
                    Toggle("Purple", isOn: $isOn)
                        .tint(.purple)
                }
            }
            
            TopicDisclosureGroup("Color") {
                VStack(spacing: 25) {
                    Toggle("Purple", isOn: $isOn)
                        .tint(.purple)
                    
                    SimpleCodeBlockView(.toggleTint)
                }
            }
        }
    }
}

#Preview {
    TopicDetail(.toggle) { relatedTopic in
        TopicTile(relatedTopic)
    }
    .environment(NavModel())
    .environment(DataModel())
    .darkSchemePreferred()
}
