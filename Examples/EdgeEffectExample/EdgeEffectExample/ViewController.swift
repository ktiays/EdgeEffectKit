//
//  Created by ktiays on 2026/5/16.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import UIKit
import EdgeEffectKit
import SwiftUI

class ViewController: UIViewController {

    let scrollContentView: _UIHostingView<ScrollContentView> = .init(rootView: ScrollContentView())
    let scrollPocket: ScrollPocket = .init(edge: .top)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(scrollPocket.backgroundCapture)
        view.addSubview(scrollContentView)
        view.addSubview(scrollPocket)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bounds = view.bounds
        scrollContentView.frame = bounds
        
        let pocketHeight: CGFloat = 120
        scrollPocket.frame = .init(x: 0, y: 0, width: bounds.width, height: pocketHeight)
        scrollPocket.backgroundCapture.frame = scrollPocket.frame
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
                        .overlay(alignment: .leading) {
                            Text("Item \(index)")
                                .padding()
                        }
                }
            }
        }
        .scrollContentBackground(.hidden)
    }
}
