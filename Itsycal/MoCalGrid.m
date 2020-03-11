//
//  MoCalGrid.m
//
//
//  Created by Sanjay Madan on 12/3/14.
//  Copyright (c) 2014 mowglii.com. All rights reserved.
//

#import "MoCalGrid.h"
#import "MoCalCell.h"
#import "Sizer.h"

CGFloat dateHPadding = 8;
CGFloat dateVPadding = 8;

@implementation MoCalGrid
{
    NSUInteger _rows, _cols, _hMargin, _vMargin;
}

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)cols horizontalMargin:(NSUInteger)hMargin verticalMargin:(NSUInteger)vMargin cellType:(CalCell)cellType {
    self.cellType = cellType;
    return [self initWithRows:rows columns:cols horizontalMargin:hMargin verticalMargin:vMargin];
}

- (instancetype)initWithRows:(NSUInteger)rows columns:(NSUInteger)cols horizontalMargin:(NSUInteger)hMargin verticalMargin:(NSUInteger)vMargin
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        CGFloat sz = [self getCellSize];
        CGFloat heightDate = sz;
        // dow's width and week's height cut
        if (_cellType == CalCellDow) {
            heightDate = heightDate * 0.5;
        }else if (_cellType == CalCellWeek) {
            sz = sz * 0.5;
        }
        NSMutableArray *cells = [NSMutableArray new];
        for (NSUInteger row = 0; row < rows; row++) {
            for (NSUInteger col = 0; col < cols; col++) {
                CGFloat x = (sz + dateHPadding) * col + hMargin;
                CGFloat y = (heightDate + dateVPadding) * rows - (heightDate + dateVPadding) * (row + 1) + vMargin;
                MoCalCell *cell = [MoCalCell new];
                [cell setFrame:NSMakeRect(x, y, sz, heightDate)];
                [self addSubview:cell];
                [cells addObject:cell];
                // dow's font and week's font smaller
                if (_cellType == CalCellDow) {
                    cell.textField.font = [[Sizer shared] dowFont];
                }else if (_cellType == CalCellWeek) {
                    cell.textField.font = [[Sizer shared] weekFont];
                }
            }
        }
        _cells = [NSArray arrayWithArray:cells];
        _rows  = rows;
        _cols  = cols;
        _hMargin = hMargin;
        _vMargin = vMargin;
        
        // Hug the cells tightly
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
        [self setContentHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
        
        REGISTER_FOR_SIZE_CHANGE;
    }
    return self;
}

- (void)addRow
{
    NSMutableArray *cells = [_cells mutableCopy];

    // Shift existing cells up.
    for (MoCalCell *cell in cells) {
        NSRect frame = cell.frame;
        frame.origin.y += [self getCellSize];
        cell.frame = frame;
    }

    // Add new row of cells.
    CGFloat sz = [self getCellSize];
    CGFloat heightDate = [self getCellSize];
    for (NSUInteger col = 0; col < _cols; col++) {
        CGFloat x = (sz + dateHPadding) * col + _hMargin;
        CGFloat y = (heightDate + dateVPadding) * (_rows + 1) - (heightDate + dateVPadding) * (_rows + 1) + _vMargin;
        MoCalCell *cell = [MoCalCell new];
        [cell setFrame:NSMakeRect(x, y, sz, sz)];
        [self addSubview:cell];
        [cells addObject:cell];
    }

    _rows += 1;
    _cells = [NSArray arrayWithArray:cells];
    [self invalidateIntrinsicContentSize];
}

- (void)removeRow
{
    NSMutableArray *cells = [_cells mutableCopy];

    // Remove last row of cells.
    for (NSUInteger col = 0; col < _cols; col++) {
        MoCalCell *cell = [cells lastObject];
        [cell removeFromSuperview];
        [cells removeLastObject];
    }

    // Shift remaining cells down.
    CGFloat heightDate = [self getCellSize];
    for (MoCalCell *cell in cells) {
        NSRect frame = cell.frame;
        frame.origin.y -= heightDate;
        cell.frame = frame;
    }

    _rows -= 1;
    _cells = [NSArray arrayWithArray:cells];
    [self invalidateIntrinsicContentSize];
}

- (MoCalCell *)cellAtPoint:(NSPoint)point
{
    CGFloat sz = [self getCellSize];
    CGFloat heightDate = [self getCellSize];
    NSInteger col = floorf((point.x - _hMargin + dateHPadding) / (sz + dateHPadding));
    NSInteger row = floorf((point.y - _vMargin + dateVPadding) / (heightDate + dateVPadding));
    row = _rows - row - 1; // flip row coordinate
    if (col < 0 || row < 0 || col >= _cols || row >= _rows) {
        return nil;
    }
    return _cells[_cols * row + col];
}

- (MoCalCell *)cellWithDate:(MoDate)date;
{
    for (MoCalCell *cell in self.cells) {
        if (CompareDates(date, cell.date) == 0) {
            return cell;
        }
    }
    return nil;
}

- (NSRect)cellsRect
{
    return NSInsetRect(self.bounds, _hMargin, _vMargin);
}

- (NSSize)intrinsicContentSize
{
    CGFloat sz = [self getCellSize];
    CGFloat heightDate = sz;
    if (_cellType == CalCellDow) {
        heightDate = heightDate * 0.5;
    }else if (_cellType == CalCellWeek) {
        sz = sz * 0.5;
    }
    CGFloat width  = (sz + dateHPadding) * _cols + 2 * _hMargin - dateHPadding;
    CGFloat height = (heightDate + dateVPadding) * _rows + 2 * _vMargin - dateVPadding ;
    return NSMakeSize(width, height);
}

- (void)sizeChanged:(id)sender
{
    CGFloat sz = [self getCellSize];
    CGFloat heightDate = sz;
    if (_cellType == CalCellDow) {
        heightDate = heightDate * 0.5;
    }else if (_cellType == CalCellWeek) {
        sz = sz * 0.5;
    }
    
    for (NSUInteger row = 0; row < _rows; row++) {
        for (NSUInteger col = 0; col < _cols; col++) {
            CGFloat x = (sz + dateHPadding) * col + _hMargin;
            CGFloat y = (heightDate + dateVPadding) * _rows - (heightDate + dateVPadding) * (row + 1) + _vMargin;
            MoCalCell *cell = _cells[row*_cols + col];
            [cell setFrame:NSMakeRect(x, y, sz, heightDate)];
        }
    }
    [self invalidateIntrinsicContentSize];
}

- (CGFloat)getCellSize {
    return  [[Sizer shared] cellSize];
}


@end
