//
//  NewButtonBar.swift
//  ARApp
//
//  Created by Mike Griffin on 05/12/2023.
//

import SwiftUI

public struct NewButtonBar: View {
    private let text: String
    private let icon: Image?

    // Tracks the enabled state of the view.
    // Check https://developer.apple.com/documentation/swiftui/environmentvalues/isenabled
    @Environment(\.isEnabled) var isEnabled

    public var body: some View {
        Button {
            print("TAP")
        } label: {
            HStack {
                icon
                Text(text).font(.body)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(8)
        }
        .buttonStyle(CustomButtonStyle(isEnabled: isEnabled))
    }

    public init(_ text: String,
                @ViewBuilder icon: () -> Image? = { nil }
    ) {
        self.icon = icon()
        self.text = text
    }
}

private struct CustomButtonStyle: ButtonStyle {
    let isEnabled: Bool

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let backgroundColor = isEnabled ? Color.purple : Color(UIColor.lightGray)
        let pressedColor = Color.red
        let background = configuration.isPressed ? pressedColor : backgroundColor

        configuration.label
            .foregroundColor(.white)
            .background(background)
            .cornerRadius(8)
    }
}
