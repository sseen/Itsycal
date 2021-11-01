//
//  MoCalendar.m
//
//
//  Created by Sanjay Madan on 11/13/14.
//  Copyright (c) 2014 Swittee.com. All rights reserved.
//

#import "MoCalendar.h"
#import "MoCalCell.h"
#import "MoCalGrid.h"
#import "MoButton.h"
#import "MoVFLHelper.h"
#import "MoCalResizeHandle.h"
#import "Themer.h"
#import "Sizer.h"
#import "MoDate.h"
#import "SCUtils.h"
#import "Itsycal.h"
#import "SNPlister.h"

NSString * const kMoCalendarNumRows = @"MoCalendarNumRows";

@implementation MoCalendar
{
    NSDateFormatter *_formatter;
    MoCalGrid *_dateGrid;
    MoCalGrid *_weekGrid;
    MoCalGrid *_dowGrid;
    MoCalToolTipWC *_tooltipWC;
    MoButton *_btnPrev, *_btnNext, *_btnToday,*_btnPrevYear,*_btnNextYear;
    NSLayoutConstraint *_weeksConstraint;
    __weak MoCalCell *_hoveredCell;
    __weak MoCalCell *_selectedCell;
    __weak MoCalCell *_monthStartCell;
    __weak MoCalCell *_monthEndCell;
    NSBezierPath *_highlightPath;
    NSColor *_highlightColor;
    MoCalResizeHandle *_resizeHandle;
    NSInteger _repeatCount;
    NSCalendar    *_nsCal;
}

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:NSZeroRect];
    if (self) {
        [self commonInitForMoCalendar];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitForMoCalendar];
    }
    return self;
}

- (void)commonInitForMoCalendar
{
    _formatter = [NSDateFormatter new];
    _tooltipWC = [MoCalToolTipWC new];
    
    // Make long labels compress and show ellipsis instead of forcing the window wider.
    // Prevent short label from pulling buttons leftward toward it.
    // [_monthLabel setContentCompressionResistancePriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    // [_monthLabel setLineBreakMode:NSLineBreakByTruncatingMiddle];
    // [_monthLabel setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    
    // Convenience function to make buttons.
    MoButton* (^btn)(NSString*, SEL) = ^MoButton* (NSString *imageName, SEL action) {
        MoButton *btn = [MoButton new];
        [btn setImage:[NSImage imageNamed:imageName]];
        [btn setAlternateImage:[NSImage imageNamed:[imageName stringByAppendingString:@"Alt"]]];
        [btn setTarget:self];
        [btn.image setTemplate:true];
        [btn setContentTintColor:NSColor.secondaryLabelColor];
        [btn setAction:action];
        [self addSubview:btn];
        return btn;
    };
    _btnPrev  = btn(@"btnPrev",  @selector(showPreviousMonth:));
    _btnToday = btn(@"btnToday", @selector(showTodayMonth:));
    _btnNext  = btn(@"btnNext",  @selector(showNextMonth:));
    _btnNextYear  = btn(@"btnNextYear",  @selector(showNextYear:));
    _btnPrevYear  = btn(@"btnPrevYear",  @selector(showPreviousYear:));
    
    // hide btntoday image
    [_btnToday setImage:[[NSImage alloc] initWithSize:_btnToday.image.size]];
    [_btnToday setFont:[[Sizer shared] dowFont]];
    
    [_btnToday setContentCompressionResistancePriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_btnToday setLineBreakMode:NSLineBreakByTruncatingMiddle];
    [_btnToday setContentHuggingPriority:1 forOrientation:NSLayoutConstraintOrientationHorizontal];

    NSInteger numRows = [[NSUserDefaults standardUserDefaults] integerForKey:kMoCalendarNumRows];
    numRows = MIN(MAX(numRows, 6), 10);
    
    _dateGrid = [[MoCalGrid alloc] initWithRows:numRows columns:7 horizontalMargin:6 verticalMargin:16 cellType:CalCellDate];
    _weekGrid = [[MoCalGrid alloc] initWithRows:numRows columns:1 horizontalMargin:3 verticalMargin:6 cellType:CalCellWeek];
    _dowGrid  = [[MoCalGrid alloc] initWithRows:1 columns:7 horizontalMargin:6 verticalMargin:0 cellType:CalCellDow];


    // The _resizeHandle is at the bottom of the calendar.
    _resizeHandle = [MoCalResizeHandle new];
    _resizeHandle.hidden = true;
    [_resizeHandle dim:YES];

    [self addSubview:_dateGrid];
    [self addSubview:_weekGrid];
    [self addSubview:_dowGrid];
    [self addSubview:_resizeHandle];

    MoVFLHelper *vfl = [[MoVFLHelper alloc] initWithSuperview:self metrics:nil views:NSDictionaryOfVariableBindings(_btnPrev, _btnToday, _btnNext, _dowGrid, _weekGrid, _dateGrid, _resizeHandle, _btnNextYear, _btnPrevYear)];
    [vfl :@"H:|-6-[_btnPrevYear]-10-[_btnPrev]-2-[_btnToday]-2-[_btnNext]-10-[_btnNextYear]-6-|" :NSLayoutFormatAlignAllBottom];
    [vfl :@"H:[_dowGrid]|"];
    [vfl :@"H:[_weekGrid]-(-2)-[_dateGrid]|"];
    [vfl :@"H:|[_resizeHandle]|"];
    [vfl :@"V:|-(-1)-[_btnPrev(15)]-7-[_dowGrid]-(-6)-[_dateGrid]-5-|"];
    [vfl :@"V:[_weekGrid]-5-|"];
    [vfl :@"V:[_resizeHandle(8)]|"];

    _weeksConstraint = [NSLayoutConstraint constraintWithItem:_weekGrid attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:2];
    [self addConstraint:_weeksConstraint];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocaleNotification:) name:NSCurrentLocaleDidChangeNotification object:nil];

    _weekStartDOW = 0;  // 0=Sunday, 1=Monday...
    _highlightedDOWs = DOWMaskNone;
    _showWeeks    = NO;
    _monthDate    = MakeDate(1583, 0, 1);   // _monthDate must be different from the
    _selectedDate = MakeDate(1583, 0, 1);   // date set in setMonthDate:selectedDate:
    _todayDate    = MakeDate(1986, 10, 12); // so calendar will draw on first display
    [self setMonthDate:_todayDate selectedDate:_todayDate];
    
    // blur
//    NSVisualEffectView *vibrant=[[NSVisualEffectView alloc] initWithFrame:self.bounds];
//    vibrant.material = NSVisualEffectMaterialLight;
//    [vibrant setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
//    [vibrant setBlendingMode:NSVisualEffectBlendingModeBehindWindow];
//    [self addSubview:vibrant positioned:NSWindowBelow relativeTo:nil];
    
    REGISTER_FOR_SIZE_CHANGE;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)isOpaque
{
    return false;
}

#pragma mark
#pragma mark Instance methods

- (void)setMonthDate:(MoDate)monthDate
{
    if (IsValidDate(monthDate)) {
        // If the provided month is today's month, select today.
        // Otherwise, select the first of the month.
        if (self.todayDate.month == monthDate.month && self.todayDate.year == monthDate.year) {
            [self setMonthDate:monthDate selectedDate:self.todayDate];
        }
        else {
            [self setMonthDate:monthDate selectedDate:monthDate];
        }
    }
}

- (void)setSelectedDate:(MoDate)selectedDate
{
    if (IsValidDate(selectedDate)) {
        [self setMonthDate:selectedDate selectedDate:selectedDate];
    }
}

- (void)setTodayDate:(MoDate)todayDate
{
    if (IsValidDate(todayDate)) {
        _todayDate = todayDate;
        for (MoCalCell *c in _dateGrid.cells) {
            if (CompareDates(c.date, todayDate) == 0) {
                c.isToday = true;
                [self updateCalendar];
                break;
            }
        }
    }
}

- (MoDate)firstDate
{
    return _dateGrid.cells.firstObject.date;
}

- (MoDate)lastDate
{
    return _dateGrid.cells.lastObject.date;
}

- (void)setWeekStartDOW:(NSInteger)weekStartDOW
{
    if (weekStartDOW < 0 || weekStartDOW > 6) {
        return;
    }
    if (_weekStartDOW != weekStartDOW) {
        _weekStartDOW = weekStartDOW;
        [self updateCalendar];
        // Now that the calendar has been redrawn with a new
        // weekStartDOW, selectedDate and selectedCell are out of
        // sync. So we need to resync them.
        // If the cell for selectedDate is still visible, then use
        // that cell as selectedCell. Otherwise, keep selectedCell
        // where it is and use its date as selectedDate.
        MoCalCell *cell = [_dateGrid cellWithDate:self.selectedDate];
        if (cell) {
            _selectedCell.isSelected = NO;
            _selectedCell = cell;
            _selectedCell.isSelected = YES;
        }
        else {
            _selectedDate = _selectedCell.date;
        }
    }
}

- (void)setShowWeeks:(BOOL)showWeeks
{
    _showWeeks = showWeeks;
    CGFloat constant = showWeeks ? NSWidth(_weekGrid.frame) : 2;
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *ctx) {
        [ctx setDuration:0.1];
        [self->_weeksConstraint.animator setConstant:constant];
    } completionHandler:NULL];
}

- (void)setShowEventDots:(BOOL)showEventDots
{
    _showEventDots = showEventDots;
    [self reloadData];
}

- (void)setUseColoredDots:(BOOL)useColoredDots
{
    _useColoredDots = useColoredDots;
    [self reloadData];
}

- (void)setHighlightedDOWs:(DOWMask)highlightedDOWs
{
    _highlightedDOWs = highlightedDOWs;
    [self updateCalendar];
}

- (void)setTooltipVC:(NSViewController<MoCalTooltipProvider> *)tooltipVC
{
    _tooltipVC = tooltipVC;
    _tooltipWC.vc = tooltipVC;

    NSView *contentView = _tooltipWC.window.contentView;
    
    // Remove all subviews of tooltip window's contentView.
    [contentView setSubviews:@[]];

    // Add the tooltopVC's view as a subview of the tooltip
    // window's contentView.
    if (tooltipVC != nil) {
        tooltipVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        [contentView addSubview:tooltipVC.view];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-3-[v]-3-|" options:0 metrics:nil views:@{@"v":_tooltipVC.view}]];
        [contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-2-[v]-2-|" options:0 metrics:nil views:@{@"v":_tooltipVC.view}]];
    }
}

- (IBAction)showPreviousMonth:(id)sender
{
    self.monthDate = AddMonthsToMonth(-1, self.monthDate);
}

- (IBAction)showNextMonth:(id)sender
{
    self.monthDate = AddMonthsToMonth(1, self.monthDate);
}

- (IBAction)showPreviousYear:(id)sender
{
    self.monthDate = AddMonthsToMonth(-12, self.monthDate);
}

- (IBAction)showNextYear:(id)sender
{
    self.monthDate = AddMonthsToMonth(12, self.monthDate);
}

- (IBAction)showTodayMonth:(id)sender
{
    [self setMonthDate:self.todayDate selectedDate:self.todayDate];
    // If the day has changed, we must update the calendar.
    if (CompareDates(self.todayDate, _selectedCell.date) != 0) {
        [self updateCalendar];
    }
}

- (void)changeDateAndLunarColor:(NSMutableAttributedString *)colorTitle dateString:(NSString *)dateString lunarWithNewLine:(NSString *)lunarWithNewLine color:(NSColor *)color {
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, dateString.length)];
    [colorTitle addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(dateString.length, lunarWithNewLine.length - dateString.length)];
}

- (void)updateCalendar
{
    // Month/year and DOW labels
    NSArray *months = [_formatter shortMonthSymbols];
    NSArray *dows = [_formatter shortWeekdaySymbols];
    NSString *month = [NSString stringWithFormat:@"%@ %zd", months[self.monthDate.month], self.monthDate.year];
    [_btnToday setTitle:month];
    // Make French dow strings lowercase because that is the convention
    // in France. -veryShortWeekdaySymbols should have done this for us.
    if ([[NSLocale currentLocale].localeIdentifier hasPrefix:@"fr"]) {
        dows = @[@"d", @"l", @"m", @"m", @"j", @"v", @"s"];
    }
    // macOS gives the English veryShortWeekdaySymbols for Esperanto.
    else if ([[NSLocale currentLocale].localeIdentifier hasPrefix:@"eo"]) {
        dows = @[@"D", @"L", @"M", @"M", @"Ĵ", @"V", @"S"];
    }
    for (NSInteger col = 0; col < 7; col++) {
        int dowInt = COL_DOW(self.weekStartDOW, col);
        NSString *dow = [NSString stringWithFormat:@"%@", dows[dowInt]];
        [[_dowGrid.cells[col] textField] setStringValue:dow];
        NSColor *dowColor = Theme.DOWTextColor;
        // dow weekend font color
        if (dowInt == 0 || dowInt == 6) {
            dowColor = Theme.DOWWeekEndTextColor;
        }
        [[_dowGrid.cells[col] textField] setTextColor:dowColor];
        // [[_dowGrid.cells[col] textField] setTextColor:[self columnIsMemberOfHighlightedDOWs:col]
        // ? Theme.highlightedDOWTextColor
        // : Theme.DOWTextColor];
    }
    
    // Get the first of the month.
    MoDate firstOfMonth = MakeDate(self.monthDate.year, self.monthDate.month, 1);
    
    // Get the DOW for the first of the month.
    // en.wikipedia.org/wiki/Julian_day#Finding_day_of_week_given_Julian_day_number
    NSInteger monthStartDOW = (firstOfMonth.julian + 1)%7;
    
    // On which column [0..6] in the monthly calendar does this date fall?
    NSInteger monthStartColumn = DOW_COL(self.weekStartDOW, monthStartDOW);
    
    // Get the date for the first column of the monthly calendar.
    MoDate date = AddDaysToDate(-monthStartColumn, firstOfMonth);
    
    // Fill in the calendar grid sequentially.
    for (NSInteger row = 0; row < _dateGrid.rows; row++) {
        for (NSInteger col = 0; col < 7; col++) {
            MoCalCell *cell = _dateGrid.cells[row * 7 + col];
            // cell hilight line hide
            cell.lineLayer.hidden = true;
            cell.isToday = CompareDates(date, self.todayDate) == 0;
            // chinese lunar text
            NSDate *lunarDate = MakeNSDateWithDate(date, [NSCalendar autoupdatingCurrentCalendar]);
            SCUtils *scUtils = [[SCUtils alloc] init];
            NSDateComponents *dateCom = [SCUtils getCNLunarComponentsWithDay:lunarDate];
            NSString *lunarContent = [NSString stringWithFormat:@"%@", [scUtils getLunarDay:lunarDate]];
            NSInteger lunarDay = dateCom.day;
            if (lunarDay == 1) {
                lunarContent = [scUtils getLunarMonth:lunarDate];
            }
            
            NSString *dateString = [NSString stringWithFormat:@"%ld",date.day];
            NSString *lunarWithNewLine = [NSString stringWithFormat:@"%@", dateString];
            
            cell.date = date;
            cell.isHighlighted = [self columnIsMemberOfHighlightedDOWs:col];
            cell.isInCurrentMonth = (date.month == self.monthDate.month);
            cell.cstatus = KCNATIONSTATUSnormal;
            
            NSString *todayDateStr = NSStringFromMoDateWithoutJulian(date);
            Boolean isShowCnLunar = [[NSUserDefaults standardUserDefaults] boolForKey:kShowCnLunar];
            Boolean isShowCnNaitonDays = [[NSUserDefaults standardUserDefaults] boolForKey:kshowCnNationDays];
            if (isShowCnLunar) {
                lunarWithNewLine = [NSString stringWithFormat:@"%@\n%@", dateString, lunarContent];
            }
            if (isShowCnNaitonDays) {
                cell.cstatus = [SCUtils whichNationDays:todayDateStr];
            }
            
            // attributed string lunar and date
            // date number big font, lunar string small font
            NSMutableAttributedString *colorTitle = [[NSMutableAttributedString alloc] initWithString: lunarWithNewLine];
            // weekend color
            // 根据星期开始于星期几来标记周末的颜色
            // 目前看来完全没有必要了，找了已经有的方法了 COL_DOW(self.weekStartDOW, col)
            
            /*
            // 0 1 56 7 - 2
            // 1 2 45 7 - 3
            // 2 3 34 7 - 4
            // 3 4 23 7 - 5
            // 4 5 12 7 - 6
            // 5 6 01 7 - 7
            // 6 7 60 7 - 1
            // int oneWeekend = 0;
            // int anotherWeekend = 6;
            // if (self.weekStartDOW != 0) {
            //     oneWeekend =  7 - (int)self.weekStartDOW - 1;
            //     anotherWeekend = oneWeekend + 1;
            // }
            */
            
            int dowInt = COL_DOW(self.weekStartDOW, col);
            //NSLog(@"%ld, %ld, %ld, %d, %d",(long)self.weekStartDOW,COL_DOW(self.weekStartDOW, col), (long)col, oneWeekend, anotherWeekend);
            if ((dowInt == 0 || dowInt == 6) && cell.isInCurrentMonth) {
                [self changeDateAndLunarColor:colorTitle dateString:dateString lunarWithNewLine:lunarWithNewLine color:Theme.currentMonthWeekEndText];
            }
            
            // 农历初一显示为月份
            if (lunarDay == 1 ) {
                cell.lineLayer.hidden = false;
            }
            // today date text color
            if (cell.isToday) {
                [self changeDateAndLunarColor:colorTitle dateString:dateString lunarWithNewLine:lunarWithNewLine color:[NSColor whiteColor]];
            }
            // date and lunar font size
            [colorTitle addAttribute:NSFontAttributeName value:[[Sizer shared] dateFont] range:NSMakeRange(0, dateString.length)];
            [colorTitle addAttribute:NSFontAttributeName value:[[Sizer shared] dateLunarFont] range:NSMakeRange(dateString.length, lunarWithNewLine.length - dateString.length)];
            [colorTitle setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, lunarWithNewLine.length)];
            cell.textField.attributedStringValue = colorTitle;
            if (date.month == self.monthDate.month) {
                if (date.day == 1) {
                    _monthStartCell = cell;
                }
                else if (date.day == DaysInMonth(date.year, date.month)) {
                    _monthEndCell = cell;
                }
            }
            // ISO 8601 weeks are defined to start on Monday (and
            // really only make sense if self.weekStartDOW is Monday).
            // If the current column is Monday, use this date to
            // calculate the week number for this row.
            if (col == DOW_COL(self.weekStartDOW, 1)) {
                // use month text color
                [_weekGrid.cells[row] textField].textColor = Theme.currentMonthWeekEndText;
                [_weekGrid.cells[row] textField].integerValue = WeekOfYear(date.year, date.month, date.day);
            }
            date = AddDaysToDate(1, date);
        }
    }
    [self setNeedsDisplay:YES];
    
    [self.delegate calendarUpdated:self];
}

- (void)reloadData
{
    for (MoCalCell *c in _dateGrid.cells) {
        c.dotColors = self.showEventDots
            ? [self.delegate dotColorsForDate:c.date useColor:self.useColoredDots]
            : nil;
    }
    [_tooltipWC endTooltip];
}

- (void)highlightCellsFromDate:(MoDate)startDate toDate:(MoDate)endDate withColor:(NSColor *)color
{
    MoCalCell *startCell=nil, *endCell=nil;
    for (MoCalCell *cell in _dateGrid.cells) {
        if (!startCell && CompareDates(startDate, cell.date) <= 0) {
            startCell = cell;
        }
        if (CompareDates(endDate, cell.date) >= 0) {
            endCell = cell;
        }
    }
    if (startCell && endCell) {
        CGFloat radius = [[Sizer shared] cellRadius];
        _highlightPath = [self bezierPathWithStartCell:startCell endCell:endCell radius:radius inset:3 useRects:YES];
        _highlightColor = color;
        // Normalize location of _highlightPath. We will tranlsate it
        // again in drawRect to the correct location.
        NSAffineTransform *t = [NSAffineTransform new];
        [t translateXBy:-NSMinX(_dateGrid.frame) yBy:0];
        [_highlightPath transformUsingAffineTransform:t];
        [self setNeedsDisplay:YES];
    }
}

- (void)unhighlightCells
{
    _highlightPath = nil;
    _highlightColor = nil;
    [self setNeedsDisplay:YES];
}

- (void)sizeChanged:(id)sender
{
    // Perform calendar size changes after grid cells have resized.
    [self performSelector:@selector(delayedSizeChanges:) withObject:nil afterDelay:0.05];
}

- (void)delayedSizeChanges:(id)sender {
    // Font sizes.
    for (MoCalCell *cell in _dowGrid.cells) {
        cell.textField.font = [NSFont systemFontOfSize:[[Sizer shared] fontSize] weight:NSFontWeightSemibold];
    }
    if (self.showWeeks) {
        _weeksConstraint.constant = NSWidth(_weekGrid.frame);
    }
}

#pragma mark -
#pragma mark Process input

- (void)keyDown:(NSEvent *)theEvent
{
    NSString *charsIgnoringModifiers = [theEvent charactersIgnoringModifiers];
    if (charsIgnoringModifiers.length != 1) return;
    
    NSUInteger flags = [theEvent modifierFlags];
    BOOL noFlags =  !(flags & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagControl | NSEventModifierFlagShift));
    BOOL shiftFlag = (flags &  NSEventModifierFlagShift) && !(flags & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagControl));
    BOOL ctrlFlag = (flags &  NSEventModifierFlagControl) && !(flags & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagShift));

    unichar keyChar = [charsIgnoringModifiers characterAtIndex:0];
    
    if (keyChar == ' ') {
        [_btnToday performClick:self];
    }
    else if ((keyChar == 'H' && shiftFlag) || (keyChar == NSLeftArrowFunctionKey && noFlags)) {
        NSInteger n = [self repeatCountify:-1];
        if (n < -1) {
            self.monthDate = AddMonthsToMonth(n, self.monthDate);
        } else {
            [_btnPrev performClick:self];
        }
    }
    else if ((keyChar == 'L' && shiftFlag) || (keyChar == NSRightArrowFunctionKey && noFlags)) {
        NSInteger n = [self repeatCountify:1];
        if (n > 1) {
            self.monthDate = AddMonthsToMonth(n, self.monthDate);
        } else {
            [_btnNext performClick:self];
        }
    }
    else if ((keyChar == 'J' && shiftFlag) || (keyChar == NSDownArrowFunctionKey && noFlags)) {
        NSInteger n = [self repeatCountify:12];
        self.monthDate = AddMonthsToMonth(n, self.monthDate);
    }
    else if ((keyChar == 'K' && shiftFlag) || (keyChar == NSUpArrowFunctionKey && noFlags)) {
        NSInteger n = [self repeatCountify:-12];
        self.monthDate = AddMonthsToMonth(n, self.monthDate);
    }
    else if ((keyChar == 'h' && noFlags) || (keyChar == NSLeftArrowFunctionKey && shiftFlag)) {
        NSInteger n = [self repeatCountify:-1];
        [self moveSelectionByDays:n];
    }
    else if ((keyChar == 'l' && noFlags) || (keyChar == NSRightArrowFunctionKey && shiftFlag)) {
        NSInteger n = [self repeatCountify:1];
        [self moveSelectionByDays:n];
    }
    else if ((keyChar == 'j' && noFlags) || (keyChar == NSDownArrowFunctionKey && shiftFlag)) {
        NSInteger n = [self repeatCountify:7];
        [self moveSelectionByDays:n];
    }
    else if ((keyChar == 'k' && noFlags) || (keyChar == NSUpArrowFunctionKey && shiftFlag)) {
        NSInteger n = [self repeatCountify:-7];
        [self moveSelectionByDays:n];
    }
    else if (keyChar == 'j' && ctrlFlag) {
        [self addRow];
    }
    else if (keyChar == 'k' && ctrlFlag) {
        [self removeRow];
    }
    else if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:keyChar] && noFlags) {
        [self repeatCountUpdate:keyChar];
    }
    else if ([theEvent.characters hasPrefix:@"#"]) {
        [self showDateInfo];
    }
    else {
        [super keyDown:theEvent];
    }
    [_tooltipWC endTooltip];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    CGFloat sz = [[Sizer shared] cellSize];
    NSPoint initialDragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL isDragging = NSPointInRect(initialDragPoint, _resizeHandle.frame);

    while (isDragging) {
        theEvent = [[self window] nextEventMatchingMask: NSEventMaskLeftMouseUp | NSEventMaskLeftMouseDragged];
        if ([theEvent type] == NSEventTypeLeftMouseUp) {
            isDragging = NO;
        }
        else if ([theEvent type] == NSEventTypeLeftMouseDragged) {
            NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            if (location.y >= initialDragPoint.y + sz && _dateGrid.rows > 6) {
                [self removeRow];
            }
            else if (location.y <= initialDragPoint.y - sz && _dateGrid.rows < 10) {
                [self addRow];
            }
        }
    }

    // Dim resizeHandle if drag ends outside of it (-mouseExited: won't catch this).
    NSPoint finalDragPoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    BOOL isInResizeHandle = NSPointInRect(finalDragPoint, _resizeHandle.frame);
    [_resizeHandle dim:!isInResizeHandle];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if ([theEvent clickCount] == 1) {
        NSPoint locationInWindow = [theEvent locationInWindow];
        NSPoint locationInDates  = [_dateGrid convertPoint:locationInWindow fromView:nil];
        MoCalCell *clickedCell   = [_dateGrid cellAtPoint:locationInDates];
        if (clickedCell && clickedCell != _selectedCell) {
            [self setMonthDate:self.monthDate selectedDate:clickedCell.date];
        }
        [_tooltipWC hideTooltip];
    }
    else if ([theEvent clickCount] == 2) {
        if (self.target && self.doubleAction) {
            [NSApp sendAction:self.doubleAction to:self.target from:self];
        }
        [_tooltipWC endTooltip];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (!self.window.isVisible) {
        // On macOS 10.14, -mouseMoved: can be called even when the
        // calendar (and its window) are *not visible* under certain
        // circumstances. This leads to tooltips mysteriously popping
        // up out of nowhere when the user's mouse is where Itsycal's
        // window *would be* if it were actually showing. By updating
        // the tracking areas, -mouseMoved: is no longer erroneously
        // called.
        [self updateTrackingAreas];
        return;
    }
    NSPoint locationInWindow = [theEvent locationInWindow];
    NSPoint locationInDates  = [_dateGrid convertPoint:locationInWindow fromView:nil];
    MoCalCell *hoveredCell   = [_dateGrid cellAtPoint:locationInDates];
    if (hoveredCell && hoveredCell != _hoveredCell) {
        _hoveredCell.isHovered = NO;
        _hoveredCell = hoveredCell;
        _hoveredCell.isHovered = YES;
        
        if (_tooltipWC.vc != nil) {
            NSRect rect = [self convertRect:_hoveredCell.frame fromView:_dateGrid];
            rect = NSOffsetRect(rect, self.frame.origin.x, self.frame.origin.y);
            rect = [self.window convertRectToScreen:rect];
            [_tooltipWC showTooltipForDate:_hoveredCell.date relativeToRect:rect screenFrame:[[NSScreen mainScreen] frame]];
        }
        else {
            [_tooltipWC hideTooltip];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    if ([[(NSDictionary *)[theEvent userData] valueForKey:@"area"] isEqualToString: @"resizeHandle"]) {
        [_resizeHandle dim:NO];
    }
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if ([[(NSDictionary *)[theEvent userData] valueForKey:@"area"] isEqualToString: @"resizeHandle"]) {
        [_resizeHandle dim:YES];
    }
    else { // userData[area] == "dateGrid"
        _hoveredCell.isHovered = NO;
        _hoveredCell = nil;
        [_tooltipWC hideTooltip];
        [self setNeedsDisplay:YES];
    }
}

- (void)updateTrackingAreas
{
    for (NSTrackingArea *area in self.trackingAreas) {
        [self removeTrackingArea:area];
    }
    // cellsRect encompasses the cells in _dateGrid (not including their margins)
    NSRect cellsRect = [self convertRect:[_dateGrid cellsRect] fromView:_dateGrid];
    NSTrackingArea *cellsTrackingArea = [[NSTrackingArea alloc] initWithRect:cellsRect options:(NSTrackingMouseMoved | NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:@{@"area": @"dateGrid"}];

    NSTrackingArea *resizeHandleTrackingArea = [[NSTrackingArea alloc] initWithRect:_resizeHandle.frame options:(NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways) owner:self userInfo:@{@"area": @"resizeHandle"}];

    [self addTrackingArea:cellsTrackingArea];
    [self addTrackingArea:resizeHandleTrackingArea];
    [super updateTrackingAreas];
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    // Left/right swipes change to previous/next months.
    if (theEvent.phase == NSEventPhaseBegan) {
        CGFloat dX = theEvent.scrollingDeltaX;
        if (dX != 0) {
            [theEvent trackSwipeEventWithOptions:(NSEventSwipeTrackingLockDirection) dampenAmountThresholdMin:-1 max:1 usingHandler:^(CGFloat amount, NSEventPhase phase, BOOL isDone, BOOL *stop) {
                if (phase == NSEventPhaseEnded) {
                    if (dX < 0) {
                        [self showNextMonth:nil];
                    }
                    else {
                        [self showPreviousMonth:nil];
                    }
                }
            }];
        }
    }
    [super scrollWheel:theEvent];
}

#pragma mark
#pragma mark Repeat count

- (void)repeatCountUpdate:(unichar)keyChar
{
    // Is there a better way to convert unichar to NSInteger?
    NSInteger n = (NSInteger)keyChar - 48;
    if (_repeatCount < 100) { // max _repeatCount allowed is 999
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatCountClear) object:nil];
        _repeatCount = _repeatCount*10 + n;
        [self performSelector:@selector(repeatCountClear) withObject:nil afterDelay:3];
    }
}

- (void)repeatCountClear
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(repeatCountClear) object:nil];
    _repeatCount = 0;
}

- (NSInteger)repeatCountify:(NSInteger)n
{
    NSInteger result = (_repeatCount > 0) ? n * _repeatCount : n;
    [self repeatCountClear];
    return result;
}

#pragma mark
#pragma mark Day info

- (void)showDateInfo
{
    static NSNumberFormatter *groupingFormatter = nil;
    if (!groupingFormatter) {
        groupingFormatter = [NSNumberFormatter new];
        groupingFormatter.numberStyle = NSNumberFormatterDecimalStyle;
        groupingFormatter.groupingSeparator = [NSLocale.currentLocale objectForKey:NSLocaleGroupingSeparator];
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearDateInfo) object:nil];
    // Get selectedDate's offset from today.
    NSInteger dayDiff = CompareDates(self.selectedDate, self.todayDate);
    NSString *dayInfo = [groupingFormatter stringFromNumber:@(labs(dayDiff))];
    dayInfo = (dayDiff >= 0)?
        [@"+" stringByAppendingString:dayInfo]:
        [@"−" stringByAppendingString:dayInfo];
    // Get day of the year.
    MoDate firstOfYear = MakeDate(self.selectedDate.year, 0, 1);
    NSInteger dayOfYear = CompareDates(self.selectedDate, firstOfYear) + 1;
    dayInfo = [NSString stringWithFormat:@"%@ ∕ %zd", dayInfo, dayOfYear];
    [_btnToday setTitle:dayInfo];
    [self performSelector:@selector(clearDateInfo) withObject:nil afterDelay:2];
}

- (void)clearDateInfo
{
    // This should match month code in -updateCalendar
    NSArray *months = [_formatter shortMonthSymbols];
    NSString *month = [NSString stringWithFormat:@"%@ %zd", months[self.monthDate.month], self.monthDate.year];
    [_btnToday setTitle:month];
}

#pragma mark
#pragma mark Utilities

- (void)setMonthDate:(MoDate)monthDate selectedDate:(MoDate)selectedDate
{
    // This method is where the instance variables backing the
    // monthDate and selectedDate properties are set.
    
    BOOL didChangeMonth = NO;
    
    monthDate = MakeDate(monthDate.year, monthDate.month, 1);
    
    // 中国假期多年份判断更新
    if (monthDate.year != self.monthDate.year) {
        [SNPlist reset:monthDate.year];
    }
    
    if (CompareDates(monthDate, self.monthDate) != 0) {
        _monthDate = monthDate;
        [self updateCalendar];
        didChangeMonth = YES;
    }
    if (didChangeMonth == YES || CompareDates(selectedDate, self.selectedDate) != 0) {
        _selectedDate = selectedDate;
        _selectedCell.isSelected = NO;
        _selectedCell = [_dateGrid cellWithDate:selectedDate];
        _selectedCell.isSelected = YES;
        [self setNeedsDisplay:YES];
        [self.delegate calendarSelectionChanged:self];
    }
}

- (void)moveSelectionByDays:(NSInteger)days
{
    MoDate newSelectedDate = AddDaysToDate(days, self.selectedDate);
    MoDate firstCellDate = [_dateGrid.cells.firstObject date];
    MoDate lastCellDate  = [_dateGrid.cells.lastObject date];
    if (CompareDates(newSelectedDate, firstCellDate) < 0 ||
        CompareDates(newSelectedDate, lastCellDate ) > 0) {
        [self setMonthDate:newSelectedDate selectedDate:newSelectedDate];
    }
    else {
        [self setMonthDate:self.monthDate selectedDate:newSelectedDate];
    }
}

- (void)handleLocaleNotification:(NSNotification *)notification
{
    // Redraw calendar with locale-specific month and DOW headers
    [self updateCalendar];
}

// Helper function to determine if a given column in the
// calendar grid is a member of self.highlightedDOWs.
- (BOOL)columnIsMemberOfHighlightedDOWs:(NSInteger)col
{
    DOWMask dowmask_for_this_col = 1 << COL_DOW(self.weekStartDOW, col);
    return dowmask_for_this_col & self.highlightedDOWs;
}

- (void)addRow
{
    if (_dateGrid.rows < 10) {
        [_dateGrid addRow];
        [_weekGrid addRow];
        [self updateCalendar];
        [[NSUserDefaults standardUserDefaults] setInteger:_dateGrid.rows forKey:kMoCalendarNumRows];
    }
}

- (void)removeRow
{
    if (_dateGrid.rows > 6) {
        // Move selection up one row (-7 days) if it is
        // in the row that is about to be removed.
        NSUInteger selectedCellIndex = [_dateGrid.cells indexOfObject:_selectedCell];
        if (selectedCellIndex >= _dateGrid.cells.count - 7) {
            [self moveSelectionByDays:-7];
        }
        [_dateGrid removeRow];
        [_weekGrid removeRow];
        [self updateCalendar];
        [[NSUserDefaults standardUserDefaults] setInteger:_dateGrid.rows forKey:kMoCalendarNumRows];
    }
}

#pragma mark
#pragma mark Drawing

- (void)drawRect:(NSRect)dirtyRect
{
//    [Theme.mainBackgroundColor set];
//    NSRectFill(self.bounds);
    
    CGFloat radius = [[Sizer shared] cellRadius] + 3;
    CGFloat sz = [[Sizer shared] cellSize];
    if (self.highlightedDOWs) {
        NSRect weekendRect = [self convertRect:[_dateGrid cellsRect] fromView:_dateGrid];
        weekendRect.size.width = sz;
        [Theme.highlightedDOWBackgroundColor set];
        NSInteger numColsToHighlight = 0;
        for (NSInteger col = 0; col <= 7; col++) {
            if (col < 7 && [self columnIsMemberOfHighlightedDOWs:col]) {
                numColsToHighlight++;
            }
            else {
                if (numColsToHighlight) {
                    NSInteger startCol = col - numColsToHighlight;
                    NSRect rect = NSOffsetRect(weekendRect, startCol * sz, 0);
                    rect.size.width *= numColsToHighlight;
                    [[NSBezierPath bezierPathWithRoundedRect:rect xRadius:radius yRadius:radius] fill];
                }
                numColsToHighlight = 0;
            }
        }
    }

    if (_highlightPath) {
        // Tranlsate the highlight path. It's location will depend
        // on whether we are showing weeks or not because they add
        // an additional column.
        NSAffineTransform *t = [NSAffineTransform new];
        [t translateXBy:NSMinX(_dateGrid.frame) yBy:0];
        NSBezierPath *highlightPath = [_highlightPath copy];
        [highlightPath transformUsingAffineTransform:t];
        [[_highlightColor colorWithAlphaComponent:0.36] setFill];
        [highlightPath fill];
    }

//    NSBezierPath *outlinePath = [self bezierPathWithStartCell:_monthStartCell endCell:_monthEndCell radius:radius inset:0 useRects:NO];
//    
//    [Theme.currentMonthOutlineColor set];
//    [outlinePath setLineWidth:2];
//    [outlinePath stroke];
}

- (NSBezierPath *)bezierPathWithStartCell:(MoCalCell *)startCell endCell:(MoCalCell *)endCell radius:(CGFloat)r inset:(CGFloat)inset useRects:(BOOL)useRects
{
    // Create a bezier path around the range of cells specified by
    // startCell and endCell. The path has rounded corners specified
    // by radius r. If useRects == YES, the path is composed only of
    // horizontal rounded rects. Otherwise, the path is a region.
    
    // First get the frame rects of the start and end cells in self view coordinates.
    
    NSRect startRect = [self convertRect:startCell.frame fromView:_dateGrid];
    NSRect endRect   = [self convertRect:endCell.frame fromView:_dateGrid];
    startRect = NSInsetRect(startRect, inset, inset);
    endRect   = NSInsetRect(endRect, inset, inset);
    
    // Get the left and right edges of the path in self view coordinates.

    NSRect dateCellsRect = [self convertRect:[_dateGrid cellsRect] fromView:_dateGrid];
    CGFloat leftEdge  = NSMinX(NSInsetRect(dateCellsRect, inset, inset));
    CGFloat rightEdge = NSMaxX(NSInsetRect(dateCellsRect, inset, inset));
    
    // Now that we have the rects, create the path...
    
    CGFloat x = startRect.origin.x;
    CGFloat y = startRect.origin.y;
    
    NSBezierPath *p;
    
    // Case 1: startRect and endRect are on the same row.
    
    if (NSMinY(startRect) == NSMinY(endRect)) {
        p = [NSBezierPath bezierPathWithRoundedRect:NSUnionRect(startRect, endRect) xRadius:r yRadius:r];
    }
    
    // Case 2: startRect and endRect are on adjacent rows with no
    // vertical overlap -OR- we must use rects to build the path.
    
    else if (((NSMinY(startRect) - inset == NSMinY(endRect) + NSHeight(endRect) + inset) &&
              (NSMinX(startRect) > NSMinX(endRect))) ||
             useRects) {
        NSRect rect = NSMakeRect(x, y, rightEdge - x, NSHeight(startRect));
        p = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:r yRadius:r];
        CGFloat yStep = 2 * inset + NSHeight(startRect);
        for (y = y - yStep; y != NSMinY(endRect); y -= yStep) {
            rect = NSMakeRect(leftEdge, y, rightEdge - leftEdge, NSHeight(startRect));
            [p appendBezierPathWithRoundedRect:rect xRadius:r yRadius:r];
        }
        x = endRect.origin.x;
        y = endRect.origin.y;
        rect = NSMakeRect(leftEdge, y, x - leftEdge + NSWidth(endRect), NSHeight(endRect));
        [p appendBezierPathWithRoundedRect:rect xRadius:r yRadius:r];
    }
    
    // Case 3: startRect and endRect have at least one row
    // between them and/or overlap vertically.
    
    else {
        p = [NSBezierPath bezierPath];
        [p moveToPoint:NSMakePoint(x, y + r)];
        y = NSMaxY(startRect);
        [p lineToPoint:NSMakePoint(x, y - r)];
        [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x + r, y) radius:r];
        x = rightEdge;
        [p lineToPoint:NSMakePoint(x - r, y)];
        [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x, y - r) radius:r];
        if (NSMaxX(endRect) != rightEdge) {
            y = NSMaxY(endRect) + 2 * inset;
            [p lineToPoint:NSMakePoint(x, y + r)];
            [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x - r, y) radius:r];
            x = NSMaxX(endRect);
            [p lineToPoint:NSMakePoint(x + r, y)];
            [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x, y - r) radius:r];
        }
        y = NSMinY(endRect);
        [p lineToPoint:NSMakePoint(x, y + r)];
        [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x - r, y) radius:r];
        x = leftEdge;
        [p lineToPoint:NSMakePoint(x + r, y)];
        [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x, y + r) radius:r];
        if (NSMinX(startRect) != leftEdge) {
            y = NSMinY(startRect) - 2 * inset;
            [p lineToPoint:NSMakePoint(x, y - r)];
            [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x + r, y) radius:r];
            x = NSMinX(startRect);
            [p lineToPoint:NSMakePoint(x - r, y)];
            [p appendBezierPathWithArcFromPoint:NSMakePoint(x, y) toPoint:NSMakePoint(x, y + r) radius:r];
        }
        [p closePath];
    }
    return p;
}

@end
