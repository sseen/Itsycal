//
//  TooltipViewController.m
//  Itsycal
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 mowglii.com. All rights reserved.
//

#import "TooltipViewController.h"
#import "Themer.h"
#import "SCUtils.h"

@implementation TooltipViewController

- (BOOL)toolTipForDate:(MoDate)date
{
    self.tv.enableHover = NO;
    self.tv.enclosingScrollView.hasVerticalScroller = NO; // in case user has System Prefs set to always show scroller
    self.events = [self.tooltipDelegate eventsForDate:date];
    
    NSString *todayDateStr = NSStringFromMoDateWithoutJulian(date);
    KCNATIONSTATUS todayType = [SCUtils whichNationDays:todayDateStr];
    NSNumber *typeNum = [NSNumber numberWithInteger:todayType];
    if (todayType & (KCNATIONSTATUSrelax | KCNATIONSTATUSwork)) {
        if (self.events) {
            NSMutableArray *addTypeArr = [NSMutableArray arrayWithObject:typeNum];
            [addTypeArr addObjectsFromArray:self.events];
            self.events = addTypeArr;
        } else {
            self.events = [NSArray arrayWithObject:typeNum];
        }
    }
    if (self.events) {
        [self reloadData];
        return YES;
    }
    return NO;
}

@end
