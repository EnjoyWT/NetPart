//
//  WTServiceFactory.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTServiceFactory.h"

@interface WTServiceFactory ()

@property (nonatomic, strong) NSMutableDictionary *serviceStorage;

@end
@implementation WTServiceFactory
#pragma mark - getters and setters
- (NSMutableDictionary *)serviceStorage
{
    if (_serviceStorage == nil) {
        _serviceStorage = [[NSMutableDictionary alloc] init];
    }
    return _serviceStorage;
}

#pragma mark - life cycle
+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static WTServiceFactory *sharedInstance;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTServiceFactory alloc] init];
    });
    return sharedInstance;
}

#pragma mark - public methods
- (WTService<WTServiceProtocal> *)serviceWithIdentifier:(Class)classIdentifier
{
    NSString *identifier = NSStringFromClass(classIdentifier);
    
    if (self.serviceStorage[identifier] == nil) {
        
          self.serviceStorage[identifier] = [self newServiceWithIdentifier:classIdentifier];
        }
    
    return self.serviceStorage[identifier];
}

- (WTService<WTServiceProtocal> *)newServiceWithIdentifier:(Class)class {
    
   WTService<WTServiceProtocal> * newService = [[class alloc] init];
 
    return newService;
}
@end
