//
//  WebviewProgressLine.h
//  DaiShengInvest
//
//  Created by 张睿 on 2017/8/23.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebviewProgressLine : UIView


//进度条颜色
@property (nonatomic,strong) UIColor  *lineColor;

//开始加载
-(void)startLoadingAnimation;

//结束加载
-(void)endLoadingAnimation;



@end
