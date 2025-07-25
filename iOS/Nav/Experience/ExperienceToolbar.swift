// Populates the navigation bar with the "Topic of the Day" and experience buttons

import SwiftUI

struct ExperienceToolbarViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbar {
                ExperienceButton()
            }
    }
}

extension View {
    func experienceToolbar() -> some View {
        modifier(ExperienceToolbarViewModifier())
    }
}

#Preview {
    NavigationStack {
        Color.white
            .experienceToolbar()
    }
}
