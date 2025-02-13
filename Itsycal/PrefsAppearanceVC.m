//
//  Created by Sanjay Madan on 1/11/17.
//  Copyright © 2017 Swittee.com. All rights reserved.
//

#import "PrefsAppearanceVC.h"
#import "Itsycal.h"
#import "HighlightPicker.h"
#import "MoVFLHelper.h"
#import "Themer.h"
#import "Sizer.h"
#import "MoUtils.h"
#import "NSDiyMenuTipsViewController.h"

@implementation PrefsAppearanceVC
{
    NSTextField *_dateTimeFormat;
    NSButton *_hideIcon;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView
{
    // View controller content view
    NSView *v = [NSView new];

    // Convenience function for making checkboxes.
    NSButton* (^chkbx)(NSString *) = ^NSButton* (NSString *title) {
        NSButton *chkbx = [NSButton checkboxWithTitle:title target:self action:nil];
        [v addSubview:chkbx];
        return chkbx;
    };
    
    NSTextField *menubarLabel = [NSTextField labelWithString:NSLocalizedString(@"Menu Bar", @"")];
    NSTextField *calendarLabel = [NSTextField labelWithString:NSLocalizedString(@"Calendar", @"")];
    menubarLabel.font = [NSFont boldSystemFontOfSize:menubarLabel.font.pointSize-1];
    calendarLabel.font = [NSFont boldSystemFontOfSize:calendarLabel.font.pointSize-1];
    [v addSubview:menubarLabel];
    [v addSubview:calendarLabel];

    NSBox *separator0 = [NSBox new];
    NSBox *separator1 = [NSBox new];
    separator0.boxType = separator1.boxType = NSBoxSeparator;
    [v addSubview:separator0];
    [v addSubview:separator1];

    // Checkboxes
    NSButton *useBigMenuFont = chkbx(NSLocalizedString(@"Use larger text in icon", @""));
    NSButton *useOutlineIcon = chkbx(NSLocalizedString(@"Use outline icon", @""));
    NSButton *useEmojiIcon = chkbx(NSLocalizedString(@"Use Emoji icon", @""));
    NSButton *useEmojiIconHideFace = chkbx(NSLocalizedString(@"Hide face Emoji", @""));
    NSButton *showMonth = chkbx(NSLocalizedString(@"Show month in icon", @""));
    NSButton *showDayOfWeek = chkbx(NSLocalizedString(@"Show day of week in icon", @""));
//    NSButton *showCnLunarInIcon = chkbx(NSLocalizedString(@"Show Chinese lunar in icon", @""));
    
    NSButton *showEventDots = chkbx(NSLocalizedString(@"Show event dots", @""));
    NSButton *useColoredDots = chkbx(NSLocalizedString(@"Use colored dots", @""));
    NSButton *showWeeks = chkbx(NSLocalizedString(@"Show calendar weeks", @""));
    NSButton *showCnLunar = chkbx(NSLocalizedString(@"Show Chinese lunar calendar", @""));
    NSButton *showCnNationDays = chkbx(NSLocalizedString(@"Show Chinese Official holidays", @""));
    NSButton *showLocation = chkbx(NSLocalizedString(@"Show event location", @""));
//    NSButton *bigger = chkbx(NSLocalizedString(@"Use larger text", @""));
    _hideIcon = chkbx(NSLocalizedString(@"Hide icon", @""));

    NSColorWell *workColorWell = [[NSColorWell alloc] init];
    NSColorWell *relaxColorWell = [[NSColorWell alloc] init];
    
//    [workColorWell bind:@"value" 
//               toObject:[NSUserDefaultsController sharedUserDefaultsController]
//            withKeyPath:[@"values." stringByAppendingString:kHolidayWorkColor]
//                options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
//                
//    [relaxColorWell bind:@"value"
//                toObject:[NSUserDefaultsController sharedUserDefaultsController]
//             withKeyPath:[@"values." stringByAppendingString:kHolidayRelaxColor]
//                 options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Datetime format text field
    _dateTimeFormat = [NSTextField textFieldWithString:@""];
    _dateTimeFormat.placeholderString = NSLocalizedString(@"Datetime pattern", @"");
    _dateTimeFormat.refusesFirstResponder = YES;
    _dateTimeFormat.bezelStyle = NSTextFieldRoundedBezel;
    _dateTimeFormat.usesSingleLineMode = YES;
    _dateTimeFormat.delegate = self;
    [v addSubview:_dateTimeFormat];

    // Datetime help button
    NSButton *helpButton = [NSButton buttonWithTitle:@"" target:self action:@selector(openHelpPage:)];
    helpButton.bezelStyle = NSBezelStyleHelpButton;
    [v addSubview:helpButton];

    // Highlight control
//    HighlightPicker *highlight = [HighlightPicker new];
//    highlight.target = self;
//    highlight.action = @selector(didChangeHighlight:);
//    [v addSubview:highlight];

    // Theme label
    NSTextField *themeLabel = [NSTextField labelWithString:NSLocalizedString(@"Theme:", @"")];
    [v addSubview:themeLabel];

    // Theme popup
    NSPopUpButton *themePopup = [NSPopUpButton new];
    [themePopup addItemWithTitle:NSLocalizedString(@"System", @"System theme name")];
    [themePopup addItemWithTitle:NSLocalizedString(@"Light", @"Light theme name")];
    [themePopup addItemWithTitle:NSLocalizedString(@"Dark", @"Dark theme name")];
    // The tags will be used to bind the selected theme
    // preference to NSUserDefaults.
    [themePopup itemAtIndex:0].tag = ThemePreferenceSystem;
    [themePopup itemAtIndex:1].tag = ThemePreferenceLight;
    [themePopup itemAtIndex:2].tag = ThemePreferenceDark;
    [v addSubview:themePopup];
    
    
    MoVFLHelper *vfl = [[MoVFLHelper alloc] initWithSuperview:v metrics:@{@"m": @25, @"mm": @50, @"m3m":@65, @"top": @100} views:NSDictionaryOfVariableBindings(menubarLabel, calendarLabel, separator0, separator1, useOutlineIcon, useEmojiIcon, useEmojiIconHideFace, showMonth, showDayOfWeek, showEventDots, useColoredDots, showWeeks, showLocation, showCnLunar, showCnNationDays, _dateTimeFormat, helpButton, _hideIcon, themeLabel, themePopup, useBigMenuFont)];
    [vfl :@"V:|-top-[menubarLabel]-10-[useBigMenuFont]-[useOutlineIcon]-[useEmojiIcon]-[useEmojiIconHideFace]-[showMonth]-[showDayOfWeek]-[_dateTimeFormat]-[_hideIcon]-m-[calendarLabel]-10-[themePopup]-m-[showEventDots]-[useColoredDots]-[showLocation]-[showWeeks]-[showCnLunar]-[showCnNationDays]-m-|"];
    [vfl :@"H:|-m-[menubarLabel]-[separator0(>=205)]-m-|" :NSLayoutFormatAlignAllCenterY];
    [vfl :@"H:|-m-[calendarLabel]-[separator1]-m-|" :NSLayoutFormatAlignAllCenterY];
    [vfl :@"H:|-mm-[useBigMenuFont]-(>=m)-|"];
    [vfl :@"H:|-mm-[useOutlineIcon]-(>=m)-|"];
    [vfl :@"H:|-mm-[useEmojiIcon]-(>=m)-|"];
    [vfl :@"H:|-m3m-[useEmojiIconHideFace]-(>=m)-|"];
    [vfl :@"H:|-mm-[showMonth]-(>=m)-|"];
    [vfl :@"H:|-mm-[showDayOfWeek]-(>=m)-|"];
//    [vfl :@"H:|-mm-[showCnLunarInIcon]-(>=m)-|"];
    [vfl :@"H:|-mm-[_dateTimeFormat]-[helpButton]-m-|" :NSLayoutFormatAlignAllCenterY];
    [vfl :@"H:|-mm-[_hideIcon]-(>=m)-|"];
    [vfl :@"H:|-mm-[themeLabel]-[themePopup]-(>=m)-|" :NSLayoutFormatAlignAllFirstBaseline];
    [vfl :@"H:|-mm-[showEventDots]-(>=m)-|"];
    [vfl :@"H:|-m3m-[useColoredDots]-(>=m)-|"];
    [vfl :@"H:|-mm-[showLocation]-(>=m)-|"];
    [vfl :@"H:|-mm-[showWeeks]-(>=m)-|"];
    [vfl :@"H:|-mm-[showCnLunar]-(>=m)-|"];
    [vfl :@"H:|-mm-[showCnNationDays]-(>=m)-|"];

    // Bindings for icon preferences
    [useBigMenuFont bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseBigMenuFont] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    [useOutlineIcon bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseOutlineIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [useEmojiIcon bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseEmojiIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    [useEmojiIconHideFace bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseEmojiIconHideFace] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [useEmojiIconHideFace bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseEmojiIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    [showMonth bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowMonthInIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [showDayOfWeek bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowDayOfWeekInIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
//    [showCnLunarInIcon bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowCnLunarInIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    [_hideIcon bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    // Bind icon prefs enabled state to hide icon's value
    [useBigMenuFont bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [useOutlineIcon bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [useEmojiIcon bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [showMonth bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
    [showDayOfWeek bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];
//    [showCnLunarInIcon bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHideIcon] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSValueTransformerNameBindingOption: NSNegateBooleanTransformerName}];

    // Binding for datetime format
    [_dateTimeFormat bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kClockFormat] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES), NSMultipleValuesPlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNoSelectionPlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNotApplicablePlaceholderBindingOption: _dateTimeFormat.placeholderString, NSNullPlaceholderBindingOption: _dateTimeFormat.placeholderString}];

    // Bindings for showEventDots preference
    [showEventDots bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowEventDots] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for useColoredDots preference
    [useColoredDots bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kUseColoredDots] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [useColoredDots bind:@"enabled" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowEventDots] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for showWeeks preference
    [showWeeks bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowWeeks] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for showLocation preference
    [showLocation bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowLocation] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // Bindings for highlight picker
//    [highlight bind:@"weekStartDOW" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kWeekStartDOW] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
//    [highlight bind:@"selectedDOWs" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHighlightedDOWs] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    // Bindings for theme
    [themePopup bind:@"selectedTag" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kThemePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // Bindings for size
//    [bigger bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kSizePreference] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
    // show cn lunar
    // show cn nation days
    [showCnLunar bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kShowCnLunar] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    [showCnNationDays bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kshowCnNationDays] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
    
//    // add work color
//    [workColorWell bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHolidayWorkColor] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];
//    
//    // add relax color
//    [relaxColorWell bind:@"value" toObject:[NSUserDefaultsController sharedUserDefaultsController] withKeyPath:[@"values." stringByAppendingString:kHolidayRelaxColor] options:@{NSContinuouslyUpdatesValueBindingOption: @(YES)}];

    self.view = v;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    [self updateHideIconState];

    // We don't want _dateTimeFormat to be first responder.
    [self.view.window makeFirstResponder:nil];
}

- (void)openHelpPage:(id)sender
{
    NSPopover *_newEventPopover = [NSPopover new];
    _newEventPopover.animates = NO;
    _newEventPopover.behavior = NSPopoverBehaviorTransient;

    NSDiyMenuTipsViewController *eventVC = [NSDiyMenuTipsViewController new];

    _newEventPopover.contentViewController = eventVC;
    _newEventPopover.appearance = NSApp.effectiveAppearance;
    [_newEventPopover showRelativeToRect:NSZeroRect ofView:sender preferredEdge:NSRectEdgeMaxX];
}

- (void)updateHideIconState
{
//    NSString *dateTimeFormat = _dateTimeFormat.stringValue;
//    if (dateTimeFormat == nil || [dateTimeFormat isEqualToString:@""]) {
//        [_hideIcon setState:0];
//        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:kHideIcon];
//        // Hack alert:
//        // We call -performSelector... instead of calling _hideIcon's
//        // -setEnabled: directly. Calling directly didn't work. Perhaps
//        // this has to do with the fact that _hideIcon's value is bound
//        // to NSUserDefaults which is mutated. By calling -setEnabled on
//        // the next turn of the runloop, we are able to disbale _hideIcon.
//        [self performSelectorOnMainThread:@selector(disableHideIcon:) withObject:nil waitUntilDone:NO];
//    }
//    else {
//        [_hideIcon setEnabled:YES];
//    }
}

- (void)disableHideIcon:(id)sender
{
    [_hideIcon setEnabled:NO];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self updateHideIconState];
}

- (void)didChangeHighlight:(HighlightPicker *)picker
{
    [[NSUserDefaults standardUserDefaults] setInteger:picker.selectedDOWs forKey:kHighlightedDOWs];
}

@end
