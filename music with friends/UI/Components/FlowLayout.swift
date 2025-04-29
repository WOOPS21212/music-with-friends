//
//  FlowLayout.swift
//  music with friends
//
//  Created by amc on 4/28/25.
//


import SwiftUI
// FlowLayout.swift - Helper for tags layout
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) -> CGSize {
        let width = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var y: CGFloat = 0
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > width {
                // Move to next row
                y += maxHeight + spacing
                x = 0
                maxHeight = 0
            }
            
            // Place the view
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
            
            // Update total height
            height = max(height, y + maxHeight)
        }
        
        return CGSize(width: width, height: height)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout Void) {
        let width = bounds.width
        var x = bounds.minX
        var y = bounds.minY
        var maxHeight: CGFloat = 0
        
        for view in subviews {
            let viewSize = view.sizeThatFits(.unspecified)
            
            if x + viewSize.width > bounds.maxX {
                // Move to next row
                y += maxHeight + spacing
                x = bounds.minX
                maxHeight = 0
            }
            
            // Place the view
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(width: viewSize.width, height: viewSize.height))
            maxHeight = max(maxHeight, viewSize.height)
            x += viewSize.width + spacing
        }
    }
}
