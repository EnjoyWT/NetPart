//
//  WTServiceFactory.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTService.h"
@interface WTServiceFactory : NSObject
+ (instancetype)sharedInstance;
- (WTService<WTServiceProtocal> *)serviceWithIdentifier:(Class)classIdentifier;
@end
