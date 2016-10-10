//
//  WTNetworkingConfiguration.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#ifndef WTNetworkingConfiguration_h
#define WTNetworkingConfiguration_h

typedef NS_ENUM(NSInteger, WTAppType) {
    WTAppTypexxx
};

typedef NS_ENUM(NSUInteger, WTURLResponseStatus)
{
    WTURLResponseStatusSuccess, //作为底层，请求是否成功只考虑是否成功收到服务器反馈。至于签名是否正确，返回的数据是否完整，由上层的CTAPIBaseManager来决定。
    WTURLResponseStatusErrorTimeout,
    WTURLResponseStatusErrorNoNetwork // 默认除了超时以外的错误都是无网络错误。
};

static NSString *WTKeychainServiceName = @"xxxxx";
static NSString *WTUDIDName = @"xxxx";
static NSString *WTPasteboardType = @"xxxx";

static BOOL WTShouldCache = NO;
static BOOL WTServiceIsOnline = NO;
static NSTimeInterval WTNetworkingTimeoutSeconds = 20.0f;
static NSTimeInterval WTCacheOutdateTimeSeconds = 300; // 5分钟的cache过期时间
static NSUInteger WTCacheCountLimit = 1000; // 最多1000条cache
static NSUInteger WTNativeFetchLimit = 20; //每次本地查询查20条数据

#endif /* WTNetworkingConfiguration_h */
