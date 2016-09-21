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

- (NSInteger)callUploadWithFilePath:(NSString *)filePath serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock success:(WTCallback)success fail:(WTCallback)fail;
- (NSInteger)callUploadWithData:(NSData*)fileData withParams:(NSDictionary*)Params serviceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl progress:(void (^)(NSProgress *uploadProgress)) uploadProgressBlock success:(WTCallback)success fail:(WTCallback)fail;

- (NSInteger)callDownloadToPath:(NSString *)targetPath withServiceIdentifier:(Class)servieIdentifier relativeURL:(NSString *)relativeUrl progress:(void (^)(NSProgress *downloadProgress))downloadProgress success:(WTCallback)success fail:(WTCallback)fail ;

- (NSNumber *)callApiWithRequest:(NSURLRequest *)request success:(WTCallback)success fail:(WTCallback)fail;
- (void)cancelRequestWithRequestID:(NSNumber *)requestID;
- (void)cancelRequestWithRequestIDList:(NSArray *)requestIDList;
@end
