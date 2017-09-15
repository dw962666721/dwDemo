//
//  DateValueFormatter.h
//  ChartsDemo
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

#import <UIKit/UIKit.h>
#import "dwDemo-Swift.h"

@interface DateValueFormatter : NSObject <IChartAxisValueFormatter>
@property NSString *dtType;
@property NSString *starDateStr;
@end
