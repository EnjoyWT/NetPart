//
//  WTApiProxy.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTApiProxy.h"
#import <AFNetworking/AFNetworking.h>
#import "WTRequestGenerator.h"
#import "WTLogger.h"
@interface WTApiProxy ()

@property (nonatomic, strong) NSMutableDictionary *dispatchTable;
@property (nonatomic, strong) NSNumber *recordedRequestId;

//AFNetworking stuff
@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end
@implementation WTApiProxy

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WTApiProxy *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTApiProxy alloc] init];
    });
    return sharedInstance;
}


#pragma mark - public methods
- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail
{
    NSURLRequest *request = [[WTRequestGenerator sharedInstance] generateGETRequestWithServiceIdentifier:servieIdentifier requestParams:params relativeURL:relativeUrl];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail
{
    
    
    NSURLRequest *request = [[WTRequestGenerator sharedInstance] generatePOSTRequestWithServiceIdentifier:servieIdentifier requestParams:params relativeURL:relativeUrl];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    
    
    return [requestId integerValue];
}

- (NSInteger)callPUTWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail
{
    NSURLRequest *request = [[WTRequestGenerator sharedInstance] generatePutRequestWithServiceIdentifier:servieIdentifier requestParams:params relativeURL:relativeUrl];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (NSInteger)callDELETEWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail
{
    NSURLRequest *request = [[WTRequestGenerator sharedInstance] generateDeleteRequestWithServiceIdentifier:servieIdentifier requestParams:params relativeURL:relativeUrl];
    NSNumber *requestId = [self callApiWithRequest:request success:success fail:fail];
    return [requestId integerValue];
}

- (void)cancelRequestWithRequestID:(NSNumber *)requestID
{
    
    
    NSURLSessionDataTask *requestOperation = self.dispatchTable[requestID];
    [requestOperation cancel];
    
    
    [self.dispatchTable removeObjectForKey:requestID];
}

- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList
{
    for (NSNumber *requestId in requestIDList) {
        [self cancelRequestWithRequestID:requestId];
    }
}

#pragma mark - getters and setters
- (NSMutableDictionary *)dispatchTable
{
    if (_dispatchTable == nil) {
        _dispatchTable = [[NSMutableDictionary alloc] init];
    }
    return _dispatchTable;
}
- (AFHTTPSessionManager *)sessionManager
{
    if (_sessionManager == nil) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES;
        _sessionManager.securityPolicy.validatesDomainName = NO;
    }
    return _sessionManager;
}
/** 这个函数存在的意义在于，如果将来要把AFNetworking换掉，只要修改这个函数的实现即可。 */
- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(WTCallback)success fail:(WTCallback)fail
{
    
    NSLog(@"\n==================================\n\nRequest Start: \n\n %@\n\n==================================", request.URL);
    
    // 跑到这里的block的时候，就已经是主线程了。
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.sessionManager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        NSNumber *requestID = @([dataTask taskIdentifier]);
        [self.dispatchTable removeObjectForKey:requestID];
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSData *responseData = responseObject;
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        
        if (error) {
            
            
            
            [WTLogger logDebugInfoWithResponse:httpResponse
                                 resposeString:responseString
                                       request:request
                                         error:error];
            WTURLResponse *WTResponse = [[WTURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData error:error];
            fail?fail(WTResponse):nil;
        } else {
            
            
            // 检查http response是否成立。
            [WTLogger logDebugInfoWithResponse:httpResponse
                                 resposeString:responseString
                                       request:request
                                         error:NULL];
            WTURLResponse *WTResponse = [[WTURLResponse alloc] initWithResponseString:responseString requestId:requestID request:request responseData:responseData status:WTURLResponseStatusSuccess];
            success?success(WTResponse):nil;
        }
    }];
    
    NSNumber *requestId = @([dataTask taskIdentifier]);
    
    self.dispatchTable[requestId] = dataTask;
    [dataTask resume];
    
    return requestId;
}

@end
