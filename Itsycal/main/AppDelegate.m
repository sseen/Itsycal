//
//  AppDelegate.m
//  Itsycal
//
//  Created by Sanjay Madan on 2/4/15.
//  Copyright (c) 2015 mowglii.com. All rights reserved.
//

#import "AppDelegate.h"
#import "Itsycal.h"
#import "ItsycalWindow.h"
#import "ViewController.h"
#import "Themer.h"
#import "Sizer.h"
#import "MASShortcut/MASShortcutBinder.h"
#import "MASShortcut/MASShortcutMonitor.h"
#import "MoUtils.h"

#import "SNPlister.h"

@import AppCenter;
@import AppCenterAnalytics;
@import AppCenterCrashes;

@implementation AppDelegate
{
    NSWindowController *_wc;
}

- (NSMutableArray *)getPlistDatas {
    NSString *pathFile = [[NSBundle mainBundle] pathForResource:@"CNationDays" ofType:@"plist"];
    NSMutableArray *appConfig = [NSMutableArray arrayWithContentsOfFile:pathFile];
    
    return appConfig;
}

+ (void)initialize
{
    // Get the default firstWeekday for user's locale.
    // User can change this in preferences.
    NSCalendar *cal = [NSCalendar autoupdatingCurrentCalendar];
    NSInteger weekStartDOW = MIN(MAX(cal.firstWeekday - 1, 0), 6);
    Boolean isCn = NO;
    if ([cal.locale.countryCode isEqual:@"CN"]) {
        isCn = YES;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:@{
        kPinItsycal:           @(NO),
        kShowWeeks:            @(NO),
        kHighlightedDOWs:      @0,
        kShowEventDays:        @7,
        kWeekStartDOW:         @(weekStartDOW), // Sun=0, Mon=1,... (MoCalendar.h)
        kShowMonthInIcon:      @(NO),
        kUseEmojiIcon:         @(NO),
        kUseEmojiIconHideFace: @(NO),
        kShowDayOfWeekInIcon:  @(NO),
        kShowEventDots:        @(YES),
        kUseColoredDots:       @(YES),
        kThemePreference:      @0, // System=0, Light=1, Dark=2
        kShowCnLunar:          @(isCn),
        kshowCnNationDays:     @(isCn),
        kHideIcon:             @(NO)
    }];
    
    // Constrain kShowEventDays to values 0...9 in (unlikely) case it is invalid.
    NSInteger validDays = MIN(MAX([defaults integerForKey:kShowEventDays], 0), 9);
    [defaults setInteger:validDays forKey:kShowEventDays];
    
    // Set kThemePreference to defaultThemePref in the unlikely case it's invalid.
    NSInteger themePref = [defaults integerForKey:kThemePreference];
    if (themePref < 0 || themePref > 2) {
        [defaults setInteger:0 forKey:kThemePreference];
    }
    
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // app center init
    [MSACAppCenter start:@"28ac792f-9fcb-42ec-b902-8c44a4511602" withServices:@[
      [MSACAnalytics class],
      [MSACCrashes class]
    ]];
    
    // Ensure the user has moved Itsycal to the /Applications folder.
    // Having the user manually move Itsycal to /Applications turns off
    // Gatekeeper Path Randomization (introduced in 10.12) and allows
    // Itsycal to be updated with Sparkle. :P
//#ifndef DEBUG
//    [self checkIfRunFromApplicationsFolder];
//#endif

    // Initialize the 'Theme' global variable which can be
    // used throught the app instead of '[Themer shared]'.
    [Themer shared];
    [SNPlister shared];

    // 0.11.1 introduced a new way to highlight columns in the calendar.
    [self weekendHighlightFixup];
    
    // 0.11.11 uses a new theme preference scheme that enables following
    // the system's appearance.
    [self themeFixup];

    // Register keyboard shortcut.
    [[MASShortcutBinder sharedBinder] bindShortcutWithDefaultsKey:kKeyboardShortcut toAction:^{
         [(ViewController *)self->_wc.contentViewController keyboardShortcutActivated];
     }];

    // This call instantiates the Sizer shared object and then
    // establishes the binding to NSUserDefaultsController. This call
    // must be made BEFORE the window is created because sizes are
    // used when initializing views.
    [[Sizer shared] bind:@"sizePreference" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kSizePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    ViewController *vc = [ViewController new];
    _wc = [[NSWindowController alloc] initWithWindow:[ItsycalWindow  new]];
    _wc.contentViewController = vc;
    _wc.window.delegate = vc;
    
    // Establish the binding to NSUserDefaultsController. On macOS
    // 10.14+, it is crucial for this call to be made AFTER the window
    // is created because Theme instantiation relies on checking a
    // property on the window to determine its appearance.
    [Theme bind:@"themePreference" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kThemePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [(ViewController *)_wc.contentViewController removeStatusItem];
    [[MASShortcutMonitor sharedMonitor] unregisterAllShortcuts];
}

#pragma mark -
#pragma mark Applications folder check

- (void)checkIfRunFromApplicationsFolder
{
    // This check can be short-circuited.
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kAllowOutsideApplicationsFolder]) {
        return;
    }
    NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
    NSArray *applicationDirs = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSLocalDomainMask | NSUserDomainMask, YES);
    for (NSString *appDir in applicationDirs) {
        if ([bundlePath hasPrefix:appDir]) {
            return; // Ok, Itsycal is being run from /Applications.
        }
    }
    // Itsycal is not being run from /Applications.
    [[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
    NSAlert *alert = [NSAlert new];
    alert.messageText = NSLocalizedString(@"Move Swittee Calendar to the Applications folder", nil);
    alert.informativeText = [NSLocalizedString(@"Swittee Calendar must be run from the Applications folder in order to work properly.\n\nPlease quit Swittee Calendar, move it to the Applications folder, and relaunch.", nil) stringByAppendingString:[NSString stringWithFormat:@"\n\n%@", bundlePath]];
    alert.icon = [NSImage imageNamed:@"move"];
    alert.showsHelp = YES;
    alert.delegate = self;
    [alert addButtonWithTitle:NSLocalizedString(@"Quit Swittee Calendar", @"")];
    [alert runModal];
    [NSApp terminate:nil];
}

- (BOOL)alertShowHelp:(NSAlert *)alert
{
    NSURL *url = [NSURL URLWithString:@"https://mowglii.com/itsycal/appfolder.html"];
    [[NSWorkspace sharedWorkspace] openURL:url];
    return YES;
}

#pragma mark -
#pragma mark Weekend highlight fixup

// Itsycal 0.11.1 moves away from using a trio of possible defaults
// (HighlightWeekend, WeekendIsFridaySaturday, WeekendIsSaturdaySunday) and
// a hardcoded list of countries with Fri/Sat weekends to the method
// of allowing the user to specify highlighted DOWs. If the user had
// HighlightWeekend == YES, migrate their highlight settings. In either
// case, remove the old default keys.
- (void)weekendHighlightFixup
{
    NSArray *countriesWithFridaySaturdayWeekend = @[
        @"AF", @"DZ", @"BH", @"BD", @"EG", @"IQ", @"JO", @"KW", @"LY",
        @"MV", @"OM", @"PS", @"QA", @"SA", @"SD", @"SY", @"AE", @"YE"];
    NSString *countryCode = [NSLocale currentLocale].countryCode;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"HighlightWeekend"]) {
        if ([defaults boolForKey:@"WeekendIsFridaySaturday"] ||
            [countriesWithFridaySaturdayWeekend containsObject:countryCode]) {
            // Fri + Sat = (1<<5) + (1<<6) = 32 + 64 = 96
            [defaults setInteger:96 forKey:kHighlightedDOWs];
        }
        else {
            // Sat + Sun = (1<<6) + (1<<0) = 64 + 1 = 65
            [defaults setInteger:65 forKey:kHighlightedDOWs];
        }
    }
    [defaults removeObjectForKey:@"HighlightWeekend"];
    [defaults removeObjectForKey:@"WeekendIsFridaySaturday"];
    [defaults removeObjectForKey:@"WeekendIsSaturdaySunday"];
}

// Itsycal 0.11.11 uses ThemePreference instead of ThemeIndex to
// express the user's theme preference. ThemePreference can be
// System in addition to explicitly Light or Dark.
- (void)themeFixup
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ThemeIndex"];
}

@end
