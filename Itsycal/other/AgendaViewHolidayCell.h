//
//  AgendaViewHolidayCell.h
//  Swittee Calendar
//
//  Created by solo on 2021/5/19.
//  Copyright © 2021 swittee. All rights reserved.
//

#ifndef AgendaViewHolidayCell_h
#define AgendaViewHolidayCell_h

#import <Cocoa/Cocoa.h>
@class TagField;

@interface AgendaViewHolidayCell : NSView

@property (nonatomic) TagField *title;
@property (nonatomic) TagField *info;

@end

#endif /* AgendaViewHolidayCell_h */