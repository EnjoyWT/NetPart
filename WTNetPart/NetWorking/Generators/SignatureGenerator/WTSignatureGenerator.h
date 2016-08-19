//
//  WTSignatureGenerator.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
//这个是加密签名使用,目前未找到使用方法
@interface WTSignatureGenerator : NSObject
+ (NSString *)signGetWithSigParams:(NSDictionary *)allParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey publicKey:(NSString *)publicKey;
+ (NSString *)signRestfulGetWithAllParams:(NSDictionary *)allParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey;

+ (NSString *)signPostWithApiParams:(NSDictionary *)apiParams privateKey:(NSString *)privateKey publicKey:(NSString *)publicKey;
+ (NSString *)signRestfulPOSTWithApiParams:(id)apiParams commonParams:(NSDictionary *)commonParams methodName:(NSString *)methodName apiVersion:(NSString *)apiVersion privateKey:(NSString *)privateKey;
@end
