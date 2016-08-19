//
//  WTCache.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTCachedObject.h"
@interface WTCache : NSObject
+ (instancetype)sharedInstance;

- (NSString *)keyWithServiceIdentifier:(Class)serviceIdentifier
                            methodName:(NSString *)methodName
                         requestParams:(NSDictionary *)requestParams;



- (NSData *)fetchCachedDataWithServiceIdentifier:(Class)serviceIdentifier
                                      methodName:(NSString *)methodName
                                   requestParams:(NSDictionary *)requestParams;

- (void)saveCacheWithData:(NSData *)cachedData
        serviceIdentifier:(Class)serviceIdentifier
               methodName:(NSString *)methodName
            requestParams:(NSDictionary *)requestParams;

- (void)deleteCacheWithServiceIdentifier:(Class)serviceIdentifier
                              methodName:(NSString *)methodName
                           requestParams:(NSDictionary *)requestParams;



- (NSData *)fetchCachedDataWithKey:(NSString *)key;
- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key;
- (void)deleteCacheWithKey:(NSString *)key;
- (void)clean;
@end
