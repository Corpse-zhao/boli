#import <UIKit/UIKit.h>
#import <objc/runtime.h>

%hook UIViewController

- (void)viewDidLoad {
    %orig;

    // 仅在微信进程生效，避免影响系统服务
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    if (![bundleID isEqualToString:@"com.tencent.xin"]) return;

    // 排除一些系统浮层，防止干扰
    if ([self isKindOfClass:NSClassFromString(@"UIAlertController")] ||
        [self isKindOfClass:NSClassFromString(@"UIActivityViewController")] ||
        [self isKindOfClass:NSClassFromString(@"UIApplicationRotationFollowingController")]) {
        return;
    }

    UIView *view = self.view;
    if (!view) return;

    // 使用关联对象标记已处理，避免重复添加
    static const void *kGlassAddedKey = &kGlassAddedKey;
    if (objc_getAssociatedObject(self, kGlassAddedKey)) return;
    objc_setAssociatedObject(self, kGlassAddedKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    // 设置背景透明
    view.backgroundColor = [UIColor clearColor];

    // 创建毛玻璃效果（可调整 style）
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:blur];
    blurView.frame = view.bounds;
    blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    blurView.userInteractionEnabled = NO;   // 不阻挡触控
    blurView.tag = 0x1314;                  // 用于后续布局更新

    [view insertSubview:blurView atIndex:0];

    // 顺便处理 tableview/collectionview 等子控件的背景
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            subview.backgroundColor = [UIColor clearColor];
        }
    }
}

%end

// 自动更新毛玻璃尺寸
%hook UIView
- (void)layoutSubviews {
    %orig;
    UIView *blur = [self viewWithTag:0x1314];
    if (blur) {
        blur.frame = self.bounds;
    }
}
%end
