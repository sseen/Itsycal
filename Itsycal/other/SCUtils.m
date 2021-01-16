//
//  SCUtils.m
//  Swittee Calendar
//
//  Created by solo on 1/16/21.
//  Copyright © 2021 mowglii.com. All rights reserved.
//

#import "SCUtils.h"
#import "SNPlister.h"

@implementation SCUtils


/// return which type nation days 返回节假日类型
/// @param dateStr string like yyyy-mm-dd
+ (KCNATIONSTATUS)whichNationDays:(NSString *)dateStr {
    KCNATIONSTATUS rt = KCNATIONSTATUSnormal;
    
    NSArray *workArray = SNPlist.cNationWorkDays;
    NSArray *relaxArray = SNPlist.cNationRelaxDays;
    
    if ([workArray indexOfObject:dateStr] != NSNotFound) {
        rt = KCNATIONSTATUSwork;
    } else if ([relaxArray indexOfObject:dateStr] != NSNotFound) {
        rt = KCNATIONSTATUSrelax;
    }
    
    return rt;
}
@end
