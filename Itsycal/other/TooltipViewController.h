//
//  TooltipViewController.h
//  Itsycal
//
//  Created by Sanjay Madan on 2/17/15.
//  Copyright (c) 2015 mowglii.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AgendaViewController.h"
#import "MoCalTooltipProvider.h"
#import "MoDate.h"

@protocol TooltipViewControllerDelegate;

@interface TooltipViewController : AgendaViewController <MoCalTooltipProvider>

@property (nonatomic, weak) id<TooltipViewControllerDelegate> tooltipDelegate;

@end

@protocol TooltipViewControllerDelegate <NSObject>

- (NSArray *)eventsForDate:(MoDate)date;

@end
