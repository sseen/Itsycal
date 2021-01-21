//
//  SCUtils.m
//  Swittee Calendar
//
//  Created by solo on 1/16/21.
//  Copyright © 2021 mowglii.com. All rights reserved.
//

#import "SCUtils.h"
#import "SNPlister.h"
#import "Itsycal.h"

@implementation SCUtils
static NSString *_holidayStr = nil;

/// return which type nation days 返回节假日类型
/// @param dateStr string like yyyy-mm-dd
+ (KCNATIONSTATUS)whichNationDays:(NSString *)dateStr {
    KCNATIONSTATUS rt = KCNATIONSTATUSnormal;
    Boolean isShowCnNationDays= [[NSUserDefaults standardUserDefaults] boolForKey:kshowCnNationDays];
    if (isShowCnNationDays) {
        NSArray *workArray = [SNPlist.cNationWorkDays allKeys];
        NSArray *relaxArray = [SNPlist.cNationRelaxDays allKeys];
        
        if ([workArray indexOfObject:dateStr] != NSNotFound) {
            rt = KCNATIONSTATUSwork;
            _holidayStr = SNPlist.cNationWorkDays[dateStr];
        } else if ([relaxArray indexOfObject:dateStr] != NSNotFound) {
            rt = KCNATIONSTATUSrelax;
            _holidayStr = SNPlist.cNationRelaxDays[dateStr];
        }
    }
    
    return rt;
}

+ (NSString *)holidayName {
    return _holidayStr;
}

+ (void)setHolidayName:(NSString *)holidayName {
    _holidayStr = holidayName;
}
@end
