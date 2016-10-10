//
//  FirstReformer.m
//  NetPartDemo
//
//  Created by lianzhu on 16/10/10.
//  Copyright © 2016年 WT. All rights reserved.
//

#import "FirstReformer.h"

@implementation FirstReformer
- (id)manager:(APIBaseManager *)manager reformData:(id)data {
    
    //这里也可以直接组装成对应的Model
    if (data==nil) {
        return nil;
    }
    //如果数据是直接从本地获取的直接返回,因为我数据库一般使用的是coredata,此时data为存放model数组,不需要解析
    if (manager.isNativeDataEmpty) {
        return data;
    }
    
    if ([data isKindOfClass:[NSDictionary class]]||[data isKindOfClass:[NSArray class]]) {
        return data;
    }
    NSError *error;
   
   id jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
   
    if (!error) {
        return jsonData;
    }
    return nil;
}
@end
