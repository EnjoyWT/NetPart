//
//  WTApiProxy.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTURLResponse.h"
typedef void(^WTCallback)(WTURLResponse *response);
@interface WTApiProxy : NSObject
+ (instancetype)sharedInstance;

- (NSInteger)callGETWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail;
- (NSInteger)callPOSTWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail;
- (NSInteger)callPUTWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail;
- (NSInteger)callDELETEWithParams:(NSDictionary *)params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl success:(WTCallback)success fail:(WTCallback)fail;


- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(WTCallback)success fail:(WTCallback)fail;
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;
@end
