//
//  Created by ktiays on 2026/5/15.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import AppKit
import EdgeEffectKit
import SwiftUI

class ViewController: NSViewController {
    
    let scrollContentView: NSHostingView<ScrollContentView> = .init(rootView: ScrollContentView())
    let scrollPocket: ScrollPocket = .init(edge: .top)

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollPocket.backgroundCapture)
        view.addSubview(scrollContentView)
        view.addSubview(scrollPocket)
    }
    
    override func viewWillLayout() {
        super.viewWillLayout()
        
        let bounds = view.bounds
        scrollPocket.backgroundCapture.frame = bounds
        scrollContentView.frame = bounds
        
        let pocketHeight: CGFloat = 48
        scrollPocket.frame = .init(x: 0, y: bounds.height - pocketHeight, width: bounds.width, height: pocketHeight)
        scrollPocket.maskLength = 12
    }
}

private let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple, .pink]

struct ScrollContentView: View {
    
    var body: some View {
        List {
            LazyVStack {
                ForEach(0..<100) { index in
                    Rectangle()
                        .foregroundStyle(colors[index % colors.count])
                        .frame(height: 60)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
