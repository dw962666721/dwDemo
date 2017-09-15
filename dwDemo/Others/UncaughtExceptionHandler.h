//
//  UncaughtExceptionHandler.h
//  DaiShengInvest
//
//  Created by 张睿 on 2017/9/8.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

@interface UncaughtExceptionHandler : NSObject
{
    BOOL dismissed;
}

@end

void HandleException(NSException *exception);
void SignalHandler(int signal);
void InstallUncaughtExceptionHandler(void);
