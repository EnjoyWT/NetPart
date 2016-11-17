//
//  ServicFirst.m
//  NetPartDemo
//
//  Created by lianzhu on 16/10/10.
//  Copyright © 2016年 WT. All rights reserved.
//

#import "ServicFirst.h"
#import "WTAppContext.h"
@implementation ServicFirst
- (BOOL)isOnline
{
    // return YES;
    
    return [WTAppContext sharedInstance].isOnline;
}

- (NSString *)offlineApiBaseUrl
{
    return @"offlineApiBaseUrl";
}

- (NSString *)onlineApiBaseUrl
{
    return @"onlineApiBaseUrl";
}

- (NSString *)offlineApiVersion
{
    return @"";
}

- (NSString *)onlineApiVersion
{
    return @"";
}

- (NSString *)onlinePublicKey
{
    return @"";
}

- (NSString *)offlinePublicKey
{
    return @"";
}

- (NSString *)onlinePrivateKey
{
    return @"";
}

- (NSString *)offlinePrivateKey
{
    return @"";
}
@end
