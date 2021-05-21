//
//  AgendaViewHolidayCell.m
//  Swittee Calendar
//
//  Created by solo on 2021/5/19.
//  Copyright © 2021 swittee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaViewHolidayCell.h"
#import "Sizer.h"

@interface TagField : NSButton

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSColor *bgColor;
@property (nonatomic) NSColor *foreColor;
@property (nonatomic) NSColor *highlightColor;

@end

@implementation TagField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    [self config];
}

- (void)config {
    if ([self isHighlighted]) {
        self.layer.backgroundColor = _highlightColor.CGColor;
    } else {
        self.layer.backgroundColor = _bgColor.CGColor;
    }
    self.layer.cornerRadius = _cornerRadius;
    
    NSAttributedString *one = [[NSAttributedString alloc] initWithString:self.title attributes:@{NSForegroundColorAttributeName:_foreColor}];
    self.attributedTitle = one;
}

@end

@implementation AgendaViewHolidayCell

- (instancetype)init
{
    // Convenience function for making labels.
    TagField* (^label)(void) = ^TagField* () {
        TagField *lbl = [[TagField alloc] initWithFrame:NSMakeRect(10, 15, 30, 16)];
        lbl.font = [NSFont systemFontOfSize:[[Sizer shared] dowFontSize]];
        [lbl setButtonType: NSButtonTypeMomentaryPushIn];
        // 加上border之后，texture效果里文字部分还是会有灰色的背景
        // 去掉boder，整个按钮轮廓缩小
        // 调整整体按钮大小来平衡
        [lbl setBezelStyle:NSBezelStyleTexturedSquare];//NSBezelStyleShadowlessSquare效果一样，就是必须去掉 border
        lbl.enabled = true;
        lbl.cornerRadius = 2;
        // 这里设置后，按钮的背景尺寸会变小
        [lbl setBordered:false];
        lbl.bgColor = NSColor.systemBlueColor;
        lbl.highlightColor = NSColor.systemBlueColor;
        lbl.foreColor = NSColor.whiteColor;
        return lbl;
    };
    self = [super init];
    if (self) {
        self.identifier = @"HolidayCell";
        self.title = label();
        self.info = label();
        self.info.frame = NSMakeRect(50, 15, 100, 20);
        
        [self addSubview:_title];
        [self addSubview:_info];
        
        _title.translatesAutoresizingMaskIntoConstraints = false;
        _info.translatesAutoresizingMaskIntoConstraints = false;
        
        [NSLayoutConstraint activateConstraints:@[
            [[_title topAnchor] constraintEqualToAnchor:self.topAnchor constant:2],
            [_title.heightAnchor constraintEqualToConstant:20],
            [[_title leadingAnchor] constraintEqualToAnchor:self.leadingAnchor constant:10]
        ]];
        [NSLayoutConstraint activateConstraints:@[
            [[_info topAnchor] constraintEqualToAnchor:_title.topAnchor],
            [_info.heightAnchor constraintEqualToAnchor:_title.heightAnchor],
            [[_info leadingAnchor] constraintEqualToAnchor:_title.trailingAnchor constant:10]
        ]];

//        [_title setContentCompressionResistancePriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
//        [_info setContentCompressionResistancePriority:NSLayoutPriorityDefaultLow forOrientation:NSLayoutConstraintOrientationHorizontal];
    }
    return self;
}

- (void)setTitleName:(NSString *)str bgColor:(NSColor *)color {
    self.title.title = str;
    self.title.bgColor = color;
    [_title config];
}

- (void)setInfoName:(NSString *)str bgColor:(NSColor *)color {
    self.info.title = str;
    self.info.bgColor = color;
    [_info config];
}
@end
