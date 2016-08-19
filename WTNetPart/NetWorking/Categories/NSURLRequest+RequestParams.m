//
//  NSURLRequest+RequestParams.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "NSURLRequest+RequestParams.h"
#import <objc/runtime.h>
static void *WTNetworkingRequestParams;
@implementation NSURLRequest (RequestParams)

- (void)setRequestParams:(NSDictionary *)requestParams
{
    objc_setAssociatedObject(self, &WTNetworkingRequestParams, requestParams, OBJC_ASSOCIATION_COPY);
}

- (NSDictionary *)requestParams
{
    return objc_getAssociatedObject(self, &WTNetworkingRequestParams);
}
@end
