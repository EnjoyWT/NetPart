//
//  NSDictionary+NetworkingMethods.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (NetworkingMethods)
- (NSString *)WT_urlParamsStringSignature:(BOOL)isForSignature;
- (NSString *)WT_jsonString;
- (NSArray *)WT_transformedUrlParamsArraySignature:(BOOL)isForSignature;
@end
