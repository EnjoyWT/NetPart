//
//  RequestFirst.m
//  NetPartDemo
//
//  Created by lianzhu on 16/10/10.
//  Copyright © 2016年 WT. All rights reserved.
//

#import "RequestFirst.h"

@implementation RequestFirst
- (NSString *)relativeURL {
    return @"clientCate/getAllClientCategory.do";
}
- (Class)serviceType {
    return [ServicFirst class];
}
- (WTAPIManagerRequestType)requestType {
    return WTAPIManagerRequestTypeGet;
}
- (BOOL)shouldCache {
    
    return NO;
}
@end
