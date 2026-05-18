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
    let scrollPocket: ScrollPocket = .init(edge: .top)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollPocket.backgroundCapture)
        view.addSubview(scrollView)
        view.addSubview(scrollPocket)
        
        scrollView.documentView = contentView
        contentView.frame = .init(origin: .zero, size: .init(width: 0, height: 6000))
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        let bounds = view.bounds
        scrollPocket.backgroundCapture.frame = bounds
        scrollView.frame = bounds
        contentView.frame.size.width = bounds.width
        
        let pocketHeight: CGFloat = 64
        scrollPocket.frame = .init(x: 0, y: bounds.height - pocketHeight, width: bounds.width, height: pocketHeight)
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
                            .padding()
                    }
            }
        }
        .ignoresSafeArea()
    }
}
