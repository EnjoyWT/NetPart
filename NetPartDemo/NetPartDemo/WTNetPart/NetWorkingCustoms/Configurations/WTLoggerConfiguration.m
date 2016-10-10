//
//  WTLoggerConfiguration.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTLoggerConfiguration.h"

@implementation WTLoggerConfiguration
- (void)configWithAppType:(WTAppType)appType
{
    switch (appType) {
        case WTAppTypexxx:
            self.appKey = @"xxxxxx";
            self.serviceType = @"xxxxx";
            self.sendLogMethod = @"xxxx";
            self.sendActionMethod = @"xxxxxx";
            self.sendLogKey = @"xxxxx";
            self.sendActionKey = @"xxxx";
            break;
    }
}
@end
