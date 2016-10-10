//
//  FirstReformer.h
//  NetPartDemo
//
//  Created by lianzhu on 16/10/10.
//  Copyright © 2016年 WT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTNetWorking.h"
@interface FirstReformer : NSObject<WTAPIManagerDataReformer>
- (id)manager:(APIBaseManager *)manager reformData:(id)data;
@end
