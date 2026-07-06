//
//  Created by Sanjay Madan on 1/11/17.
//  Copyright © 2017 Swittee.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class EventCenter;

@interface PrefsGeneralVC : NSViewController <NSTableViewDataSource, NSTableViewDelegate>

@property (nonatomic, weak) EventCenter *ec;
@property (nonatomic, copy) NSString *holidayHintCalendarIdentifier;

- (void)showPendingHolidayHintIfPossible;

@end
