//
//  SNPlister.m
//  Swittee Calendar
//
//  Created by solo on 2021/1/13.
//  Copyright © 2021 mowglii.com. All rights reserved.
//

#import "SNPlister.h"

@implementation SNPlister

SNPlister *SNPlist = nil;
static NSArray *nationWorkDays = nil;
static NSArray *nationRelaxdays = nil;

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

- (NSArray *)cNationWorkDays {
    if (!nationWorkDays) {
        [self cNationDays];
    }
    return nationWorkDays;
}

- (NSArray *)cNationRelaxDays {
    if (!nationRelaxdays) {
        [self cNationDays];
    }
    return nationRelaxdays;
}

- (void)cNationDays {
    NSDictionary *dic = [self getPlistDatas:@"CNationDays"];
    nationRelaxdays = dic[@"relax"];
    nationWorkDays  = dic[@"work"];
}

- (NSMutableDictionary *)getPlistDatas:(NSString*)fileName{
    NSString *pathFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    // NSMutableArray *appConfig = [NSMutableArray arrayWithContentsOfFile:pathFile];
    NSMutableDictionary *appConfig = [NSMutableDictionary dictionaryWithContentsOfFile:pathFile];
    
    return appConfig;
}
@end
