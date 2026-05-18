//
//  Created by ktiays on 2026/5/16.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import UIKit
import EdgeEffectKit
import SwiftUI

class ViewController: UIViewController {

    let scrollContentView: _UIHostingView<ScrollContentView> = .init(rootView: ScrollContentView())
    let edgeEffectContainer: EdgeEffectContainer = .init()
    
    private var topEffectConfiguration: EdgeEffectConfiguration = .init()
    private var bottomEffectConfiguration: EdgeEffectConfiguration = .init(isBlurEnabled: false)
    
    private let safeAreaIndicator: UIView = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgeEffectContainer.contentView = scrollContentView
        view.addSubview(edgeEffectContainer)
        
        safeAreaIndicator.layer.borderColor = UIColor.systemRed.cgColor
        safeAreaIndicator.layer.borderWidth = 1
        safeAreaIndicator.isUserInteractionEnabled = false
        view.addSubview(safeAreaIndicator)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let bounds = view.bounds
        let safeAreaInsets = view.safeAreaInsets
        safeAreaIndicator.frame = bounds.inset(by: safeAreaInsets)
        
        topEffectConfiguration.maskLength = safeAreaInsets.top + 54.8
        bottomEffectConfiguration.maskLength = safeAreaInsets.bottom + 54.8
        edgeEffectContainer.configuration.top = topEffectConfiguration
        edgeEffectContainer.configuration.bottom = bottomEffectConfiguration
        
        edgeEffectContainer.frame = bounds
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
