//
//  WTRequestGenerator.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//


//warning signGetWithSigParams 这个类是对请求进行加密处理的MD_5的算法方法,这个demo中并没有使用这个类.
#import "WTRequestGenerator.h"
#import <AFNetworking/AFNetworking.h>
#import "NSURLRequest+RequestParams.h"
#import "WTServiceFactory.h"
@interface WTRequestGenerator ()

@property (nonatomic, strong) AFHTTPRequestSerializer *httpRequestSerializer;

@end
@implementation WTRequestGenerator
#pragma mark - public methods
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WTRequestGenerator *sharedInstance = nil;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTRequestGenerator alloc] init];
    });
    return sharedInstance;
}
- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl
{
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString;
    
    if (service.apiVersion.length != 0) {
        urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    } else if (relativeUrl.length!= 0){
        urlString = [NSString stringWithFormat:@"%@/%@", service.apiBaseUrl, relativeUrl];
    }else {
        urlString = service.apiBaseUrl;
    }
    
   // [self.httpRequestSerializer setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"xxxxxxxx"];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"GET" URLString:urlString parameters:requestParams error:NULL];
    request.requestParams = requestParams;
//    if ([CTAppContext sharedInstance].accessToken) {
//        [request setValue:[CTAppContext sharedInstance].accessToken forHTTPHeaderField:@"xxxxxxxx"];
//    }
    return request;
}

- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl
{
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    
 //   [self.httpRequestSerializer setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"xxxxxxxx"];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"POST" URLString:urlString parameters:requestParams error:NULL];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
//    if ([CTAppContext sharedInstance].accessToken) {
//        [request setValue:[CTAppContext sharedInstance].accessToken forHTTPHeaderField:@"xxxxxxxx"];
//    }
    request.requestParams = requestParams;
    return request;
}
- (NSURLRequest *)generatePutRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl
{
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    
   // [self.httpRequestSerializer setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"xxxxxxxx"];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"PUT" URLString:urlString parameters:requestParams error:NULL];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
//    if ([CTAppContext sharedInstance].accessToken) {
//        [request setValue:[CTAppContext sharedInstance].accessToken forHTTPHeaderField:@"xxxxxxxx"];
//    }
    request.requestParams = requestParams;
    return request;
}
- (NSURLRequest *)generateDeleteRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl
{
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    
  //  [self.httpRequestSerializer setValue:[[NSUUID UUID] UUIDString] forHTTPHeaderField:@"xxxxxxxx"];
    
    NSMutableURLRequest *request = [self.httpRequestSerializer requestWithMethod:@"DELETE" URLString:urlString parameters:requestParams error:NULL];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:requestParams options:0 error:NULL];
    
#warning (wt)这里的token可以干掉,或者请求加密的时调用,CTService的公钥私钥,(具体放在那里还不知道)
    
//    if ([CTAppContext sharedInstance].accessToken) {
//        [request setValue:[CTAppContext sharedInstance].accessToken forHTTPHeaderField:@"xxxxxxxx"];
//    }
    request.requestParams = requestParams;
    return request;
}
- (NSURLRequest *)generateUploadRequestWithServiceIdentifier:(Class)serviceIdentifier relativeURL:(NSString *)relativeUrl {
    
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
   return request ;
}
- (NSURLRequest *)generateUploadRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl withData:(NSData *)data {
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:urlString parameters: requestParams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        [formData appendPartWithFileData:data name:@"pic" fileName:@"h.jpg" mimeType:@"image/jpeg"];
    } error:nil];
    
    return request;
}
- (NSURLRequest *)generateDownloadRequestWithServiceIdentifier:(Class)serviceIdentifier relativeURL:(NSString *)relativeUrl {
    WTService *service = [[WTServiceFactory sharedInstance] serviceWithIdentifier:serviceIdentifier];
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", service.apiBaseUrl, service.apiVersion, relativeUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    return request;
}
#pragma mark - getters and setters
- (AFHTTPRequestSerializer *)httpRequestSerializer
{
    if (_httpRequestSerializer == nil) {
        _httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        _httpRequestSerializer.timeoutInterval = WTNetworkingTimeoutSeconds;
        _httpRequestSerializer.cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    return _httpRequestSerializer;
}

@end
