//
//  StyledCardFieldContainer.swift
//  Example
//
//  Created by Guilherme Prata Costa on 01/04/25.
//
import SwiftUI

struct StyledCardFieldContainer<Content: View>: View {
    let title: String
    @Binding public var isValid: Bool
    let content: Content
    let paddingContent = EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)

    init(title: String, isValid: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.title = title
        self._isValid = isValid
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(self.title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)

            HStack {
                self.content
                    .frame(height: 48)
                    .padding(self.paddingContent)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(self.isValid ? Color(.systemGray4) : Color.red, lineWidth: 1)
                    )
            }
        }
    }
}
