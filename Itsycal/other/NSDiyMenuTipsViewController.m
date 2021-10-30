//
//  NSDiyMenuTipsViewController.m
//  Swittee Calendar
//
//  Created by solo on 2020/8/29.
//  Copyright © 2020 Swittee.com. All rights reserved.
//

#import "NSDiyMenuTipsViewController.h"
#import "Themer.h"

@interface NSDiyMenuTipsViewController ()

@end

@implementation NSDiyMenuTipsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.view.wantsLayer = true;
}

- (void)viewWillAppear {
    [super viewWillAppear];
    
    self.view.layer.backgroundColor = NSColor.windowBackgroundColor.CGColor;
}

@end
