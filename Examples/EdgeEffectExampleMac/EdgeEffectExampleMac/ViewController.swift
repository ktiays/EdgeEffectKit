//
//  Created by ktiays on 2026/5/15.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import AppKit
import EdgeEffectKit
import SwiftUI

class ViewController: NSViewController {
    
    let scrollView: NSScrollView = .init()
    let contentView: NSHostingView<ScrollContentView> = .init(rootView: .init())
    let edgeEffectContainer: EdgeEffectContainer = .init()
    
    private var topEffectConfiguration: EdgeEffectConfiguration = .init(extent: 0)

    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.documentView = contentView
        contentView.frame = .init(origin: .zero, size: .init(width: 0, height: 6000))
        
        edgeEffectContainer.contentView = scrollView
        view.addSubview(edgeEffectContainer)
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        let bounds = view.bounds
        let safeAreaInsets = view.safeAreaInsets
        
        topEffectConfiguration.extent = safeAreaInsets.top
        topEffectConfiguration.transitionLength = safeAreaInsets.top * 1.8
        edgeEffectContainer.configuration.top = topEffectConfiguration
        
        edgeEffectContainer.frame = bounds
        contentView.frame.size.width = bounds.width
    }
}

private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

struct ScrollContentView: View {
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<100) { index in
                Rectangle()
                    .foregroundStyle(colors[index % colors.count])
                    .frame(height: 60)
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Text("Item \(index)")
                            .foregroundStyle(.white)
                            .padding()
                    }
            }
        }
        .ignoresSafeArea()
    }
}
