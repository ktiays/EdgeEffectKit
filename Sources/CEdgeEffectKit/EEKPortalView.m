//
//  Created by ktiays on 2026/5/16.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#import "EEKPortalView.h"

#if TARGET_OS_IPHONE

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wmissing-method-return-type"
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
@implementation EEKPortalView

- (instancetype)initWithSourceView:(__kindof UIView * _Nullable)sourceView {
    return [[NSClassFromString(@"_UIPortalView") alloc] initWithSourceView:sourceView];
}

@end
#pragma clang diagnostic pop

#endif
