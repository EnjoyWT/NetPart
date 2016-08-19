//
//  WTCache.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTCache.h"
#import "WTNetworkingConfiguration.h"
#import "NSDictionary+NetworkingMethods.h"
@interface WTCache ()

@property (nonatomic, strong) NSCache *cache;

@end
@implementation WTCache
#pragma mark - getters and setters
- (NSCache *)cache
{
    if (_cache == nil) {
        _cache = [[NSCache alloc] init];
        _cache.countLimit = WTCacheCountLimit;
    }
    return _cache;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WTCache *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTCache alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public method
- (NSData *)fetchCachedDataWithServiceIdentifier:(Class)serviceIdentifier
                                      methodName:(NSString *)methodName
                                   requestParams:(NSDictionary *)requestParams
{
    return [self fetchCachedDataWithKey:[self keyWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:requestParams]];
}

- (void)saveCacheWithData:(NSData *)cachedData
        serviceIdentifier:(Class)serviceIdentifier
               methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams
{
    [self saveCacheWithData:cachedData key:[self keyWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:requestParams]];
}

- (void)deleteCacheWithServiceIdentifier:(Class)serviceIdentifier
                              methodName:(NSString *)methodName
                           requestParams:(NSDictionary *)requestParams
{
    [self deleteCacheWithKey:[self keyWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:requestParams]];
}

- (NSData *)fetchCachedDataWithKey:(NSString *)key
{
    WTCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject.isOutdated || cachedObject.isEmpty) {
        
        if (cachedObject.isOutdated) {
           [self deleteCacheWithKey:key];
        }
        
        return nil;
    } else {
        return cachedObject.content;
    }
}

- (void)saveCacheWithData:(NSData *)cachedData key:(NSString *)key
{
    WTCachedObject *cachedObject = [self.cache objectForKey:key];
    if (cachedObject == nil) {
        cachedObject = [[WTCachedObject alloc] init];
    }
    [cachedObject updateContent:cachedData];
    [self.cache setObject:cachedObject forKey:key];
}

- (void)deleteCacheWithKey:(NSString *)key
{
    [self.cache removeObjectForKey:key];
}

- (void)clean
{
    [self.cache removeAllObjects];
}

- (NSString *)keyWithServiceIdentifier:(Class)serviceIdentifier methodName:(NSString *)methodName requestParams:(NSDictionary *)requestParams
{
    NSString *serviceIdentifierStr= NSStringFromClass(serviceIdentifier);
    return [NSString stringWithFormat:@"%@%@%@", serviceIdentifierStr, methodName, [requestParams WT_urlParamsStringSignature:NO]];
}
@end
