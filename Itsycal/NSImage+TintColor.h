//
//  NSImage+TintColor.h
//  BezierMacosDemo
//
//  Created by solo on 2020/7/16.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (TintColor)
- (NSImage *)imageWith:(NSColor *)tintColor;
@end

NS_ASSUME_NONNULL_END
