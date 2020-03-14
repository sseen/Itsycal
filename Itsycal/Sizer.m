// Created by Sanjay Madan on 7/27/18
// Copyright (c) 2018 mowglii.com

#import "Sizer.h"
#import <AppKit/AppKit.h>

// NSUserDefaults key
NSString * const kSizePreference = @"SizePreference";

// Notification names
NSString * const kSizeDidChangeNotification = @"SizeDidChangeNotification";

#define SMALL_OR_BIG(sm, bg) (self.sizePreference == SizePreferenceLarge ? (bg) : (sm))

@implementation Sizer

+ (instancetype)shared {
    static Sizer *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[Sizer alloc] init];
    });
    return shared;
}

- (void)setSizePreference:(SizePreference)sizePreference {
    _sizePreference = sizePreference;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSizeDidChangeNotification object:nil];
}

- (CGFloat)dowFontSize {
    return SMALL_OR_BIG(14, 16);
}

- (CGFloat)weekFontSize {
    return SMALL_OR_BIG(12, 14);
}

- (CGFloat)fontSize {
    return SMALL_OR_BIG(18, 20);
}

- (CGFloat)dateLunarSize {
    return SMALL_OR_BIG(10, 12);
}

- (CGFloat)calendarTitleFontSize {
    return SMALL_OR_BIG(16, 18);
}

- (CGFloat)cellSize {
    return SMALL_OR_BIG(38, 42);
}

- (CGFloat)cellTextFieldVerticalSpace {
    return SMALL_OR_BIG(2, 2);
}

- (CGFloat)cellDotWidth {
    return SMALL_OR_BIG(3, 4);
}

- (CGFloat)cellRadius {
    return SMALL_OR_BIG(2, 3);
}

- (CGFloat)agendaDotWidth {
    return SMALL_OR_BIG(6, 7);
}

- (CGFloat)agendaEventLeadingMargin {
    return SMALL_OR_BIG(15, 16);
}

- (NSFont *)dowFont {
    return [NSFont systemFontOfSize:[self dowFontSize] weight:NSFontWeightMedium];
}

- (NSFont *)weekFont {
    return [self arialWithSize:[self weekFontSize]];
}

- (NSFont *)dateFont {
    return [self arialWithSize:[self fontSize]];
}

- (NSFont *)dateLunarFont {
    return [NSFont systemFontOfSize:[self dateLunarSize] weight:NSFontWeightMedium];
}


- (NSFont *)arialWithSize:(CGFloat)size {
    return [NSFont fontWithName:@"Arial" size:size];
}
@end
