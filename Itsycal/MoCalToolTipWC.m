//
//  MoCalToolTipWC.m
//  
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 mowglii.com. All rights reserved.
//

#import "MoCalToolTipWC.h"
#import "Themer.h"

static CGFloat kToolipWindowWidth = 200;

// Implementation at bottom.
@interface MoCalTooltipWindow : NSWindow  @end
@interface MoCalTooltipContentView : NSView {NSVisualEffectView *visualView;}@end

#pragma mark -
#pragma mark MoCalTooltipWC

// =========================================================================
// MoCalTooltipWC
// =========================================================================

@implementation MoCalToolTipWC
{
    NSTimer *_fadeTimer;
    NSRect   _positioningRect;
    NSRect   _screenFrame;
}

- (instancetype)init
{
    self = [super initWithWindow:[MoCalTooltipWindow new]];
    
    // 空白view
    // 加上这个view 放在 visualeffect 后面
    // 使 effect 起作用
    //[self.window.contentView  addSubview:visualView positioned:NSWindowBelow relativeTo:nil];
    
    return self;
}

- (void)showTooltipForDate:(MoDate)date relativeToRect:(NSRect)rect screenFrame:(NSRect)screenFrame
{
    _positioningRect = rect;
    _screenFrame = screenFrame;
    BOOL dateHasEvent = NO;
    if (self.vc) {
        dateHasEvent = [self.vc toolTipForDate:date];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showTooltip) object:nil];
    if (!dateHasEvent) {
        [self hideTooltip];
        return;
    }
    if (self.window.occlusionState & NSWindowOcclusionStateVisible) {
        // Switching from one tooltip to another
        [_fadeTimer invalidate];
        _fadeTimer = nil;
        [self performSelector:@selector(showTooltip) withObject:nil afterDelay:0];
    }
    else {
        // Showing a tooltip for the first time
        [self performSelector:@selector(showTooltip) withObject:nil afterDelay:1];
    }
}

- (void)positionTooltip
{
    NSRect frame = self.window.frame;
    frame.origin.x = roundf(NSMidX(_positioningRect) - NSWidth(frame)/2);
    frame.origin.y = _positioningRect.origin.y - NSHeight(frame) - 3;
    CGFloat screenMaxX = NSMaxX(_screenFrame);
    if (NSMaxX(frame) + 5 > screenMaxX) {
        frame.origin.x = screenMaxX - NSWidth(frame) - 5;
    }
    [self.window setFrame:frame display:YES animate:NO];
    
    //NSLog(@"%@", self.window.contentView.subviews);
}

- (void)showTooltip
{
    [self positionTooltip];
    [self showWindow:self];
    [self.window setAlphaValue:1];
}

- (void)endTooltip
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showTooltip) object:nil];
    [_fadeTimer invalidate];
    _fadeTimer = nil;
    [self.window orderOut:nil];
}

- (void)hideTooltip
{

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showTooltip) object:nil];
    if (self.window.occlusionState & NSWindowOcclusionStateVisible &&
        _fadeTimer == nil) {
        _fadeTimer = [NSTimer scheduledTimerWithTimeInterval:1/30. target:self selector:@selector(tick:) userInfo:nil repeats:YES];
    }
}

- (void)tick:(NSTimer *)timer
{
    CGFloat alpha = self.window.alphaValue - 0.07;
    if (alpha <= 0) {
        [self endTooltip];
    }
    else {
        self.window.alphaValue = alpha;
    }
}

@end

#pragma mark-
#pragma mark Tooltip window and content view

// =========================================================================
// MoCalTooltipWindow
// =========================================================================

@implementation MoCalTooltipWindow

- (instancetype)init
{
    self = [super initWithContentRect:NSZeroRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    if (self) {
        self.backgroundColor = [NSColor clearColor];
        self.opaque = NO;
        self.level = NSPopUpMenuWindowLevel;
        self.movableByWindowBackground = NO;
        self.ignoresMouseEvents = YES;
        self.hasShadow = YES;

        // Draw tooltip background and fix tooltip width.
        self.contentView = [MoCalTooltipContentView new];
        [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kToolipWindowWidth]];
    }
    return self;
}

@end

// =========================================================================
// MoCalTooltipContentView
// =========================================================================

@implementation MoCalTooltipContentView

- (instancetype)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    visualView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, 30, 10)];
    [visualView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    visualView.maskImage = [self maskImage:4];
    visualView.material = NSVisualEffectMaterialHUDWindow;
    visualView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualView.state = NSVisualEffectStateActive;
    
    
    return self;
}

- (NSImage *)maskImage:(CGFloat)cornerRadius {
    CGFloat edgeLength = 2.0 * cornerRadius + 1.0;
    NSImage *img = [NSImage imageWithSize:NSMakeSize(edgeLength, edgeLength) flipped:false drawingHandler:^BOOL(NSRect dstRect) {
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:dstRect xRadius:cornerRadius yRadius:cornerRadius];
        [NSColor.redColor set];
        [path fill];
        return true;
    }];
    
    img.capInsets = NSEdgeInsetsMake(cornerRadius, cornerRadius, cornerRadius, cornerRadius);
    img.resizingMode = NSImageResizingModeStretch;
    
    return img;
}

- (void)drawRect:(NSRect)dirtyRect
{
    visualView.frame = NSInsetRect(dirtyRect, 1, 1);
    [self addSubview:visualView positioned:NSWindowBelow relativeTo:nil];
    // A rounded rect with a light gray border.
    NSRect r = NSInsetRect(self.bounds, 1, 1);
    NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:r xRadius:4 yRadius:4];
    [Theme.windowBorderColor setStroke];
    [p setLineWidth:1];
    [p stroke];
    [Theme.tooltipBackgroundColor setFill];
    [p fill];
}

@end
