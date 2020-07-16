//
//  NSImage+TintColor.m
//  BezierMacosDemo
//
//  Created by solo on 2020/7/16.
//

#import "NSImage+TintColor.h"

@implementation NSImage (TintColor)

- (NSImage *)imageWith:(NSColor *)tintColor {
    if ([self isTemplate] == false) {
        return  self;
    }
    
    NSImage *img = [self copy];
    [img lockFocus];
    
    [tintColor set];
    NSRect imgRect = NSMakeRect(0, 0, img.size.width, img.size.height);
    NSRectFillUsingOperation(imgRect, NSCompositingOperationSourceIn);
    
    [img unlockFocus];
    [img setTemplate:false];
    
    return img;
}

@end
