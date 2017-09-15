//
//  DayAxisValueFormatter.h
//  ChartsDemo
//  Copyright © 2016 dcg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "dwDemo-Swift.h"

@interface DayAxisValueFormatter : NSObject <IChartAxisValueFormatter>

- (id)initForChart:(BarLineChartViewBase *)chart;

@end
