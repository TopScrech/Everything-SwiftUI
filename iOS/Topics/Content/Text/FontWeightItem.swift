import SwiftUI

struct FontWeightItem: View {
    private let text: TextFontWeight
    
    init(_ text: TextFontWeight) {
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(text.name)
                .fontWeight(text.weight)
            
            Spacer()
        }
    }
}
