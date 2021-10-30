//
//  SCUtils.h
//  Swittee Calendar
//
//  Created by solo on 1/16/21.
//  Copyright © 2021 Swittee.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoCalCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCUtils : NSObject

@property (class) NSString *holidayName;

+ (KCNATIONSTATUS)whichNationDays:(NSString *)dateStr;

- (NSString *)getLunarDay:(NSDate *)day;
- (NSString *)getLunarMonth:(NSDate *)day;
- (NSString *)getLunarYear:(NSDate *)day;
+ (NSDateComponents *)getCNLunarComponentsWithDay:(NSDate *)day;
+ (NSArray *)tansformCnholidayToEvents:(NSArray *)events date:(MoDate)date;
@end

NS_ASSUME_NONNULL_END
