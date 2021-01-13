//
//  Created by Sanjay Madan on 6/12/17.
//  Copyright © 2017 mowglii.com. All rights reserved.
//

#import "Themer.h"
#import "Itsycal.h"
#import "MoUtils.h"

// NSUserDefaults key
NSString * const kThemePreference = @"ThemePreference";

@implementation Themer

Themer *Theme = nil;

+ (instancetype)shared
{
    static Themer *shared;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[Themer alloc] init];
        Theme = shared;
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _themePreference = [[NSUserDefaults standardUserDefaults] integerForKey:kThemePreference];
        [self adjustAppAppearanceForThemePreference];
    }
    return self;
}

- (void)setThemePreference:(ThemePreference)themePref {
    // Validate themePref before setting ivar.
    _themePreference = (themePref < 0 || themePref > 2) ? 0 : themePref;
    [self adjustAppAppearanceForThemePreference];
}

- (void)adjustAppAppearanceForThemePreference {
    switch (_themePreference) {
        case ThemePreferenceSystem:
            NSApp.appearance = nil;
            break;
        case ThemePreferenceDark:
            NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
            break;
        case ThemePreferenceLight:
        default:
            NSApp.appearance = [NSAppearance appearanceNamed:NSAppearanceNameAqua];
    }
}

- (NSColor *)agendaDayTextColor {
    return NSColor.secondaryLabelColor;
}

- (NSColor *)agendaDividerColor {
    return NSColor.separatorColor;
}

- (NSColor *)agendaDOWTextColor {
    return [self monthTextColor];
}

- (NSColor *)agendaEventDateTextColor {
    return NSColor.secondaryLabelColor;
}

- (NSColor *)agendaEventTextColor {
    return [self monthTextColor];
}

- (NSColor *)agendaHoverColor {
    return [self highlightedDOWBackgroundColor];
}

- (NSColor *)currentMonthOutlineColor {
    return [NSColor colorWithWhite:0.53 alpha:1];
}

- (NSColor *)DOWTextColor {
    return [self currentMonthTextColor];
}
- (NSColor *)DOWWeekEndTextColor {
//    return [NSColor colorNamed:@"currentMonthWeekEndText"];
    return NSColor.secondaryLabelColor;
}

- (NSColor *)highlightedDOWBackgroundColor {
    return [NSColor colorNamed:@"HighlightedDOWBackgroundColor"];
}

- (NSColor *)highlightedDOWTextColor {
    return NSColor.secondaryLabelColor;
}

- (NSColor *)hoveredCellColor {
    return NSColor.tertiaryLabelColor;
}

- (NSColor *)mainBackgroundColor {
    return NSColor.windowBackgroundColor;//[NSColor colorNamed:@"MainBackgroundColor"];
}

- (NSColor *)monthTextColor {
    return NSColor.labelColor;
}

- (NSColor *)currentMonthTextColor {
    return NSColor.labelColor;//[NSColor colorNamed:@"currentMonthText"];
}
- (NSColor *)noncurrentMonthTextColor {
//    return [NSColor colorNamed:@"noncurrentMonthText"];
    return NSColor.tertiaryLabelColor;
}
- (NSColor *)currentMonthWeekEndText {
//    return [NSColor colorNamed:@"currentMonthWeekEndText"];
    return NSColor.secondaryLabelColor;
}

- (NSColor *)cnWork {
    return [NSColor colorNamed:@"cnWork"];
}

- (NSColor *)cnRelax {
    return [NSColor colorNamed:@"cnRelax"];
}

- (NSColor *)lunarTextColor {
    return [NSColor colorNamed:@"lunarText"];
}
- (NSColor *)lunarWeekEndTextColor {
    return [NSColor colorNamed:@"lunarWeekEndText"];
}

- (NSColor *)resizeHandleBackgroundColor {
    return [self highlightedDOWBackgroundColor];
}

- (NSColor *)resizeHandleForegroundColor {
    return [NSColor colorNamed:@"ResizeHandleForegroundColor"];
}

- (NSColor *)selectedCellColor {
//    return [self currentMonthOutlineColor];
    return NSColor.secondaryLabelColor;
}

- (NSColor *)todayCellColor {
//    return [NSColor colorNamed:@"TodayCellColor"];
    return NSColor.systemRedColor
    ;
}
- (NSColor *)todayCellOutlineColor {
    return [NSColor colorWithRed:0.9 green:0.2 blue:0.1 alpha:1];
}

- (NSColor *)holidayTextColor {
    return [NSColor colorNamed:@"holidayText"];
}
- (NSColor *)holidayWeekEndTextColor {
    return [NSColor colorNamed:@"holidayWeekEndText"];
}

- (NSColor *)tooltipBackgroundColor {
    return [self mainBackgroundColor];
}

- (NSColor *)weekTextColor {
    return NSColor.secondaryLabelColor;
}

- (NSColor *)windowBorderColor {
    return [NSColor colorNamed:@"WindowBorderColor"];
}


@end
