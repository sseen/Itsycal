//
//  SNPlister.m
//  Swittee Calendar
//
//  Created by solo on 2021/1/13.
//  Copyright © 2021 Swittee.com. All rights reserved.
//

#import "SNPlister.h"
#import "MoDate.h"

@implementation SNPlister

// static 全局变量
SNPlister *SNPlist = nil;
static NSDictionary *nationWorkDays = nil;
static NSDictionary *nationRelaxdays = nil;

+ (instancetype)shared
{
    static SNPlister *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[SNPlister alloc] init];
        SNPlist = shared;
    });
    return shared;
}

/// get
- (NSDictionary *)cNationWorkDays {
    if (!nationWorkDays) {
        [self cNationDays];
    }
    return nationWorkDays;
}


/// get
- (NSDictionary *)cNationRelaxDays {
    if (!nationRelaxdays) {
        [self cNationDays];
    }
    return nationRelaxdays;
}


/// 生成中国官方节假日，包括放假，补班信息
- (void)cNationDays {
    MoDate today = todayDate();
    [self cNationDays:today.year];
}

- (void)cNationDays:(NSInteger)year {
    NSString *yearStr = [NSString stringWithFormat:@"%ld", (long)year];
    NSDictionary *dic = [self getPlistDatas:@"CNationDays"];
    NSDictionary *yearData = dic[yearStr];

    nationRelaxdays = yearData[@"relax"];
    nationWorkDays  = yearData[@"work"];
}

- (void)reset:(NSInteger)year {
    [self cNationDays:year];
}

/// 读取 plist 文件
/// @param fileName the name of plist file
- (NSMutableDictionary *)getPlistDatas:(NSString*)fileName{
    NSString *pathFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    // NSMutableArray *appConfig = [NSMutableArray arrayWithContentsOfFile:pathFile];
    NSMutableDictionary *appConfig = [NSMutableDictionary dictionaryWithContentsOfFile:pathFile];
    
    return appConfig;
}
@end
