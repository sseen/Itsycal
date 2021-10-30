//
//  MoCalTooltipProvider.h
//  
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 Swittee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoDate.h"

@protocol MoCalTooltipProvider <NSObject>

// Return YES for success (date has a tooltip).
- (BOOL)toolTipForDate:(MoDate)date;

@end
