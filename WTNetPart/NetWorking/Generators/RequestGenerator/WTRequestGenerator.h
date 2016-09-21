//
//  WTRequestGenerator.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WTRequestGenerator : NSObject
+ (instancetype)sharedInstance;

- (NSURLRequest *)generateGETRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl;
- (NSURLRequest *)generatePOSTRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl;
- (NSURLRequest *)generatePutRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl;
- (NSURLRequest *)generateDeleteRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl;


- (NSURLRequest *)generateUploadRequestWithServiceIdentifier:(Class)serviceIdentifier relativeURL:(NSString *)relativeUrl;
- (NSURLRequest *)generateUploadRequestWithServiceIdentifier:(Class)serviceIdentifier requestParams:(NSDictionary *)requestParams relativeURL:(NSString *)relativeUrl withData:(NSData *)data ;
- (NSURLRequest *)generateDownloadRequestWithServiceIdentifier:(Class)serviceIdentifier relativeURL:(NSString *)relativeUrl;
@end
