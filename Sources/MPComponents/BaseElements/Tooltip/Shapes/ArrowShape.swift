//
//  ArrowShape.swift
//  MercadoPagoSDK
//
//  Created by Guilherme Prata Costa on 08/09/25.
//

import SwiftUI

/// A triangular arrow shape for tooltip pointers.
///
/// `ArrowShape` creates a triangular path that points upward by default.
/// The shape automatically scales to fit the provided rectangle and can be
/// rotated to point in different directions based on tooltip positioning.
///
/// ## Shape Characteristics
///
/// - **Base**: The bottom edge of the triangle spans the full rectangle width
/// - **Apex**: The top point is centered horizontally and positioned at the top
/// - **Orientation**: Points upward by default; use rotation for other directions
///
/// ## Example Usage
///
/// Basic arrow shape:
/// ```swift
/// ArrowShape()
///     .fill(Color.blue)
///     .frame(width: 12, height: 6)
/// ```
///
/// Rotated arrow for different tooltip sides:
/// ```swift
/// ArrowShape()
///     .rotation(.degrees(180)) // Points downward
///     .fill(Color.blue)
/// ```
package struct ArrowShape: Shape {
    /// Creates the triangular arrow path within the provided rectangle.
    ///
    /// The path creates a triangle with its base at the bottom of the rectangle
    /// and its apex at the top center. This creates an upward-pointing arrow
    /// that can be rotated as needed for different tooltip orientations.
    ///
    /// - Parameter rect: The rectangle in which to create the arrow path.
    /// - Returns: A `Path` representing the triangular arrow shape.
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addLines([
            CGPoint(x: 0, y: rect.height),
            CGPoint(x: rect.width / 2, y: 0),
            CGPoint(x: rect.width, y: rect.height)
        ])
        return path
    }
}

#if DEBUG
struct ArrowShape_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Basic arrow shape
            ArrowShape()
                .fill(Color.blue)
                .frame(width: 20, height: 10)
            
            // Stroked arrow
            ArrowShape()
                .stroke(Color.red, lineWidth: 2)
                .frame(width: 20, height: 10)
            
            // Rotated arrows showing different directions
            HStack(spacing: 20) {
                ArrowShape()
                    .fill(Color.blue)
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(0)) // Up
                
                ArrowShape()
                    .fill(Color.blue)
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(90)) // Right
                
                ArrowShape()
                    .fill(Color.blue)
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(180)) // Down
                
                ArrowShape()
                    .fill(Color.blue)
                    .frame(width: 15, height: 8)
                    .rotationEffect(.degrees(270)) // Left
            }
        }
        .padding()
    }
}
#endif
