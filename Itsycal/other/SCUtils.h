//
//  SCUtils.h
//  Swittee Calendar
//
//  Created by solo on 1/16/21.
//  Copyright © 2021 mowglii.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoCalCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SCUtils : NSObject
+ (KCNATIONSTATUS)whichNationDays:(NSString *)dateStr;
@end

NS_ASSUME_NONNULL_END
