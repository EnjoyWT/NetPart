//
//  WTLocationManager.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, WTLocationManagerLocationServiceStatus) {
    WTLocationManagerLocationServiceStatusDefault,               //默认状态
    WTLocationManagerLocationServiceStatusOK,                    //定位功能正常
    WTLocationManagerLocationServiceStatusUnknownError,          //未知错误
    WTLocationManagerLocationServiceStatusUnAvailable,           //定位功能关掉了
    WTLocationManagerLocationServiceStatusNoAuthorization,       //定位功能打开，但是用户不允许使用定位
    WTLocationManagerLocationServiceStatusNoNetwork,             //没有网络
    WTLocationManagerLocationServiceStatusNotDetermined          //用户还没做出是否要允许应用使用定位功能的决定，第一次安装应用的时候会提示用户做出是否允许使用定位功能的决定
};

typedef NS_ENUM(NSUInteger, WTLocationManagerLocationResult) {
    WTLocationManagerLocationResultDefault,              //默认状态
    WTLocationManagerLocationResultLocating,             //定位中
    WTLocationManagerLocationResultSuccess,              //定位成功
    WTLocationManagerLocationResultFail,                 //定位失败
    WTLocationManagerLocationResultParamsError,          //调用API的参数错了
    WTLocationManagerLocationResultTimeout,              //超时
    WTLocationManagerLocationResultNoNetwork,            //没有网络
    WTLocationManagerLocationResultNoContent             //API没返回数据或返回数据是错的
};

@interface WTLocationManager : NSObject

@property (nonatomic, assign, readonly) WTLocationManagerLocationResult locationResult;
@property (nonatomic, assign,readonly) WTLocationManagerLocationServiceStatus locationStatus;
@property (nonatomic, copy, readonly) CLLocation *currentLocation;

+ (instancetype)sharedInstance;

- (void)startLocation;
- (void)stopLocation;
- (void)restartLocation;

@end
