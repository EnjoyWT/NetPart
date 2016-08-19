//
//  WTLocationManager.m
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import "WTLocationManager.h"
@interface WTLocationManager () <CLLocationManagerDelegate>

@property (nonatomic, assign, readwrite) WTLocationManagerLocationResult locationResult;
@property (nonatomic, assign, readwrite) WTLocationManagerLocationServiceStatus locationStatus;
@property (nonatomic, copy, readwrite) CLLocation *currentLocation;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end
@implementation WTLocationManager

+ (instancetype)sharedInstance
{
    static WTLocationManager *locationManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        locationManager = [[WTLocationManager alloc] init];
    });
    return locationManager;
}

- (void)startLocation
{
    if ([self checkLocationStatus]) {
        self.locationResult = WTLocationManagerLocationResultLocating;
        [self.locationManager startUpdatingLocation];
    } else {
        [self failedLocationWithResultType:WTLocationManagerLocationResultFail statusType:self.locationStatus];
    }
}

- (void)stopLocation
{
    if ([self checkLocationStatus]) {
        [self.locationManager stopUpdatingLocation];
    }
}

- (void)restartLocation
{
    [self stopLocation];
    [self startLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.currentLocation = [manager.location copy];
    NSLog(@"Current location is %@", self.currentLocation);
    [self stopLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    //如果用户还没选择是否允许定位，则不认为是定位失败
    if (self.locationStatus == WTLocationManagerLocationServiceStatusNotDetermined) {
        return;
    }
    
    //如果正在定位中，那么也不会通知到外面
    if (self.locationResult == WTLocationManagerLocationResultLocating) {
        return;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.locationStatus = WTLocationManagerLocationServiceStatusOK;
        [self restartLocation];
    } else {
        if (self.locationStatus != WTLocationManagerLocationServiceStatusNotDetermined) {
            [self failedLocationWithResultType:WTLocationManagerLocationResultDefault statusType:WTLocationManagerLocationServiceStatusNoAuthorization];
        } else {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager startUpdatingLocation];
        }
    }
}
#pragma mark - private methods
- (void)failedLocationWithResultType:(WTLocationManagerLocationResult)result statusType:(WTLocationManagerLocationServiceStatus)status
{
    self.locationResult = result;
    self.locationStatus = status;
}

- (BOOL)checkLocationStatus;
{
    BOOL result = NO;
    BOOL serviceEnable = [self locationServiceEnabled];
    WTLocationManagerLocationServiceStatus authorizationStatus = [self locationServiceStatus];
    if (authorizationStatus == WTLocationManagerLocationServiceStatusOK && serviceEnable) {
        result = YES;
    }else if (authorizationStatus == WTLocationManagerLocationServiceStatusNotDetermined) {
        result = YES;
    }else{
        result = NO;
    }
    
    if (serviceEnable && result) {
        result = YES;
    }else{
        result = NO;
    }
    
    if (result == NO) {
        [self failedLocationWithResultType:WTLocationManagerLocationResultFail statusType:self.locationStatus];
    }
    
    return result;
}

- (BOOL)locationServiceEnabled
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationStatus = WTLocationManagerLocationServiceStatusOK;
        return YES;
    } else {
        self.locationStatus = WTLocationManagerLocationServiceStatusUnknownError;
        return NO;
    }
}

- (WTLocationManagerLocationServiceStatus)locationServiceStatus
{
    self.locationStatus = WTLocationManagerLocationServiceStatusUnknownError;
    BOOL serviceEnable = [CLLocationManager locationServicesEnabled];
    if (serviceEnable) {
        CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
        switch (authorizationStatus) {
            case kCLAuthorizationStatusNotDetermined:
                self.locationStatus = WTLocationManagerLocationServiceStatusNotDetermined;
                break;
                
            case kCLAuthorizationStatusAuthorizedAlways :
            case kCLAuthorizationStatusAuthorizedWhenInUse:
                self.locationStatus = WTLocationManagerLocationServiceStatusOK;
                break;
                
            case kCLAuthorizationStatusDenied:
                self.locationStatus = WTLocationManagerLocationServiceStatusNoAuthorization;
                break;
                
            default:
                break;
        }
    } else {
        self.locationStatus = WTLocationManagerLocationServiceStatusUnAvailable;
    }
    return self.locationStatus;
}

#pragma mark - getters and setters
- (CLLocationManager *)locationManager
{
    if (_locationManager == nil) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    return _locationManager;
}

@end
