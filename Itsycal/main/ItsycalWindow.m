//
//  ItsycalWindow.m
//  Itsycal
//
//  Created by Sanjay Madan on 12/14/14.
//  Copyright (c) 2014 Swittee.com. All rights reserved.
//

#import "ItsycalWindow.h"
#import "Themer.h"

static const CGFloat kMinimumSpaceBetweenWindowAndScreenEdge = 10;
static const CGFloat kArrowHeight  = 8;
static const CGFloat kCornerRadius = 8;
static const CGFloat kBorderWidth  = 1;
static const CGFloat kMarginWidth  = 2;
static const CGFloat kWindowTopMargin    = kCornerRadius + kBorderWidth + kArrowHeight;
static const CGFloat kWindowSideMargin   = kMarginWidth  + kBorderWidth;
static const CGFloat kWindowBottomMargin = kCornerRadius + kBorderWidth;

@interface ItsycalWindowFrameView : NSView
@property (nonatomic, assign) CGFloat arrowMidX;
@end

@interface ItsycalWindowVisualView : NSVisualEffectView
@property (nonatomic, assign) CGFloat arrowMidX;
@property (nonatomic, strong) NSImage *cornerImage;
- (void)invalidateCornerImage ;
@end


@interface ColorOverlayView : NSView

@end

#pragma mark -
#pragma mark ItsycalWindow

// =========================================================================
// ItsycalWindow
// =========================================================================

@implementation ItsycalWindow
{
    NSView *_childContentView;
    ItsycalWindowVisualView *_vibrant;
}

- (id)init
{
    self = [super initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskNonactivatingPanel backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        [self setBackgroundColor:[NSColor clearColor]];
        [self setOpaque:NO];
        [self setLevel:NSMainMenuWindowLevel];
        [self setMovableByWindowBackground:NO];
        [self setCollectionBehavior:NSWindowCollectionBehaviorMoveToActiveSpace];
        // Fade out when -[NSWindow orderOut:] is called.
        [self setAnimationBehavior:NSWindowAnimationBehaviorUtilityWindow];
        //self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(interfaceModeChanged:) name:@"AppleInterfaceThemeChangedNotification" object:nil];
    }
    return self;
}

+ (BOOL)isDarkMode {
    NSAppearance *appearance = NSAppearance.currentAppearance;
    if (@available(*, macOS 10.14)) {
        return appearance.name == NSAppearanceNameDarkAqua;
    }

    return NO;
}

// 貌似增加了 vibrant 效果没有很好
// 而且 window reload 也貌似没有执行
// 先去掉好了
- (void)interfaceModeChanged:(NSNotification *)sender {
//    if ([ItsycalWindow isDarkMode]) {
//        self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
//    } else {
//        self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
//    }
//    [self viewsNeedDisplay];
}

- (BOOL)canBecomeMainWindow
{
    return NO;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)setContentView:(NSView *)aView
{
    // Instead of setting aView as the contentView, we set
    // our own frame view (which draws the window) as the
    // contentView and then set aView as its subview.
    // We keep a reference to aView called _childContentView.
    // So...
    // [self  contentView] returns _childContentView
    // [super contentView] returns our frame view
    
    if ([_childContentView isEqualTo:aView]) {
        return;
    }
    ItsycalWindowFrameView *frameView = [super contentView];
    if (!frameView) {
        frameView = [[ItsycalWindowFrameView alloc] initWithFrame:NSZeroRect];
        frameView.translatesAutoresizingMaskIntoConstraints = YES;
        frameView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;

        [super setContentView:frameView];

    }
    
    // blur
    if (!_vibrant) {
        
        ColorOverlayView *colorView = [ColorOverlayView new];
        colorView.translatesAutoresizingMaskIntoConstraints = false;
        _vibrant=[[ItsycalWindowVisualView alloc] initWithFrame:NSMakeRect(0, 0, 2, 2)];
        _vibrant.translatesAutoresizingMaskIntoConstraints = NO;
        // _vibrant.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        _vibrant.material = NSVisualEffectMaterialPopover;
        [_vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
        [frameView addSubview:_vibrant];// positioned:NSWindowBelow relativeTo:nil];
        [frameView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_vibrant]|" options:0 metrics:@{ @"m" : @(kWindowSideMargin) } views:NSDictionaryOfVariableBindings(_vibrant)]];
        [frameView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[_vibrant]|" options:0 metrics:@{ @"tm" : @(kWindowTopMargin), @"bm" : @(kWindowBottomMargin) } views:NSDictionaryOfVariableBindings(_vibrant)]];
    }
    
    
    if (_childContentView) {
        [_childContentView removeFromSuperview];
        _childContentView = nil;
    }
    if (aView == nil) {
        return;
    }
    _childContentView = aView;
    _childContentView.translatesAutoresizingMaskIntoConstraints = NO;
    [frameView addSubview:_childContentView];
    [frameView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(m)-[_childContentView]-(m)-|" options:0 metrics:@{ @"m" : @(kWindowSideMargin) } views:NSDictionaryOfVariableBindings(_childContentView)]];
    [frameView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(tm)-[_childContentView]-(bm)-|" options:0 metrics:@{ @"tm" : @(kWindowTopMargin), @"bm" : @(kWindowBottomMargin) } views:NSDictionaryOfVariableBindings(_childContentView)]];
    

}

- (NSView *)contentView
{
    return _childContentView;
}

- (NSRect)convertRectToScreen:(NSRect)aRect
{
    NSRect rect = [super convertRectToScreen:aRect];
    // Right now, rect is the answer for our frame view.
    // What we want is the answer for _childContentView.
    // So, we offset by the amount _childContentView is
    // offset within our frame view.
    return NSOffsetRect(rect, kWindowSideMargin, kWindowBottomMargin);
}

- (NSRect)convertRectFromScreen:(NSRect)aRect
{
    // See comment for -convertRectToScreen:.
    NSRect rect = [super convertRectFromScreen:aRect];
    return NSOffsetRect(rect, kWindowSideMargin, kWindowBottomMargin);
}

- (void)positionRelativeToRect:(NSRect)rect screenMaxX:(CGFloat)screenMaxX
{
    // Calculate window's top left point.
    // First, center window under status item.
    CGFloat w = NSWidth(self.frame);
    CGFloat x = roundf(NSMidX(rect) - w / 2);
    CGFloat y = NSMinY(rect) - 2;
    
    // If the calculated x position puts the window too
    // far to the right, shift the window left.
    if (x + w + kMinimumSpaceBetweenWindowAndScreenEdge > screenMaxX) {
        x = screenMaxX - w - kMinimumSpaceBetweenWindowAndScreenEdge;
    }

    // Set the window position.
    [self setFrameTopLeftPoint:NSMakePoint(x, y)];

    // Tell the frame view where to draw the arrow.
    ItsycalWindowFrameView *frameView = [super contentView];
    // We call super because we want the midX for the frame view,
    // not the _childContentView, since we use the midX to draw
    // the frame view.
    frameView.arrowMidX = NSMidX([super convertRectFromScreen:rect]);
    [frameView setNeedsDisplay:YES];
    
    _vibrant.arrowMidX = frameView.arrowMidX;
    [_vibrant invalidateCornerImage];
    
    [self invalidateShadow];
}

@end

#pragma mark -
#pragma mark ItsycalWindowFrameView

// =========================================================================
// ItsycalWindowFrameView
// =========================================================================

@implementation ItsycalWindowFrameView

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    [[NSColor clearColor] set];
    NSRectFill(dirtyRect);
    
    // ❶ 从 self.bounds 减去边框 & 箭头
    NSRect rect = NSInsetRect(self.bounds, kBorderWidth, kBorderWidth);
    rect.size.height -= kArrowHeight; // 让主体腾出箭头高度
    
    // ❷ 先做一个圆角矩形
    NSBezierPath *rectPath = [NSBezierPath
                              bezierPathWithRoundedRect:rect
                              xRadius:kCornerRadius
                              yRadius:kCornerRadius];
    
    // ❸ 在顶部追加箭头路径
    CGFloat arrowMidX = (_arrowMidX == 0) ? NSMidX(self.bounds) : _arrowMidX;
    CGFloat curveOffset = 5.0;
    
    // 箭头的“基线”就在主体 rect 的顶部
    CGFloat arrowBaseY = NSMaxY(rect);
    // 箭头左端 x 坐标 = (箭头中点) - (箭头宽度/2)
    // 箭头宽度大约是 (kArrowHeight + curveOffset) * 2
    CGFloat x = arrowMidX - (kArrowHeight + curveOffset);
    
    // 创建箭头的 BezierPath
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    [arrowPath moveToPoint:NSMakePoint(x, arrowBaseY)];
    [arrowPath relativeCurveToPoint:NSMakePoint(kArrowHeight+curveOffset, kArrowHeight)
                      controlPoint1:NSMakePoint(curveOffset, 0)
                      controlPoint2:NSMakePoint(kArrowHeight, kArrowHeight)];
    [arrowPath relativeCurveToPoint:NSMakePoint(kArrowHeight+curveOffset, -kArrowHeight)
                      controlPoint1:NSMakePoint(curveOffset, 0)
                      controlPoint2:NSMakePoint(kArrowHeight, -kArrowHeight)];
    
    // ❹ 把箭头 append 到原先圆角矩形的路径里
    [rectPath appendBezierPath:arrowPath];
    
    // ❺ 描边 & 填充
    [rectPath setLineWidth:kBorderWidth];
    [Theme.windowBorderColor setStroke];
    [Theme.windowBorderColor setFill];
    [rectPath fill];
    [rectPath stroke];
}

@end

#pragma mark -
#pragma mark ItsycalWindowVisualView

// =========================================================================
// ItsycalWindowVisualView
// =========================================================================

@implementation ItsycalWindowVisualView

- (void)invalidateCornerImage {
    if (self.bounds.size.height == 0) return;
    
    // 跟 FrameView 同样的算法：
    NSRect rect = NSInsetRect(self.bounds, kBorderWidth, kBorderWidth);
    rect.size.height -= kArrowHeight;
    
    NSImage *img = [[NSImage alloc] initWithSize:self.bounds.size];
    [img lockFocus];
    
    // 注意：保证跟上面的箭头曲线参数完全一致
    NSBezierPath *rectPath =
    [NSBezierPath bezierPathWithRoundedRect:rect
                                    xRadius:kCornerRadius
                                    yRadius:kCornerRadius];
    
    CGFloat arrowMidX = (_arrowMidX == 0) ? NSMidX(self.bounds) : _arrowMidX;
    CGFloat curveOffset = 5.0;
    CGFloat arrowBaseY = NSMaxY(rect);
    
    NSBezierPath *arrowPath = [NSBezierPath bezierPath];
    CGFloat x = arrowMidX - (kArrowHeight + curveOffset);
    [arrowPath moveToPoint:NSMakePoint(x, arrowBaseY)];
    [arrowPath relativeCurveToPoint:NSMakePoint(kArrowHeight+curveOffset, kArrowHeight)
                      controlPoint1:NSMakePoint(curveOffset, 0)
                      controlPoint2:NSMakePoint(kArrowHeight, kArrowHeight)];
    [arrowPath relativeCurveToPoint:NSMakePoint(kArrowHeight+curveOffset, -kArrowHeight)
                      controlPoint1:NSMakePoint(curveOffset, 0)
                      controlPoint2:NSMakePoint(kArrowHeight, -kArrowHeight)];
    [rectPath appendBezierPath:arrowPath];
    
    [rectPath addClip];
    [rectPath fill]; // 用透明色填充，表示可见区域
    
    [img unlockFocus];
    self.maskImage = img;
}

- (void)viewDidMoveToSuperview {
    [super viewDidMoveToSuperview];
//    self.maskImage = [NSImage imageWithSystemSymbolName:@"hammer.fill" accessibilityDescription:nil];
    [self invalidateCornerImage];
}

- (void)setFrameSize:(NSSize)newSize {
    // NSLog(@"** %@,%@", NSStringFromRect(self.bounds),NSStringFromSize(newSize));
    [super setFrameSize: newSize];
    self.translatesAutoresizingMaskIntoConstraints = false;
//    self.maskImage = [NSImage imageWithSystemSymbolName:@"hammer.fill" accessibilityDescription:nil];
    [self invalidateCornerImage];
}

@end


@implementation ColorOverlayView

- (void)drawRect:(NSRect)dirtyRect {
    [NSColor.clearColor setFill];
    NSRectFill(dirtyRect);
}

- (BOOL)allowsVibrancy {
    return  true;
}

@end
