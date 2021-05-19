//
//  AgendaViewHolidayCell.m
//  Swittee Calendar
//
//  Created by solo on 2021/5/19.
//  Copyright © 2021 swittee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgendaViewHolidayCell.h"

@interface TagField : NSButton

@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) NSColor *bgColor;
@property (nonatomic) NSColor *foreColor;

@end

@implementation TagField

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}

- (void)config {
    self.layer.backgroundColor = _bgColor.CGColor;
    self.layer.cornerRadius = _cornerRadius;
    
    NSAttributedString *one = [[NSAttributedString alloc] initWithString:@"hello" attributes:@{NSForegroundColorAttributeName:_foreColor}];
    self.attributedTitle = one;
}

@end

@implementation AgendaViewHolidayCell



@end
