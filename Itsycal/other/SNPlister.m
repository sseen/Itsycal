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

- (NSDictionary *)cNationDays {
    return [self getPlistDatas:@"CNationDays"];
}

- (NSMutableDictionary *)getPlistDatas:(NSString*)fileName{
    NSString *pathFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    // NSMutableArray *appConfig = [NSMutableArray arrayWithContentsOfFile:pathFile];
    NSMutableDictionary *appConfig = [NSMutableDictionary dictionaryWithContentsOfFile:pathFile];
    
    return appConfig;
}
@end
