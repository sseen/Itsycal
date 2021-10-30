//
//  MoCalToolTipWC.h
//  
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 Swittee.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MoDate.h"
#import "MoCalTooltipProvider.h"

@interface MoCalToolTipWC : NSWindowController

@property (nonatomic) NSViewController<MoCalTooltipProvider> *vc;

- (void)showTooltipForDate:(MoDate)date relativeToRect:(NSRect)rect screenFrame:(NSRect)screenFrame;
- (void)hideTooltip;
- (void)endTooltip;

@end
