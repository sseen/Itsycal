//
//  Created by Sanjay Madan on 1/29/17.
//  Copyright © 2017 Swittee.com. All rights reserved.
//

#import "PrefsVC.h"
#import "NSImage+TintColor.h"
#import "SNToolbarItem.h"
#import <CoreImage/CoreImage.h>

@implementation PrefsVC
{
    NSToolbar *_toolbar;
    NSMutableArray<NSString *> *_toolbarIdentifiers;
    NSInteger _selectedItemTag;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _toolbar = [[NSToolbar alloc] initWithIdentifier:@"Toolbar"];
        _toolbar.allowsUserCustomization = NO;
        _toolbar.delegate = self;
        _toolbarIdentifiers = [NSMutableArray new];
        _selectedItemTag = 0;
    }
    return self;
}

- (void)loadView
{
    self.view = [NSView new];
}


- (void)makeWindowBlur {
    
    // 这里可以不设置
    // 打开后就是可以使window的背景透明
    // self.view.window.contentView.wantsLayer = true;
    // self.view.window.backgroundColor = [NSColor.purpleColor colorWithAlphaComponent:0.2];
    // self.view.window.opaque = false;
    // [self.view.window makeKeyAndOrderFront:nil];
    // [self.view.window makeKeyWindow];
    
//    self.view.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
    self.view.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    
    self.view.window.titlebarAppearsTransparent = true;
    NSVisualEffectView *visualView = [[NSVisualEffectView alloc] initWithFrame:NSMakeRect(0, 0, self.view.window.contentView.frame.size.width, self.view.window.contentView.frame.size.height)];
    [visualView setAutoresizingMask:NSViewWidthSizable | NSViewHeightSizable];
    visualView.material = NSVisualEffectMaterialUnderWindowBackground;
    visualView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualView.state = NSVisualEffectStateActive;
    
    // 空白view
    // 加上这个view 放在 visualeffect 后面
    // 使 effect 起作用
    NSView *bgview = [NSView new];
    bgview.frame = visualView.frame;
    [self.view.window.contentView  addSubview:visualView positioned:NSWindowBelow relativeTo:self.view];
    [self.view.window.contentView addSubview:bgview positioned:NSWindowBelow relativeTo:self.view];
}

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    if (self.view.window.toolbar == nil) {
        self.view.window.toolbar = _toolbar;
        if (@available(macOS 11.0, *)) {
            self.view.window.toolbarStyle = NSWindowToolbarStylePreference;
            [self makeWindowBlur];
        }
    }
}

- (void)blurView:(NSView *)view
{
    NSView *blurView = [[NSView alloc] initWithFrame:view.bounds];
    blurView.wantsLayer = YES;
    blurView.layer.backgroundColor = [NSColor clearColor].CGColor;
    blurView.layer.masksToBounds = YES;
    blurView.layerUsesCoreImageFilters = YES;
    blurView.layer.needsDisplayOnBoundsChange = YES;

    CIFilter *saturationFilter = [CIFilter filterWithName:@"CIColorControls"];
    [saturationFilter setDefaults];
    [saturationFilter setValue:@2.0 forKey:@"inputSaturation"];

    CIFilter *blurFilter = [CIFilter filterWithName:@"CIGaussianBlur"]; // Other blur types are available
    [blurFilter setDefaults];
    [blurFilter setValue:@2.0 forKey:@"inputRadius"];

    blurView.layer.backgroundFilters = @[saturationFilter, blurFilter];

    [view addSubview:blurView];

    [blurView.layer setNeedsDisplay];
}

- (void)showAbout
{
    NSString *identifier = NSLocalizedString(@"About", @"About prefs tab label");
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
    item.tag = 2; // 2 == index of About panel
    _toolbar.selectedItemIdentifier = identifier;
    [self switchToTabForToolbarItem:item animated:NO];
}

- (void)showPrefs
{
    if (_selectedItemTag == 2) { // 2 == index of About panel
        NSString *identifier = NSLocalizedString(@"General", @"General prefs tab label");
        NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:identifier];
        item.tag = 0; // 0 == index of General panel.
        _toolbar.selectedItemIdentifier = identifier;
        [self switchToTabForToolbarItem:item animated:NO];
    }
}

- (void)setChildViewControllers:(NSArray<__kindof NSViewController *> *)childViewControllers
{
    [super setChildViewControllers:childViewControllers];
    for (NSViewController *childViewController in childViewControllers) {
        [_toolbarIdentifiers addObject:childViewController.title];
    }
    [self.view setFrame:(NSRect){0, 0, childViewControllers[0].view.fittingSize}];
    [childViewControllers[0].view setFrame:self.view.bounds];
    [self.view addSubview:childViewControllers[0].view];
    [_toolbar setSelectedItemIdentifier:_toolbarIdentifiers[0]];
}

- (void)toolbarItemClicked:(NSToolbarItem *)item
{
    [self switchToTabForToolbarItem:item animated:YES];
}

- (void)switchToTabForToolbarItem:(NSToolbarItem *)item animated:(BOOL)animated
{
    if (_selectedItemTag == item.tag) return;

    _selectedItemTag = item.tag;

    NSViewController *toVC = [self viewControllerForItemIdentifier:item.itemIdentifier];
    if (toVC) {

        if (self.view.subviews[2] == toVC.view) return;

        NSWindow *window = self.view.window;
        NSRect contentRect = (NSRect){0, 0, toVC.view.fittingSize};
        NSRect contentFrame = [window frameRectForContentRect:contentRect];
        CGFloat windowHeightDelta = window.frame.size.height - contentFrame.size.height;
        NSPoint newOrigin = NSMakePoint(window.frame.origin.x, window.frame.origin.y + windowHeightDelta);
        NSRect newFrame = (NSRect){newOrigin, contentFrame.size};

        [toVC.view setAlphaValue: 0];
        [toVC.view setFrame:contentRect];
        [self.view addSubview:toVC.view];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [context setDuration:animated ? 0.2 : 0];
            [window.animator setFrame:newFrame display:false];
            [toVC.view.animator setAlphaValue:1];
            // 所有的view都加在 visualeffectview 上面
            // 所以index是2
            [self.view.subviews[2].animator setAlphaValue:0];
        } completionHandler:^{
            [self.view.subviews[2] removeFromSuperview];
        }];
    }
}

- (void)toolbarItemClicked2:(NSButton *)item
{
    [self switchToTabForToolbarItem2:item animated:YES];
}

- (void)switchToTabForToolbarItem2:(NSButton *)item animated:(BOOL)animated
{
    if (_selectedItemTag == item.tag) return;

    _selectedItemTag = item.tag;

    NSViewController *toVC = [self viewControllerForItemIdentifier:_toolbarIdentifiers[item.tag]];
    if (toVC) {

        if (self.view.subviews[0] == toVC.view) return;

        NSWindow *window = self.view.window;
        NSRect contentRect = (NSRect){0, 0, toVC.view.fittingSize};
        NSRect contentFrame = [window frameRectForContentRect:contentRect];
        CGFloat windowHeightDelta = window.frame.size.height - contentFrame.size.height;
        NSPoint newOrigin = NSMakePoint(window.frame.origin.x, window.frame.origin.y + windowHeightDelta);
        NSRect newFrame = (NSRect){newOrigin, contentFrame.size};

        [toVC.view setAlphaValue: 0];
        [toVC.view setFrame:contentRect];
        [self.view addSubview:toVC.view];

        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            [context setDuration:animated ? 0.2 : 0];
            [window.animator setFrame:newFrame display:NO];
            [toVC.view.animator setAlphaValue:1];
            [self.view.subviews[0].animator setAlphaValue:0];
        } completionHandler:^{
            [self.view.subviews[0] removeFromSuperview];
        }];
    }
}

- (NSViewController *)viewControllerForItemIdentifier:(NSString *)itemIdentifier
{
    for (NSViewController *vc in self.childViewControllers) {
        if ([vc.title isEqualToString:itemIdentifier]) return vc;
    }
    return nil;
}

#pragma mark -
#pragma mark NSToolbarDelegate

- (nullable NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier willBeInsertedIntoToolbar:(BOOL)flag
{
    NSToolbarItem *item = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
    item.label = itemIdentifier;
    
    NSImage *img = [NSImage imageNamed:NSStringFromClass([[self viewControllerForItemIdentifier:itemIdentifier] class])];
    [img setTemplate:true];
    
    NSColor *color = NSColor.secondaryLabelColor;
    NSImage *newImage = [img imageWith:color];
    [newImage setTemplate:true];
    
    item.image = newImage;
    item.target = self;
    item.action = @selector(toolbarItemClicked:);
    item.tag = [_toolbarIdentifiers indexOfObject:itemIdentifier];
    
    return item;
}

- (NSArray<NSString *> *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

- (NSArray<NSString *> *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

- (NSArray<NSString *> *)toolbarSelectableItemIdentifiers:(NSToolbar *)toolbar
{
    return _toolbarIdentifiers;
}

@end
