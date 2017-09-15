//
//  UncaughtExceptionHandler.m
//  DaiShengInvest
//
//  Created by 张睿 on 2017/9/8.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#import <UIKit/UIKit.h>
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "AppDelegate.h"

NSString *const UncaughtExceptionHandlerSignalExceptionName =@"UncaughtExceptionHandlerSignalExceptionName";
NSString *const UncaughtExceptionHandlerSignalKey =@"UncaughtExceptionHandlerSignalKey";
NSString *const UncaughtExceptionHandlerAddressesKey =@"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCount =0;
const int32_t UncaughtExceptionMaximum =10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount =4;
const NSInteger UncaughtExceptionHandlerReportAddressCount =5;

@implementation UncaughtExceptionHandler
+ (NSArray *)backtrace {// 程序崩溃2(程序崩溃第二步走的方法)
    void* callstack[128];
    int frames =backtrace(callstack, 128);
    char **strs =backtrace_symbols(callstack, frames);
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (i = UncaughtExceptionHandlerSkipAddressCount ; i <UncaughtExceptionHandlerSkipAddressCount +UncaughtExceptionHandlerReportAddressCount; i++){
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex {
    if (anIndex ==0){
        dismissed =YES;
    }else if(anIndex==1) {
        NSLog(@"ssssssss");
    }
}

- (void)validateAndSaveCriticalApplicationData {
    // 崩溃拦截可以做的事,写在这个方法也是极好的
//    NSLog(@"崩溃了");
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"温馨提示"  message:@"打开" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alert addAction:cancelAction];
    
    UIViewController * rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}
// 程序崩溃3(程序崩溃是第三进入的方法)
- (void)handleException:(NSException *)exception {
    [self validateAndSaveCriticalApplicationData];
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"如果点击继续，程序有可能会出现其他的问题，建议您还是点击退出按钮并重新打开\n\n"@"异常原因如下:\n%@\n%@",nil),[exception reason],[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKey]];
    UIAlertView *alert =[[UIAlertView alloc]initWithTitle:NSLocalizedString(@"抱歉，程序出现了异常",nil)
                                                  message:message
                                                 delegate:self
                                        cancelButtonTitle:NSLocalizedString(@"退出",nil)
                                        otherButtonTitles:NSLocalizedString(@"继续",nil), nil];
    
    NSLog(@"异常显示了");
    
    [alert show];
    UIAlertAction *act1 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"异常啦" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [vc addAction:act1];
    UIViewController *rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController presentViewController:vc animated:YES completion:nil];
    
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed) {
        for (NSString *mode in (__bridge NSArray *)allModes) {
            CFRunLoopRunInMode((CFStringRef)mode,0.001, false);
        }
    }
    
    CFRelease(allModes);
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT,SIG_DFL);
    signal(SIGILL,SIG_DFL);
    signal(SIGSEGV,SIG_DFL);
    signal(SIGFPE,SIG_DFL);
    signal(SIGBUS,SIG_DFL);
    signal(SIGPIPE,SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName]) {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey]intValue]);
    }else{
        [exception raise];
    }
}

@end

void HandleException(NSException *exception) {
    int32_t exceptionCount =OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount >UncaughtExceptionMaximum) {
        return;
    }
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];[userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]performSelectorOnMainThread:@selector(handleException:)withObject:
     [NSException exceptionWithName:[exception name] reason:[exception reason] userInfo:userInfo]waitUntilDone:YES];
}

void SignalHandler(int signal) {
    
    int32_t exceptionCount =OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount >UncaughtExceptionMaximum) {
        return;
    }
    
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo setObject:callStack forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]performSelectorOnMainThread:@selector(handleException:)withObject:[NSException exceptionWithName:UncaughtExceptionHandlerSignalExceptionName reason:[NSString stringWithFormat:NSLocalizedString(@"Signal %d was raised.",nil),signal]userInfo:
                                                                                                               [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:signal]forKey:UncaughtExceptionHandlerSignalKey]]waitUntilDone:YES];
}

void InstallUncaughtExceptionHandler(void) {
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGHUP, SignalHandler);//本信号在用户终端连接(正常或非正常)结束时发出, 通常是在终端的控制进程结束时, 通知同一session内的各个作业
    signal(SIGINT, SignalHandler);//程序终止(interrupt)信号, 在用户键入INTR字符(通常是Ctrl-C)时发出，用于通知前台进程组终止进程。
    signal(SIGQUIT, SignalHandler);//类似于一个程序错误信号。
    
    
    signal(SIGABRT,SignalHandler);//调用abort函数生成的信号。
    signal(SIGILL,SignalHandler);//用来立即结束程序的运行. 本
    signal(SIGSEGV,SignalHandler);//试图访问未分配给自己的内存, 或试图往没有写权限的内存地址写数据.
    signal(SIGFPE,SignalHandler);//在发生致命的算术运算错误时发出.
    signal(SIGBUS,SignalHandler);//访问不属于自己存储空间或只读存储空间
    signal(SIGPIPE,SignalHandler);//管道破裂。
}
