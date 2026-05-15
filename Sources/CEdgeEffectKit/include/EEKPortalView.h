//
//  Created by ktiays on 2026/5/16.
//  Copyright (c) 2026 ktiays. All rights reserved.
//

#import <TargetConditionals.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

NS_SWIFT_NAME(PortalView)
@interface EEKPortalView : UIView

@property (nonatomic, strong) UIView *sourceView;
@property (nonatomic, copy, nullable) NSString *name;
@property (nonatomic, assign) BOOL hidesSourceView;
@property (nonatomic, assign) BOOL matchesAlpha;
@property (nonatomic, assign) BOOL matchesTransform;
@property (nonatomic, assign) BOOL matchesPosition;
@property (nonatomic, assign) BOOL allowsBackdropGroups;
@property (nonatomic, assign) BOOL hidesSourceLayerInOtherPortals;
@property (nonatomic, assign) BOOL allowsHitTesting;
@property (nonatomic, assign) BOOL forwardsClientHitTestingToSourceView;
@property (nonatomic, assign) CGFloat sourceViewAlphaScale;
@property (nonatomic, readonly) CALayer *portalLayer;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithSourceView:(__kindof UIView * _Nullable)sourceView NS_DESIGNATED_INITIALIZER;

- (UIView *)_sourceViewIfPortal;
- (void)_updateSourceLayer;

@end

NS_ASSUME_NONNULL_END

#endif
