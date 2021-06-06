//
//  SCUtils.m
//  Swittee Calendar
//
//  Created by solo on 1/16/21.
//  Copyright © 2021 mowglii.com. All rights reserved.
//

#import "SCUtils.h"
#import "SNPlister.h"
#import "Itsycal.h"

static NSString *_holidayStr = nil;

static NSArray<NSString *> *_lunarChars;
static NSArray<NSString *> *_lunarMonthChars;
static NSArray<NSString *> *_lunarYearChars;

@implementation SCUtils
+ (void)initialize {
    _lunarYearChars = @[@"甲子", @"乙丑", @"丙寅", @"丁卯",  @"戊辰",  @"己巳",  @"庚午",  @"辛未",  @"壬申",  @"癸酉", @"甲戌",   @"乙亥",  @"丙子",  @"丁丑", @"戊寅",   @"己卯",  @"庚辰",  @"辛己",  @"壬午",  @"癸未", @"甲申",   @"乙酉",  @"丙戌",  @"丁亥",  @"戊子",  @"己丑",  @"庚寅",  @"辛卯",  @"壬辰",  @"癸巳", @"甲午",   @"乙未",  @"丙申",  @"丁酉",  @"戊戌",  @"己亥",  @"庚子",  @"辛丑",  @"壬寅",  @"癸丑", @"甲辰",   @"乙巳",  @"丙午",  @"丁未",  @"戊申",  @"己酉",  @"庚戌",  @"辛亥",  @"壬子",  @"癸丑", @"甲寅",   @"乙卯",  @"丙辰",  @"丁巳",  @"戊午",  @"己未",  @"庚申",  @"辛酉",  @"壬戌",  @"癸亥"];
    _lunarMonthChars = @[@"正月", @"二月", @"三月", @"四月", @"五月", @"六月", @"七月", @"八月", @"九月", @"十月", @"冬月", @"腊月"];
    _lunarChars = @[@"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十", @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十", @"二一", @"二二", @"二三", @"二四", @"二五", @"二六", @"二七", @"二八", @"二九", @"三十"];
}


/// 获取农历信息
/// @param solarDate 哪一天
- (NSString *)LunarForSolar:(NSDate *)solarDate{

    //天干名称
    NSArray *cTianGan= [NSArray arrayWithObjects:@"甲",@"乙",@"丙",@"丁",@"戊",@"己",@"庚",@"辛",@"壬",@"癸", nil];

    //地支名称
    NSArray *cDiZhi = [NSArray arrayWithObjects:@"子",@"丑",@"寅",@"卯",@"辰",@"巳",@"午",@"未",@"申",@"酉",@"戌",@"亥",nil];

    //属相名称
    NSArray *cShuXiang = [NSArray arrayWithObjects:@"鼠",@"牛",@"虎",@"兔",@"龙",@"蛇",@"马",@"羊",@"猴",@"鸡",@"狗",@"猪",nil];

    //农历日期名
    NSArray *cDayName = [NSArray arrayWithObjects:@"*",@"初一",@"初二",@"初三",@"初四",@"初五",@"初六",@"初七",@"初八",@"初九",@"初十",@"十一",@"十二",@"十三",@"十四",@"十五",@"十六",@"十七",@"十八",@"十九",@"二十",@"廿一",@"廿二",@"廿三",@"廿四",@"廿五",@"廿六",@"廿七",@"廿八",@"廿九",@"三十",nil];

    //农历月份名
    NSArray *cMonName = [NSArray arrayWithObjects:@"*",@"正",@"二",@"三",@"四",@"五",@"六",@"七",@"八",@"九",@"十",@"十一",@"腊",nil];

    //公历每月前面的天数
    const int wMonthAdd[12] = {0,31,59,90,120,151,181,212,243,273,304,334};

    //农历数据
    const int wNongliData[100] = {2635,333387,1701,1748,267701,694,2391,133423,1175,396438,3402,3749,331177,1453,694,201326,2350,465197,3221,3402,400202,2901,1386,267611,605,2349,137515,2709,464533,1738,2901,330421,1242,2651,199255,1323,529706,3733,1706,398762,2741,1206,267438,2647,1318,204070,3477,461653,1386,2413,330077,1197,2637,268877,3365,531109,2900,2922,398042,2395,1179,267415,2635,661067,1701,1748,398772,2742,2391,330031,1175,1611,200010,3749,527717,1452,2742,332397,2350,3222,268949,3402,3493,133973,1386,464219,605,2349,334123,2709,2890,267946,2773,592565,1210,2651,395863,1323,2707,265877};

    static int wCurYear,wCurMonth,wCurDay;
    static int nTheDate,nIsEnd,m,k,n,i,nBit;

    //取当前公历年、月、日

    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:solarDate];
    wCurYear = (int)[components year];
    wCurMonth = (int)[components month];
    wCurDay = (int)[components day];

    //计算到初始时间1921年2月8日的天数：1921-2-8(正月初一)
    nTheDate = (wCurYear - 1921) * 365 + (wCurYear - 1921) / 4 + wCurDay + wMonthAdd[wCurMonth - 1] - 38;
    if((!(wCurYear % 4)) && (wCurMonth > 2)) {
        nTheDate = nTheDate + 1;
    }
    //计算农历天干、地支、月、日
    nIsEnd = 0;
    m = 0;
    while(nIsEnd != 1) {
        if(wNongliData[m] < 4095) {
            k = 11;
        }
        else {
            k = 12;
        }
        n = k;
        while(n>=0) {
            //获取wNongliData(m)的第n个二进制位的值
            nBit = wNongliData[m];
            for (i=1; i<n+1; i++) {
                nBit = nBit/2;
            }
            nBit = nBit%2;
            if (nTheDate <= (29 + nBit)) {
                nIsEnd = 1;
                break;
            }
            nTheDate = nTheDate - 29 - nBit;
            n = n - 1;
        }
        if (nIsEnd) {
            break;
        }
        m = m + 1;
    }
    wCurYear = 1921 + m;
    wCurMonth = k - n +1;
    wCurDay = nTheDate;
    if (k == 12) {
        if (wCurMonth == wNongliData[m] / 65536 + 1) {
            wCurMonth = 1 - wCurMonth;
        } else if (wCurMonth > wNongliData[m] / 65536 + 1) {
            wCurMonth = wCurMonth - 1;
        }
    }

    //生成农历天干、地支、属相
    NSString *szShuXiang = (NSString *)[cShuXiang objectAtIndex:((wCurYear - 4) % 60) % 12];
    NSString *szNongli = [NSString stringWithFormat:@"%@(%@%@)年",szShuXiang, (NSString *)[cTianGan objectAtIndex:((wCurYear - 4) % 60) % 10],(NSString *)[cDiZhi objectAtIndex:((wCurYear - 4) % 60) % 12]];

    //生成农历月、日
    NSString *szNongliDay;
    if (wCurMonth < 1){
        szNongliDay = [NSString stringWithFormat:@"闰%@",(NSString *)[cMonName objectAtIndex:-1 * wCurMonth]];
    } else{
        szNongliDay = (NSString *)[cMonName objectAtIndex:wCurMonth];
    }

    // 完整日期
    NSString *lunarDate __attribute__((unused)) = [NSString stringWithFormat:@"%@ %@月 %@",szNongli,szNongliDay,(NSString *)[cDayName objectAtIndex:wCurDay]];

    NSString *lunarDate1 = [NSString stringWithFormat:@"%@",(NSString *)[cDayName objectAtIndex:wCurDay]];

    return lunarDate1;
}


/// get lunar componets 返回农历信息组件 年 月 日
/// @param day NSDate 哪一天
+ (NSDateComponents *)getCNLunarComponentsWithDay:(NSDate *)day {
    NSCalendar *_chineseCalendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierChinese];
    _chineseCalendar.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh-CN"];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    NSDateComponents *comps = [_chineseCalendar components:unitFlags fromDate:day];
    // NSInteger lunarDay = comps.day;
    // NSString *lunarContent = [NSString stringWithFormat:@"%@", self.lunarChars[lunarDay-1]];
    
    return  comps;
}

- (NSString *)getLunarYear:(NSDate *)day {
    
    NSDateComponents *one = [SCUtils getCNLunarComponentsWithDay:day];
    return _lunarYearChars[one.year - 1];
}

- (NSString *)getLunarMonth:(NSDate *)day {
    
    NSDateComponents *one = [SCUtils getCNLunarComponentsWithDay:day];
    return _lunarMonthChars[one.month - 1];
}

- (NSString *)getLunarDay:(NSDate *)day {
    
    NSDateComponents *one = [SCUtils getCNLunarComponentsWithDay:day];
    return _lunarChars[one.day - 1];
}


/// return which type nation days 返回节假日类型
/// @param dateStr string like yyyy-mm-dd
+ (KCNATIONSTATUS)whichNationDays:(NSString *)dateStr {
    KCNATIONSTATUS rt = KCNATIONSTATUSnormal;
    Boolean isShowCnNationDays= [[NSUserDefaults standardUserDefaults] boolForKey:kshowCnNationDays];
    if (isShowCnNationDays) {
        NSArray *workArray = [SNPlist.cNationWorkDays allKeys];
        NSArray *relaxArray = [SNPlist.cNationRelaxDays allKeys];
        
        if ([workArray indexOfObject:dateStr] != NSNotFound) {
            rt = KCNATIONSTATUSwork;
            _holidayStr = SNPlist.cNationWorkDays[dateStr];
        } else if ([relaxArray indexOfObject:dateStr] != NSNotFound) {
            rt = KCNATIONSTATUSrelax;
            _holidayStr = SNPlist.cNationRelaxDays[dateStr];
        }
    }
    
    return rt;
}

+ (NSString *)holidayName {
    return _holidayStr;
}

+ (void)setHolidayName:(NSString *)holidayName {
    _holidayStr = holidayName;
}


/// 因为添加中国法定节假日显示
/// 所以agendaview里也要显示这个状态
/// 然后统一都添加到日程的列表里，放在第一个位置
/// @param events 日程列表
/// @param date 选中的日期
+ (NSArray *)tansformCnholidayToEvents:(NSArray *)events date:(MoDate)date{
    NSArray *arr = events;
    Boolean isShowCnNationDays= [[NSUserDefaults standardUserDefaults] boolForKey:kshowCnNationDays];
    if (isShowCnNationDays) {
        NSString *todayDateStr = NSStringFromMoDateWithoutJulian(date);
        KCNATIONSTATUS todayType = [SCUtils whichNationDays:todayDateStr];
        NSNumber *typeNum = [NSNumber numberWithInteger:todayType];
        if (todayType & (KCNATIONSTATUSrelax | KCNATIONSTATUSwork)) {
            if (events) {
                NSMutableArray *addTypeArr = [NSMutableArray arrayWithObject:typeNum];
                [addTypeArr addObjectsFromArray:events];
                arr = addTypeArr;
            } else {
                arr = [NSArray arrayWithObject:typeNum];
            }
        }
    }
    
    return arr;
}
@end
