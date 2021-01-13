//
//  MoCalCell.m
//
//
//  Created by Sanjay Madan on 12/3/14.
//  Copyright (c) 2014 mowglii.com. All rights reserved.
//

#import "MoCalCell.h"
#import "Themer.h"
#import "Sizer.h"

@implementation MoCalCell
{
    NSLayoutConstraint *_textFieldVerticalSpace;
}

- (instancetype)init
{
    CGFloat sz = [[Sizer shared] cellSize];
    self = [super initWithFrame:NSMakeRect(0, 0, sz, sz)];
    if (self) {
        _textField = [NSTextField labelWithString:@""];
        // 默认使用 dow font medium，后面 date font 会更新一次使用 regular
        [_textField setFont:[[Sizer shared] dowFont]];
        [_textField setTextColor:[NSColor blackColor]];
        [_textField setAlignment:NSTextAlignmentCenter];
        [_textField setTranslatesAutoresizingMaskIntoConstraints:NO];

        [self addSubview:_textField];

        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textField]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_textField)]];
        
        _textFieldVerticalSpace = [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:[[Sizer shared] cellTextFieldVerticalSpace]];
        [self addConstraint:_textFieldVerticalSpace];

        // highlight line
        self.wantsLayer = true;
        _lineLayer = [CALayer layer];
        _lineLayer.borderColor = NSColor.clearColor.CGColor;
        _lineLayer.borderWidth = 0;
        _lineLayer.frame = NSMakeRect(5, 1, CGRectGetWidth(self.bounds) - 10, 1);
        _lineLayer.backgroundColor = NSColor.redColor.CGColor;
        [self.layer addSublayer:_lineLayer];
        _lineLayer.hidden = true;
        
        _cstatus = KCNATIONSTATUSnormal;
        
        REGISTER_FOR_SIZE_CHANGE;
    }
    return self;
}

- (void)sizeChanged:(id)sender
{
    [_textField setFont:[NSFont systemFontOfSize:[[Sizer shared] fontSize] weight:NSFontWeightMedium]];
    _textFieldVerticalSpace.constant = [[Sizer shared] cellTextFieldVerticalSpace];
}

- (void)setIsToday:(BOOL)isToday {
    _isToday = isToday;
    [self setNeedsDisplay:YES];
}

- (void)setIsHighlighted:(BOOL)isHighlighted {
    _isHighlighted = isHighlighted;
    [self updateTextColor];
}

- (void)setIsInCurrentMonth:(BOOL)isInCurrentMonth {
    _isInCurrentMonth = isInCurrentMonth;
    [self updateTextColor];
}

- (void)setIsSelected:(BOOL)isSelected
{
    if (isSelected != _isSelected) {
        _isSelected = isSelected;
        [self setNeedsDisplay:YES];
    }
}

- (void)setIsHovered:(BOOL)isHovered
{
    if (isHovered != _isHovered) {
        _isHovered = isHovered;
        [self setNeedsDisplay:YES];
    }
}

- (void)setDotColors:(NSArray<NSColor *> *)dotColors
{
    _dotColors = dotColors;
    [self setNeedsDisplay:YES];
}

- (void)updateTextColor {
    self.textField.textColor = self.isInCurrentMonth ? Theme.currentMonthTextColor : Theme.noncurrentMonthTextColor;
}

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat offsetx __attribute__((unused)) = 0;
    CGFloat offsety __attribute__((unused)) = -2;
    CGFloat inset = 1;
    CGFloat radius = [[Sizer shared] cellRadius];
    NSRect r = NSInsetRect(self.bounds, inset, inset);
    if (self.isToday) {
        [Theme.todayCellColor setFill];
        //[Theme.todayCellOutlineColor setStroke];
        //NSRect r = NSOffsetRect(r0, offsetx, offsety);
        NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:r xRadius:radius yRadius:radius];
        [p fill];
        //[p stroke];
    }
    else if (self.isSelected) {
        [Theme.selectedCellColor set];
        NSRect r = NSInsetRect(self.bounds, inset, inset);
        //NSRect r = NSOffsetRect(r0, offsetx, offsety);
        NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:r xRadius:radius yRadius:radius];
        [p setLineWidth:2];
        [p stroke];
    }
    else if (self.isHovered) {
        [Theme.hoveredCellColor set];
        NSRect r = NSInsetRect(self.bounds, inset, inset);
        //NSRect r = NSOffsetRect(r0, offsetx, offsety);
        NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:r xRadius:radius yRadius:radius];
        [p setLineWidth:2];
        [p stroke];
    }
    if (self.dotColors) {
        CGFloat sz = [[Sizer shared] cellSize];
        CGFloat dotWidth = [[Sizer shared] cellDotWidth];
        CGFloat dotSpacing = 1.5*dotWidth;
        NSRect r = NSMakeRect(0, 0, dotWidth, dotWidth);
        r.origin.y = self.bounds.origin.y + dotWidth - 2.5;
        if (self.dotColors.count == 0) {
            [self.textField.textColor set];
            r.origin.x = self.bounds.origin.x + sz/2.0 - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
        }
        else if (self.dotColors.count == 1) {
            [self.dotColors[0] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
        }
        else if (self.dotColors.count == 2) {
            [self.dotColors[0] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 - dotSpacing/2 - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
            
            [self.dotColors[1] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 + dotSpacing/2 - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
        }
        else if (self.dotColors.count == 3) {
            [self.dotColors[0] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 - dotSpacing - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
            
            [self.dotColors[1] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
            
            [self.dotColors[2] set];
            r.origin.x = self.bounds.origin.x + sz/2.0 + dotSpacing - dotWidth/2.0;
            [[NSBezierPath bezierPathWithOvalInRect:r] fill];
        }
    }
    
    if (_cstatus != KCNATIONSTATUSnormal) {
        NSBezierPath* ovalPath = [NSBezierPath bezierPath];
        
        NSColor *nationColor = _cstatus == KCNATIONSTATUSwork ? Theme.cnWork : Theme.cnRelax;
        
        CGFloat holidayRadius = 8;
        CGFloat holidayHalfR = 4;
        CGFloat frameWidth = r.size.width + 1;
        CGFloat frameHeight = r.size.height + 1;
        CGFloat xStart = frameWidth - holidayRadius;
        CGFloat yEnd = frameHeight - holidayRadius;
        [ovalPath moveToPoint: NSMakePoint(xStart, frameHeight)];
        [ovalPath lineToPoint: NSMakePoint(frameWidth, frameHeight)];
        [ovalPath lineToPoint: NSMakePoint(frameWidth, yEnd)];
        [ovalPath curveToPoint: NSMakePoint(xStart, frameHeight) controlPoint1: NSMakePoint(frameWidth - holidayHalfR, yEnd)  controlPoint2: NSMakePoint(xStart,frameHeight-holidayHalfR)];
        [ovalPath closePath];
        [nationColor setFill];
        [ovalPath fill];
        [Theme.mainBackgroundColor setStroke];
        ovalPath.lineWidth = 1;
        [ovalPath stroke];
    }
    
}

@end
