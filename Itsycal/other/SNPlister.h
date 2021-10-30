//
//  SNPlister.h
//  Swittee Calendar
//
//  Created by solo on 2021/1/13.
//  Copyright © 2021 Swittee.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface SNPlister : NSObject

extern SNPlister *SNPlist;

@property (nonatomic) NSDictionary* cNationWorkDays;
@property (nonatomic) NSDictionary* cNationRelaxDays;

+ (instancetype)shared;
@end

NS_ASSUME_NONNULL_END
