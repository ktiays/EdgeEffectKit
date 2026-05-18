//
//  Created by ktiays on 2026/5/18.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

import QuartzCore

class NoAnimationDelegate: NSObject, CALayerDelegate {
    
    func action(for layer: CALayer, forKey event: String) -> (any CAAction)? {
        NSNull()
    }
}
