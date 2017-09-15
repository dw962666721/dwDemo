//
//  NetworkTool.m
//  DaiShengInvest
//
//  Created by 张睿 on 2017/7/12.
//  Copyright © 2017年 davinci. All rights reserved.
//

#import "NetworkTool.h"

@implementation NetworkTool

+(instancetype)sharedTools{
    
    static NetworkTool *instance;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //基本的地址
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
//        NSURL *url = [NSURL URLWithString:@"http://dcm.yemaoka.com/"];
        //101.37.78.116:8087
//        NSURL *url = [NSURL URLWithString:@"http://101.37.78.116:8087/"];
        //103.20.249.35
        NSURL *url = [NSURL URLWithString:@"http://103.20.249.35/"];
        
        instance = [[NetworkTool alloc] initWithBaseURL:url sessionConfiguration:config];
        
        //设置超时时间
        
        config.timeoutIntervalForRequest = 10;
        
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        
        NSString * userID = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"userId"]];
        
        NSString * lastLoginTimeStr = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"lastLoginTime"]];
        NSString * createTimeStr = [NSString stringWithFormat:@"%@",[userDefaults objectForKey:@"createTime"]];
        
        instance.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        
        if ([userID isEqualToString:@""]) {
            
        }else{
            
            instance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/javascript",@"text/html", @"image/jpeg",@"image/png", @"application/octet-stream", nil];
            instance.requestSerializer = [AFHTTPRequestSerializer serializer];
            //        instance.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
            //        instance.responseSerializer = [AFJSONResponseSerializer serializer];
            //        instance.requestSerializer = [AFJSONRequestSerializer serializer];
            [instance.requestSerializer setValue:createTimeStr forHTTPHeaderField:@"createTime"];
            [instance.requestSerializer setValue:lastLoginTimeStr forHTTPHeaderField:@"lastLoginTime"];
            [instance.requestSerializer setValue:userID forHTTPHeaderField:@"userId"];

        }
        
        ((AFJSONResponseSerializer *)instance.responseSerializer).removesKeysWithNullValues = YES;
       
    });
    return instance;
}

-(NSString *)description{
    return @"aaa";
}


@end
