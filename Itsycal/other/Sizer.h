// Created by Sanjay Madan on 7/27/18
// Copyright (c) 2018 Swittee.com

#import <Foundation/Foundation.h>
@class NSFont;

// NSUserDefaults key
extern NSString * const kSizePreference;

// Notification name
extern NSString * const kSizeDidChangeNotification;

// Convenience macro for notification observer for sizeable components
#define REGISTER_FOR_SIZE_CHANGE [[NSNotificationCenter defaultCenter] \
                                   addObserverForName:kSizeDidChangeNotification \
                                   object:nil queue:[NSOperationQueue mainQueue] \
                                   usingBlock:^(NSNotification *note) { \
                                   [self sizeChanged:nil];}];

typedef enum : NSInteger {
    SizePreferenceDefault = 0,
    SizePreferenceLarge = 1
} SizePreference;

@interface Sizer : NSObject

@property (nonatomic, readonly) NSFont* dowFont;
@property (nonatomic, readonly) NSFont* weekFont;
@property (nonatomic, readonly) NSFont* dateFont;
@property (nonatomic, readonly) NSFont* dateLunarFont;
@property (nonatomic) SizePreference sizePreference;
@property (nonatomic, readonly) CGFloat dowFontSize;
@property (nonatomic, readonly) CGFloat weekFontSize;
@property (nonatomic, readonly) CGFloat fontSize;
@property (nonatomic, readonly) CGFloat calendarTitleFontSize;
@property (nonatomic, readonly) CGFloat cellSize;
@property (nonatomic, readonly) CGFloat cellTextFieldVerticalSpace;
@property (nonatomic, readonly) CGFloat cellDotWidth;
@property (nonatomic, readonly) CGFloat cellDotOriginY;
@property (nonatomic, readonly) CGFloat cellRadius;
@property (nonatomic, readonly) CGFloat cellHolidayBadgeRadius;
@property (nonatomic, readonly) CGFloat cellHolidayBadgeInset;
@property (nonatomic, readonly) CGFloat cellMonthStartIndicatorX;
@property (nonatomic, readonly) CGFloat cellMonthStartIndicatorWidth;
@property (nonatomic, readonly) CGFloat cellMonthStartIndicatorVerticalInset;
@property (nonatomic, readonly) CGFloat cellLunarLineHeightMultiple;
@property (nonatomic, readonly) CGFloat cellLunarTextCenterYOffset;
@property (nonatomic, readonly) CGFloat agendaEventLeadingMargin;
@property (nonatomic, readonly) CGFloat agendaDotWidth;

+ (instancetype)shared;

@end
