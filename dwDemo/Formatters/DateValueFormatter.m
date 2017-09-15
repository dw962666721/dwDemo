//
//  DateValueFormatter.m
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//


#import "DateValueFormatter.h"

@interface DateValueFormatter ()
{
    NSDateFormatter *_dateFormatter;
}
@end

@implementation DateValueFormatter

- (id)init
{
    self = [super init];
    if (self)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"MM-dd HH:mm";
    }
    return self;
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
//    NSString *dateStr=@"2012-5-4 4:34:23";
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];//创建一个日期格式化器
    dateFormatter.dateFormat=@"yyyy-MM-dd HH:mm:ss";//后面的hh:mm:ss不写可以吗?答案不写不可以
    
    //dateFormatter.dateFormat=@"yyyy-MM-dd hh:mm:ss";//转化格式
    NSDate *starDate = [dateFormatter dateFromString:self.starDateStr];
    
    NSTimeInterval interval = 60 * 60 * 2;
    if ([self.dtType isEqualToString:@"m1"])
    {
        interval = 60;
    }
    else if ([self.dtType isEqualToString:@"m5"])
    {
        interval = 60*5;
    }
    else if ([self.dtType isEqualToString:@"m15"])
    {
        interval = 60*15;
    }
    else if ([self.dtType isEqualToString:@"m30"])
    {
        interval = 60*30;
    }
    else if ([self.dtType isEqualToString:@"h1"])
    {
        interval = 60*60;
    }
    else if ([self.dtType isEqualToString:@"h4"])
    {
        interval = 60*60*4;
    }
    else if ([self.dtType isEqualToString:@"d1"])
    {
        interval = 60*60*24;
    }
    else if ([self.dtType isEqualToString:@"w1"])
    {
        interval = 60*60*24*7;
    }
    else if ([self.dtType isEqualToString:@"mn1"])
    {
        NSDateComponents *comps = [[NSDateComponents alloc] init];
        [comps setMonth:1*value];
        NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *showDate = [calender dateByAddingComponents:comps toDate:starDate options:0];
        return [_dateFormatter stringFromDate:showDate];
    }
    NSDate *showDate = [starDate initWithTimeInterval:interval*value sinceDate:starDate];
    
    return [_dateFormatter stringFromDate:showDate];
}

@end
