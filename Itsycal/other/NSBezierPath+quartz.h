//
//  NSBezierPath+quartz.h
//  BezierMacosDemo
//
//  Created by solo on 11/12/20.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBezierPath (quartz)
- (CGPathRef)quartzPath;
@end

NS_ASSUME_NONNULL_END
