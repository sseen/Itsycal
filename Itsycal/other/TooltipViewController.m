//
//  TooltipViewController.m
//  Itsycal
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 Swittee.com. All rights reserved.
//

#import "TooltipViewController.h"
#import "Themer.h"
#import "SCUtils.h"
#import "Itsycal.h"

@implementation TooltipViewController

- (BOOL)toolTipForDate:(MoDate)date
{
    self.tv.enableHover = NO;
    self.tv.enclosingScrollView.hasVerticalScroller = NO; // in case user has System Prefs set to always show scroller
    self.events = [self.tooltipDelegate eventsForDate:date];
    
    self.events = [SCUtils tansformCnholidayToEvents:self.events date:date];
    if (self.events) {
        [self reloadData];
        return YES;
    }
    return NO;
}

@end
