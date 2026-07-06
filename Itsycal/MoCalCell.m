//
//  MoCalCell.m
//
//
//  Created by Sanjay Madan on 12/3/14.
//  Copyright (c) 2014 Swittee.com. All rights reserved.
//

#import "MoCalCell.h"
#import "Themer.h"
#import "Sizer.h"

@implementation MoCalCell
{
    NSLayoutConstraint *_textFieldVerticalSpace;
    NSLayoutConstraint *_textFieldCenterYConstraint;
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
        _textFieldCenterYConstraint = [_textField.centerYAnchor constraintEqualToAnchor:self.centerYAnchor];
        _textFieldCenterYConstraint.active = true;
        [_textField.centerXAnchor constraintEqualToAnchor:self.centerXAnchor].active = true;
        
        ///
        /// 之前的布局约束
        /// 增加了cell尺寸后（农历），导致没有剧中
        /// 审核打回优化
        ///
        // [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_textField]|" options:NSLayoutFormatAlignAllCenterY metrics:0 views:NSDictionaryOfVariableBindings(_textField)]];
        // _textFieldVerticalSpace = [NSLayoutConstraint constraintWithItem:_textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:[[Sizer shared] cellTextFieldVerticalSpace]];
        // [self addConstraint:_textFieldVerticalSpace];

        // highlight line
        self.wantsLayer = true;
        _lineLayer = [CALayer layer];
        _lineLayer.borderColor = NSColor.clearColor.CGColor;
        _lineLayer.borderWidth = 0;
        _lineLayer.backgroundColor = NSColor.systemRedColor.CGColor;
        [self.layer addSublayer:_lineLayer];
        [self updateMonthStartIndicatorFrame];
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
    [self updateTextFieldCenterYOffset];
    [self updateMonthStartIndicatorFrame];
}

- (void)layout
{
    [super layout];
    [self updateMonthStartIndicatorFrame];
}

- (void)setUsesLunarTextLayout:(BOOL)usesLunarTextLayout
{
    if (_usesLunarTextLayout != usesLunarTextLayout) {
        _usesLunarTextLayout = usesLunarTextLayout;
        [self updateTextFieldCenterYOffset];
    }
}

- (void)updateTextFieldCenterYOffset
{
    _textFieldCenterYConstraint.constant = self.usesLunarTextLayout ? [[Sizer shared] cellLunarTextCenterYOffset] : 0;
}

- (void)updateMonthStartIndicatorFrame
{
    CGFloat x = [[Sizer shared] cellMonthStartIndicatorX];
    CGFloat width = [[Sizer shared] cellMonthStartIndicatorWidth];
    CGFloat inset = [[Sizer shared] cellMonthStartIndicatorVerticalInset];
    CGFloat height = MAX(0, NSHeight(self.bounds) - (2 * inset));
    _lineLayer.frame = NSMakeRect(x, inset, width, height);
    _lineLayer.cornerRadius = width / 2.0;
    _lineLayer.backgroundColor = NSColor.systemRedColor.CGColor;
}

- (void)setCstatus:(KCNATIONSTATUS)cstatus {
    _cstatus = cstatus;
    [self setNeedsDisplay:YES];
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
    if (self.isToday) {
        [Theme.todayCellColor set];
        NSRect r = NSInsetRect(self.bounds, inset, inset);
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
        [p setLineWidth:1];
        [p stroke];
    }
    else if (self.isHovered) {
        [Theme.hoveredCellColor set];
        NSRect r = NSInsetRect(self.bounds, inset, inset);
        //NSRect r = NSOffsetRect(r0, offsetx, offsety);
        NSBezierPath *p = [NSBezierPath bezierPathWithRoundedRect:r xRadius:radius yRadius:radius];
        [p setLineWidth:1];
        [p stroke];
    }
    if (self.dotColors) {
        CGFloat dotWidth = [[Sizer shared] cellDotWidth];
        CGFloat dotSpacing = 1.5 * dotWidth;
        NSUInteger dotCount = self.dotColors.count == 0 ? 1 : MIN(self.dotColors.count, 3);
        CGFloat firstCenterX = NSMidX(self.bounds) - (dotSpacing * (dotCount - 1) / 2.0);
        NSRect r = NSMakeRect(0, 0, dotWidth, dotWidth);
        r.origin.y = self.bounds.origin.y + [[Sizer shared] cellDotOriginY];
        for (NSUInteger i = 0; i < dotCount; i++) {
            NSColor *dotColor = self.dotColors.count == 0 ? self.textField.textColor : self.dotColors[i];
            r.origin.x = round(firstCenterX + (dotSpacing * i) - dotWidth / 2.0);
            [self dotColor:dotColor rect:r];
        }
    }

    if (self.cstatus != KCNATIONSTATUSnormal) {

        CGFloat badgeInset = [[Sizer shared] cellHolidayBadgeInset];
        NSRect r = NSInsetRect(self.bounds, badgeInset, badgeInset);
        NSBezierPath* ovalPath = [NSBezierPath bezierPath];

        NSColor *nationColor = _cstatus == KCNATIONSTATUSwork ? Theme.cnWork : Theme.cnRelax;

        CGFloat holidayRadius = [[Sizer shared] cellHolidayBadgeRadius];
        CGFloat holidayHalfR = holidayRadius / 2.0;
        CGFloat maxX = NSMaxX(r);
        CGFloat maxY = NSMaxY(r);
        CGFloat xStart = maxX - holidayRadius;
        CGFloat yEnd = maxY - holidayRadius;
        [ovalPath moveToPoint:NSMakePoint(xStart, maxY)];
        [ovalPath lineToPoint:NSMakePoint(maxX, maxY)];
        [ovalPath lineToPoint:NSMakePoint(maxX, yEnd)];
        [ovalPath curveToPoint:NSMakePoint(xStart, maxY)
                 controlPoint1:NSMakePoint(maxX - holidayHalfR, yEnd)
                 controlPoint2:NSMakePoint(xStart, maxY - holidayHalfR)];
        [ovalPath closePath];
        [nationColor setFill];
        [ovalPath fill];
    }
}

- (void)dotColor:(NSColor *)dotColor rect:(NSRect)r {
    [dotColor set];
    [[NSBezierPath bezierPathWithOvalInRect:r] fill];
}

@end
