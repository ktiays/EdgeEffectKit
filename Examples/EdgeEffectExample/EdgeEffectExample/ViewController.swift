//
//  Created by ktiays on 2026/5/16.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import UIKit
import EdgeEffectKit
import SwiftUI

class ViewController: UIViewController {

    let scrollRootView: _UIHostingView<ScrollRootView> = .init(rootView: .init())
    let edgeEffectContainer: EdgeEffectContainer = .init()
    
    private var topEffectConfiguration: EdgeEffectConfiguration = .init()
    private var bottomEffectConfiguration: EdgeEffectConfiguration = .init(isBlurEnabled: false)
    
    private let safeAreaIndicator: UIView = .init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGroupedBackground
        
        edgeEffectContainer.contentView = scrollRootView
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

struct ScrollRootView: View {
    
    var body: some View {
        if #available(iOS 26.0, *) {
            ScrollView {
                ScrollContentView()
            }
            .scrollContentBackground(.hidden)
            .scrollEdgeEffectHidden(for: .all)
        } else {
            ScrollView {
                ScrollContentView()
            }
            .scrollContentBackground(.hidden)
        }
    }
}

struct ScrollContentView: View {
    
    private let icons = ["eject.fill", "pc", "figure.wave", "snowflake"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                ForEach(0..<4, id: \.self) { index in
                    VStack {
                        Image(systemName: icons[index])
                            .font(.system(size: 24))
                            .padding(20)
                            .background {
                                Circle()
                                    .foregroundStyle(
                                        Color(uiColor: .secondarySystemGroupedBackground)
                                    )
                            }
                        Text("Icon \(index + 1)")
                            .foregroundStyle(.secondary)
                            .font(.system(size: 13))
                    }
                    if index != 3 {
                        Spacer()
                    }
                }
            }
            .padding(.vertical, 5)
            VStack(alignment: .leading) {
                AsyncImage(url: .init(string: "https://picsum.photos/600/400")) { image in
                    image.resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Color(uiColor: .quaternarySystemFill)
                }
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay {
                    ZStack(alignment: .bottomTrailing) {
                        Color.clear
                        Text("4.5")
                            .font(.system(size: 14))
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.thinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(6)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text("7km")
                        .font(.footnote)
                    Text("Parking")
                        .bold()
                        .font(.title3)
                        .foregroundStyle(.primary)
                }
                .padding(6)
            }
            .foregroundStyle(.secondary)
            .padding(4)
            .background {
                Color(uiColor: .secondarySystemGroupedBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.vertical, 8)
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. In malesuada facilisis ornare. Vestibulum faucibus erat eu quam iaculis facilisis. Sed fringilla tempus bibendum. Sed eu consectetur est. Sed cursus ex at diam ornare, non viverra sapien consectetur.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(7)
            VStack(spacing: 14) {
                ForEach(0..<20, id: \.self) { i in
                    HStack {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Rectangle()
                                    .frame(width: 10, height: 10)
                                    .rotationEffect(.degrees(45))
                                    .frame(width: 14, height: 14)
                                Text("+\(String(format: "%.3f", Double.random(in: 1..<10)))")
                                    .foregroundStyle(Color.init(red: 102.0 / 255, green: 240.0 / 255, blue: 195.0 / 255))
                                    .font(.system(size: 11))
                            }
                            HStack(alignment: .top, spacing: 1) {
                                Text("$")
                                    .font(.system(size: 9))
                                    .offset(y: 2)
                                Text(String(Int.random(in: 100..<10000)))
                                    .font(.system(size: 14))
                                    .bold()
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(width: 60)
                        .padding([.horizontal, .top], 8)
                        .padding(.bottom, 7)
                        .background {
                            Color.blue
                                .opacity(0.9)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Item \(i + 1)")
                                .bold()
                            Text("Subitem \(i + 1)")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 15))
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("$\(Int.random(in: 1000..<100000))")
                                .bold()
                            Text("USDT")
                                .foregroundStyle(.secondary)
                                .font(.system(size: 15))
                        }
                    }
                    .frame(height: 58)
                }
            }
            .padding(12)
            .background {
                Color(uiColor: .secondarySystemGroupedBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .padding(.horizontal)
        .padding(.bottom)
        .padding(.top, 36)
        .ignoresSafeArea(edges: .vertical)
    }
}
