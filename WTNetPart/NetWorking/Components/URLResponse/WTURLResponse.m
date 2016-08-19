//
//  WTURLResponse.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTURLResponse.h"
#import "NSURLRequest+RequestParams.h"
#import "NSObject+NetworkingMethods.h"
@interface WTURLResponse ()

@property (nonatomic, assign, readwrite) WTURLResponseStatus status;
@property (nonatomic, copy, readwrite) NSString *contentString;
@property (nonatomic, copy, readwrite) id content;
@property (nonatomic, copy, readwrite) NSURLRequest *request;
@property (nonatomic, assign, readwrite) NSInteger requestId;
@property (nonatomic, copy, readwrite) NSData *responseData;
@property (nonatomic, assign, readwrite) BOOL isCache;
@property (nonatomic, copy, readwrite) id modelsData;

@end

@implementation WTURLResponse
#pragma mark - life cycle
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData status:(WTURLResponseStatus)status
{
    self = [super init];
    if (self) {
        self.contentString = responseString;
        self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        self.status = status;
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
    }
    return self;
}
- (instancetype)initWithResponseString:(NSString *)responseString requestId:(NSNumber *)requestId request:(NSURLRequest *)request responseData:(NSData *)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        self.contentString = [responseString WT_defaultValue:@""];
        self.status = [self responseStatusWithError:error];
        self.requestId = [requestId integerValue];
        self.request = request;
        self.responseData = responseData;
        self.requestParams = request.requestParams;
        self.isCache = NO;
        
        if (responseData) {
            self.content = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:NULL];
        } else {
            self.content = nil;
        }
    }
    return self;
}
- (instancetype)initWithData:(id)data
{
    self = [super init];
    if (self) {
        self.contentString = @"";
        self.status = [self responseStatusWithError:nil];
        self.requestId = 0;
        self.request = nil;
        self.responseData = nil;
        self.content = nil;
        self.isCache = YES;
        self.modelsData = data;
    }
    return self;
}
#pragma mark - private methods
- (WTURLResponseStatus)responseStatusWithError:(NSError *)error
{
    if (error) {
        WTURLResponseStatus result = WTURLResponseStatusErrorNoNetwork;
        
        // 除了超时以外，所有错误都当成是无网络
        if (error.code == NSURLErrorTimedOut) {
            result = WTURLResponseStatusErrorTimeout;
        }
        return result;
    } else {
        return WTURLResponseStatusSuccess;
    }
}
@end
