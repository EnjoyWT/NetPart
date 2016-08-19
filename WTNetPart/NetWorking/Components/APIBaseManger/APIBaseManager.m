//
//  APIBaseManger.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "APIBaseManager.h"
#import "WTCache.h"
#import "WTServiceFactory.h"
#import "WTApiProxy.h"
#import "WTLogger.h"
#import "WTAppContext.h"


#define WTCallAPI(REQUEST_METHOD, REQUEST_ID)                                                   \
{                                                                                               \
__weak typeof(self) weakSelf = self;                                                        \
REQUEST_ID = [[WTApiProxy sharedInstance] call##REQUEST_METHOD##WithParams:apiParams serviceIdentifier:self.child.serviceType relativeURL:self.child.relativeURL success:^(WTURLResponse *response) { \
__strong typeof(weakSelf) strongSelf = weakSelf;                                        \
[strongSelf successedOnCallingAPI:response];                                            \
} fail:^(WTURLResponse *response) {                                                        \
__strong typeof(weakSelf) strongSelf = weakSelf;                                        \
[strongSelf failedOnCallingAPI:response withErrorType:WTAPIManagerErrorTypeDefault];    \
}];                                                                                         \
[self.requestIdList addObject:@(REQUEST_ID)];                                               \
}

@interface APIBaseManager  ()


@property (nonatomic, assign, readwrite) BOOL isLoading;
@property (nonatomic, assign, readwrite) BOOL isNativeDataEmpty;
@property (nonatomic, copy, readwrite) NSString *errorMessage;
@property (nonatomic, readwrite) WTAPIManagerErrorType errorType;
@property (nonatomic, strong) NSMutableArray *requestIdList;//(wt)这个仅仅是为了判断请求是否在进行??:这个是一个api对应多次请求的存储.
@property (nonatomic, strong) WTCache *cache;

@end

@implementation APIBaseManager
#pragma mark - life cycle
- (instancetype)init
{
    self = [super init];
    if (self) {
        _delegate = nil;
        _validator = nil;
        _paramSource = nil;
        
        _fetchedRawData = nil;
        
        _errorMessage = nil;
        _errorType = WTAPIManagerErrorTypeDefault;
        
        if ([self conformsToProtocol:@protocol(WTAPIManagerChild)]) {
            self.child = (id <WTAPIManagerChild>)self;
        } else {
            
            NSException *exception = [[NSException alloc] init];
            
            @throw exception;
        }
    }
    return self;
}

- (void)dealloc
{
    
    [self cancelAllRequests];
    self.requestIdList = nil;
}

#pragma mark - public methods
- (void)cancelAllRequests
{
    [[WTApiProxy sharedInstance] cancelRequestWithRequestIDList:self.requestIdList];
    [self.requestIdList removeAllObjects];
}
- (void)cancelRequestWithRequestId:(NSInteger)requestID
{
    [self removeRequestIdWithRequestID:requestID];
    [[WTApiProxy sharedInstance] cancelRequestWithRequestID:@(requestID)];
}
- (id)fetchDataWithReformer:(id<WTAPIManagerDataReformer>)reformer
{
    id resultData = nil;
    if ([reformer respondsToSelector:@selector(manager:reformData:)]) {
        
        
        resultData = [reformer manager:self reformData:self.fetchedRawData];
        
        
    } else {
        
        resultData = [self.fetchedRawData mutableCopy];
    }
    return resultData;
}
#pragma mark - calling api
- (NSInteger)loadData
{
    NSDictionary *params = [self.paramSource paramsForApi:self];
    NSInteger requestId = [self loadDataWithParams:params];
    return requestId;
}

- (NSInteger)loadDataWithParams:(NSDictionary *)params
{
    NSInteger requestId = 0;
    NSDictionary *apiParams = [self reformParams:params];
    if ([self shouldCallAPIWithParams:apiParams]) {
        
        if (self.validator == nil||[self.validator manager:self isCorrectWithParamsData:apiParams]) {

            
            // 先检查一下是否有内存缓存
            if ([self shouldCache] && [self hasCacheWithParams:apiParams]) {
                return 0;
            }
            
            
            //检查本地磁盘中没有数据
            if ([self shouldLoadFromNative]) {//(wt)
                
                
                BOOL hasNativeData = [self loadDataFromNative];
                
                if (hasNativeData == YES){ //本地有数据-->数据的有效性子类中判断,是否继续请求,子类中决定//返回数据如何统一(NSData, 和数组Model 如何区分)//暂时妥协的方法是在子类中自定义一个返回数据类型,根据self.isNativeDataEmpty来判断是否来自本地数据库,从而调用不同的数据,以及数据的处理.
                    self.isNativeDataEmpty = NO;
                    
                    [self.delegate managerCallAPIDidSuccess:self];
                    
                    return requestId;
                    
                }
                self.isNativeDataEmpty = YES;
                
            }
            
            
            // 实际的网络请求
            if ([self isReachable]) {
                self.isLoading = YES;
                switch (self.child.requestType)
                {
                    case WTAPIManagerRequestTypeGet:
                        
                        WTCallAPI(GET, requestId);
                        break;
                    case WTAPIManagerRequestTypePost:
                        
                        WTCallAPI(POST, requestId);
                        break;
                    case WTAPIManagerRequestTypePut:
                        WTCallAPI(PUT, requestId);
                        break;
                    case WTAPIManagerRequestTypeDelete:
                        WTCallAPI(DELETE, requestId);
                        break;
                    default:
                        break;
                }
                
                NSMutableDictionary *params = [apiParams mutableCopy];
                params[WTAPIBaseManagerRequestID] = @(requestId);
                [self afterCallingAPIWithParams:params];
                return requestId;
                
            } else {
                
                //这里没有网络时请求本地数据,本地有返回数据,没有返回失败调用
                
                [self failedOnCallingAPI:nil withErrorType:WTAPIManagerErrorTypeNoNetWork];
                return requestId;
            }
        } else {
            
            
            [self failedOnCallingAPI:nil withErrorType:WTAPIManagerErrorTypeParamsError];
            return requestId;
        }
    }
    return requestId;
}

#pragma mark - api callbacks
- (void)successedOnCallingAPI:(WTURLResponse *)response
{
    self.isLoading = NO;
    self.response = response;

    if (response.content) {
        self.fetchedRawData = [response.content copy];
    } else {
        self.fetchedRawData = [response.responseData copy];
    }
    [self removeRequestIdWithRequestID:response.requestId];
    if (self.validator ==nil ||[self.validator manager:self isCorrectWithCallBackData:response.content]) {
        
        if ([self shouldCache] && !response.isCache) { //(wt)这里内存缓存了请求数据
            [self.cache saveCacheWithData:response.responseData serviceIdentifier:self.child.serviceType methodName:self.child.relativeURL requestParams:response.requestParams];
        }
        
        if ([self beforePerformSuccessWithResponse:response]) {
            if ([self shouldLoadFromNative]) {
                
                if (response.isCache == YES) {
                    [self.delegate managerCallAPIDidSuccess:self];
                }
                if (self.isNativeDataEmpty) {
                    [self.delegate managerCallAPIDidSuccess:self];
                }
                
            } else {
                
                [self.delegate managerCallAPIDidSuccess:self];
            }
        }
        [self afterPerformSuccessWithResponse:response];
    } else {
        
        [self failedOnCallingAPI:response withErrorType:WTAPIManagerErrorTypeNoContent];
    }
}

- (void)failedOnCallingAPI:(WTURLResponse *)response withErrorType:(WTAPIManagerErrorType)errorType
{
    self.isLoading = NO;
    self.response = response;
#warning (wt)这里通过通知来判断需要token的请求中, token是否失效,这仅仅是作者自己的特定app中的框架逻辑.自己的需要处理:(1.去掉2.相似的逻辑处理)(这里是作者的一个处理的亮点需要学习)
//    if ([response.content[@"id"] isEqualToString:@"expired_access_token"]) {
//        // token 失效
//        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenInvalidNotification
//                                                            object:nil
//                                                          userInfo:@{
//                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
//                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
//                                                                     }];
//    } else if ([response.content[@"id"] isEqualToString:@"illegal_access_token"]) {
//        // token 无效，重新登录
//        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenIllegalNotification
//                                                            object:nil
//                                                          userInfo:@{
//                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
//                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
//                                                                     }];
//    } else if ([response.content[@"id"] isEqualToString:@"no_permission_for_this_api"]) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kBSUserTokenIllegalNotification
//                                                            object:nil
//                                                          userInfo:@{
//                                                                     kBSUserTokenNotificationUserInfoKeyRequestToContinue:[response.request mutableCopy],
//                                                                     kBSUserTokenNotificationUserInfoKeyManagerToContinue:self
//                                                                     }];
//    } else {
        // 其他错误
        self.errorType = errorType;
        [self removeRequestIdWithRequestID:response.requestId];
        if ([self beforePerformFailWithResponse:response]) {
            [self.delegate managerCallAPIDidFailed:self];
        }
        [self afterPerformFailWithResponse:response];
 //   }
}

#pragma mark - method for interceptor

/*
 拦截器的功能可以由子类通过继承实现，也可以由其它对象实现,两种做法可以共存
 当两种情况共存的时候，子类重载的方法一定要调用一下super
 然后它们的调用顺序是BaseManager会先调用子类重载的实现，再调用外部interceptor的实现
 
 notes:
 正常情况下，拦截器是通过代理的方式实现的，因此可以不需要以下这些代码
 但是为了将来拓展方便，如果在调用拦截器之前manager又希望自己能够先做一些事情，所以这些方法还是需要能够被继承重载的
 所有重载的方法，都要调用一下super,这样才能保证外部interceptor能够被调到
 这就是decorate pattern
 */
- (BOOL)beforePerformSuccessWithResponse:(WTURLResponse *)response
{
    BOOL result = YES;
    
    self.errorType = WTAPIManagerErrorTypeSuccess;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(beforePerformSuccessWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformSuccessWithResponse:response];
    }
    return result;
}

- (void)afterPerformSuccessWithResponse:(WTURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(afterPerformSuccessWithResponse:)]) {
        [self.interceptor manager:self afterPerformSuccessWithResponse:response];
    }
}

- (BOOL)beforePerformFailWithResponse:(WTURLResponse *)response
{
    BOOL result = YES;
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(beforePerformFailWithResponse:)]) {
        result = [self.interceptor manager:self beforePerformFailWithResponse:response];
    }
    return result;
}

- (void)afterPerformFailWithResponse:(WTURLResponse *)response
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(afterPerformFailWithResponse:)]) {
        [self.interceptor manager:self afterPerformFailWithResponse:response];
    }
}

//只有返回YES才会继续调用API
- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(shouldCallAPIWithParams:)]) {
        return [self.interceptor manager:self shouldCallAPIWithParams:params];
    } else {
        return YES;
    }
}

- (void)afterCallingAPIWithParams:(NSDictionary *)params
{
    if (self != self.interceptor && [self.interceptor respondsToSelector:@selector(afterCallingAPIWithParams:)]) {
        [self.interceptor manager:self afterCallingAPIWithParams:params];
    }
}

#pragma mark - method for child
- (void)cleanData
{
    [self.cache clean];
    self.fetchedRawData = nil;
    self.errorMessage = nil;
    self.errorType = WTAPIManagerErrorTypeDefault;
}

//如果需要在调用API之前额外添加一些参数，比如pageNumber和pageSize之类的就在这里添加
//子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
- (NSDictionary *)reformParams:(NSDictionary *)params
{
    IMP childIMP = [self.child methodForSelector:@selector(reformParams:)];
    IMP selfIMP = [self methodForSelector:@selector(reformParams:)];
    
    if (childIMP == selfIMP) {
        return params;
    } else {
        // 如果child是继承得来的，那么这里就不会跑到，会直接跑子类中的IMP。
        // 如果child是另一个对象，就会跑到这里
        NSDictionary *result = nil;
        result = [self.child reformParams:params];
        if (result) {
            return result;
        } else {
            return params;
        }
    }
}

- (BOOL)shouldCache
{
    return WTShouldCache;
}

#pragma mark - getters and setters
- (WTCache *)cache
{
    if (_cache == nil) {
        _cache = [WTCache sharedInstance];
    }
    return _cache;
}

- (NSMutableArray *)requestIdList
{
    if (_requestIdList == nil) {
        _requestIdList = [[NSMutableArray alloc] init];
    }
    return _requestIdList;
}

- (BOOL)isReachable
{
    BOOL isReachability = [WTAppContext sharedInstance].isReachable;
    
    if (!isReachability) {
        self.errorType = WTAPIManagerErrorTypeNoNetWork;
    }
    return isReachability;
}

- (BOOL)isLoading
{
    if (self.requestIdList.count == 0) {
        _isLoading = NO;
    }
    return _isLoading;
}

- (BOOL)shouldLoadFromNative
{
    return NO;
}
#pragma mark - private methods
- (void)removeRequestIdWithRequestID:(NSInteger)requestId
{
    NSNumber *requestIDToRemove = nil;
    for (NSNumber *storedRequestId in self.requestIdList) {
        if ([storedRequestId integerValue] == requestId) {
            requestIDToRemove = storedRequestId;
        }
    }
    if (requestIDToRemove) {
        [self.requestIdList removeObject:requestIDToRemove];
    }
}

- (BOOL)hasCacheWithParams:(NSDictionary *)params
{
    Class  serviceIdentifier = self.child.serviceType;
    NSString *methodName = self.child.relativeURL;
    NSData *result = [self.cache fetchCachedDataWithServiceIdentifier:serviceIdentifier methodName:methodName requestParams:params];
    
    if (result == nil) {
        return NO;
    }
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof (weakSelf) strongSelf = weakSelf;
        WTURLResponse *response = [[WTURLResponse alloc] initWithData:result];
        response.requestParams = params;
        [WTLogger logDebugInfoWithCachedResponse:response methodName:methodName serviceIdentifier:[[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier]];
        [strongSelf successedOnCallingAPI:response];
    });
    return YES;
}

- (BOOL)loadDataFromNative
{
    
    NSException *exception = [[NSException alloc]init];
    
    @throw exception;
    
    return NO;
    //这里的逻辑应该在子类中去实现
    
//    NSString *methodName = self.child.relativeURL;
//    NSDictionary *result = (NSDictionary *)[[NSUserDefaults standardUserDefaults] objectForKey:methodName];
//    
//    if (result) {
//        self.isNativeDataEmpty = NO;
//        __weak typeof(self) weakSelf = self;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            __strong typeof(weakSelf) strongSelf = weakSelf;
//            WTURLResponse *response = [[WTURLResponse alloc] initWithData:[NSJSONSerialization dataWithJSONObject:result options:0 error:NULL]];
//            [strongSelf successedOnCallingAPI:response];
//        });
//    } else {
//        self.isNativeDataEmpty = YES;
//    }
}
@end

