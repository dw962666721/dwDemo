//
//  WebviewProgressLine.m
//  DaiShengInvest
//
//  Created by 张睿 on 2017/8/23.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import "WebviewProgressLine.h"
#import "UIView+Frame.h"

@implementation WebviewProgressLine



-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.hidden = YES;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

-(void)setLineColor:(UIColor *)lineColor{
    _lineColor = lineColor;
    self.backgroundColor = lineColor;
}

-(void)startLoadingAnimation{
    
    self.hidden = NO;
    self.width = 0.0;
    
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:10 animations:^{
        weakSelf.width = SCREEN_WIDTH * 0.1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.4 animations:^{
            weakSelf.width = SCREEN_WIDTH * 0.8;
        }];
    }];
    
    
}

-(void)endLoadingAnimation{
    __weak UIView *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^{
        weakSelf.width = SCREEN_WIDTH;
    } completion:^(BOOL finished) {
        weakSelf.hidden = YES;
    }];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
