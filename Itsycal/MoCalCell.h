//
//  MoCalCell.h
//
//
//  Created by Sanjay Madan on 12/3/14.
//  Copyright (c) 2014 Swittee.com. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "MoDate.h"

/// work | relax 11
/// work & ( work | relax) true
/// normal & ( work | relax) false
typedef enum: NSInteger {
    KCNATIONSTATUSnormal = 0,  // 0
    KCNATIONSTATUSwork = 1<<0, // 1
    KCNATIONSTATUSrelax = 1<<1,// 10
}KCNATIONSTATUS;

@interface MoCalCell : NSView

@property (nonatomic) NSTextField *textField;
@property (nonatomic) MoDate date;
@property (nonatomic) BOOL isToday;
@property (nonatomic) BOOL isHighlighted;
@property (nonatomic) BOOL isInCurrentMonth;
@property (nonatomic) BOOL isHovered;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) CALayer *lineLayer;
@property (nonatomic,assign) KCNATIONSTATUS cstatus;

// An array of up to 3 colors.
// - Nil means do not draw a dot.
// - An empty array means draw a single dot in the default theme color.
// - Otherwise, draw up to 3 dots with the given colors.
@property (nonatomic) NSArray<NSColor *> *dotColors;

@end
