//
//  Created by Sanjay Madan on 1/11/17.
//  Copyright © 2017 Swittee.com. All rights reserved.
//

#import "PrefsAboutVC.h"
#import "Itsycal.h"
#import "MoTextField.h"
#import "MoVFLHelper.h"

@implementation PrefsAboutVC
{
    NSTextField *_emoji;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView
{
    NSView *v = [NSView new];

    // Convenience function for making labels.
    MoTextField* (^label)(NSString*, BOOL) = ^MoTextField* (NSString *stringValue, BOOL isLink) {
        MoTextField *txt = [MoTextField labelWithString:stringValue];
        if (isLink) {
            txt.font = [NSFont systemFontOfSize:13 weight:NSFontWeightMedium];
            txt.linkEnabled = YES;
        }
        [v addSubview:txt];
        return txt;
    };
    
    NSImageView *imv = [NSImageView imageViewWithImage:[NSImage imageNamed:@"AppIcon"]];
    [v addSubview:imv];

    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSTextField *appName = label(@"Swittee Calendar", NO);
    appName.font = [NSFont systemFontOfSize:20 weight:NSFontWeightMedium];
    NSTextField *version = label([NSString stringWithFormat:@"%@ (%@)", infoDict[@"CFBundleShortVersionString"], infoDict[@"CFBundleVersion"]], NO);
    version.font = [NSFont systemFontOfSize:12 weight:NSFontWeightRegular];
    version.textColor = [NSColor secondaryLabelColor];
    NSTextField *mail = label(@"swittee.app@gmail.com", YES);
//    NSTextField *donateWith = label(NSLocalizedString(@"Donate with", nil), NO);
//    MoTextField *paypal = label(@"PayPal", YES);
//    NSTextField *or = label(NSLocalizedString(@"or", nil), NO);
//    MoTextField *square = label(@"Square", YES);
//    _emoji = label(@"♥️", NO);
//    NSTextField *follow = label(NSLocalizedString(@"Follow", nil), NO);
//    NSTextField *smile = label(@"(๑˃̵ᴗ˂̵)و", NO);
//    smile.font = [NSFont systemFontOfSize:16 weight:NSFontWeightLight];
//    MoTextField *Switteeapps = label(@"@Switteeapps", YES);
//    MoTextField *sparkle = label(@"Sparkle", YES);
//    MoTextField *sparkleCopyright = label(@"© 2006 Andy Matuschak", NO);
//    MoTextField *masshortcut = label(@"MASShortcut", YES);
//    MoTextField *masshortcutCopyright = label(@"© 2013 Vadim Shpakovski", NO);
//    NSTextField *copyright1 = label(@"© 2012 − 2019", NO);
//    MoTextField *copyright2 = label(@"Swittee.com", YES);
//
//    paypal.urlString = @"https://www.paypal.me/Switteeapps";
//    square.urlString = @"https://cash.me/$Swittee";
//    Switteeapps.urlString = @"https://twitter.com/intent/follow?screen_name=Switteeapps";
//    sparkle.urlString = @"https://github.com/sparkle-project/Sparkle";
//    masshortcut.urlString = @"https://github.com/shpakovski/MASShortcut";

//    MoVFLHelper *vfl = [[MoVFLHelper alloc] initWithSuperview:v metrics:@{@"m": @25} views:NSDictionaryOfVariableBindings(appName, version, donateWith, paypal, or, square, _emoji, follow, smile, Switteeapps, sparkle, sparkleCopyright, masshortcut, masshortcutCopyright, copyright1, copyright2)];
//    [vfl :@"V:|-m-[appName]-8-[version]-m-[donateWith]-10-[follow]-18-[smile]-12-[sparkle][sparkleCopyright]-10-[masshortcut][masshortcutCopyright]-m-[copyright1]-m-|"];
//    [vfl :@"H:|-m-[appName]-(>=m)-|"];
//    [vfl :@"H:|-m-[version]-(>=m)-|"];
//    [vfl :@"H:|-m-[donateWith]-4-[paypal]-4-[or]-4-[square]-6-[_emoji]-(>=m)-|" :NSLayoutFormatAlignAllBaseline];
//    [vfl :@"H:|-m-[follow]-4-[Switteeapps]-(>=m)-|" :NSLayoutFormatAlignAllBaseline];
//    [vfl :@"H:|-m-[sparkle]-(>=m)-|"];
//    [vfl :@"H:|-m-[masshortcut]-(>=m)-|"];
//    [vfl :@"H:|-m-[sparkleCopyright]-(>=m)-|"];
//    [vfl :@"H:|-m-[masshortcutCopyright]-(>=m)-|"];
//    [vfl :@"H:|-m-[copyright1]-4-[copyright2]-(>=m)-|" :NSLayoutFormatAlignAllBaseline];
//
//    [smile.centerXAnchor constraintEqualToAnchor:v.centerXAnchor].active = YES;
    
    //NSStackView *mainStack = [[NSStackView alloc] init];
    
    MoVFLHelper *vfl = [[MoVFLHelper alloc] initWithSuperview:v metrics:@{@"m": @30,@"top": @100} views:NSDictionaryOfVariableBindings(imv, appName, version, mail)];
    [vfl :@"V:|-top-[appName]-(-10)-[imv(68)]-(-60)-[version]-m-[mail]-40-|"];
    [vfl :@"H:|-(130)-[appName]-(70)-|"];
    [vfl :@"H:|-m-[imv(68)]-(>=m)-|"];
    [vfl :@"H:|-(>=m)-[version]-(>=m)-|"];
    [vfl :@"H:|-(>=m)-[mail]-(>=m)-|"];
    
    NSLayoutConstraint *leadingVersionMargin = [NSLayoutConstraint constraintWithItem:appName attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:version attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    NSLayoutConstraint *leadingMailMargin = [NSLayoutConstraint constraintWithItem:appName attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:mail attribute:NSLayoutAttributeLeading multiplier:1 constant:0];
    [v addConstraint:leadingMailMargin];
    [v addConstraint:leadingVersionMargin];

    self.view = v;
}

- (void)viewWillAppear
{
    [super viewWillAppear];
    static NSInteger index = 0;
    static NSArray *emojis = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emojis = @[@"♥️", @"😀", @"😜",
                   @"😍", @"😊", @"😝",
                   @"🤗", @"😘", @"✌️"];
    });
    _emoji.stringValue = emojis[index];
    index = (index + 1) % emojis.count;
}

@end
