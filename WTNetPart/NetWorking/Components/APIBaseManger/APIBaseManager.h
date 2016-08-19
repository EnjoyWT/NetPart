//
//  APIBaseManager.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/12.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WTURLResponse.h"

// 在调用成功之后的params字典里面，用这个key可以取出requestID
static NSString * const WTAPIBaseManagerRequestID = @"kCTAPIBaseManagerRequestID";
//api回调
@class APIBaseManager;
/*************************************************************************************************/
/*                               CTAPIManagerCallBackDelegate                                          */
/*************************************************************************************************/
//api回调
@protocol WTAPIManagerCallBackDelegate <NSObject>
@required
- (void)managerCallAPIDidSuccess:(APIBaseManager *)manager;
- (void)managerCallAPIDidFailed:(APIBaseManager *)manager;

@end



/*************************************************************************************************/
/*                               APIManagerDataReformer                                          */
/*************************************************************************************************/
/**
 *  数据转换协议
 */
@protocol WTAPIManagerDataReformer <NSObject>
/*
 比如同样的一个获取电话号码的逻辑，二手房，新房，租房调用的API不同，所以它们的manager和data都会不同。
 即便如此，同一类业务逻辑（都是获取电话号码）还是应该写到一个reformer里面去的。这样后人定位业务逻辑相关代码的时候就非常方便了。
 
 代码样例：
 - (id)manager:(CTAPIBaseManager *)manager reformData:(NSDictionary *)data
 {
 if ([manager isKindOfClass:[xinfangManager class]]) {
 return [self xinfangPhoneNumberWithData:data];      //这是调用了派生后reformer子类自己实现的函数，别忘了reformer自己也是一个对象呀。
 //reformer也可以有自己的属性，当进行业务逻辑需要一些外部的辅助数据的时候，
 //外部使用者可以在使用reformer之前给reformer设置好属性，使得进行业务逻辑时，
 //reformer能够用得上必需的辅助数据。
 }
 
 if ([manager isKindOfClass:[zufangManager class]]) {
 return [self zufangPhoneNumberWithData:data];
 }
 
 if ([manager isKindOfClass:[ershoufangManager class]]) {
 return [self ershoufangPhoneNumberWithData:data];
 }
 }
 */
@required
- (id)manager:(APIBaseManager *)manager reformData:(id)data;
@end
/*************************************************************************************************/
/*                               CTAPIManagerValidator                                          */
/*************************************************************************************************/
@protocol WTAPIManagerValidator <NSObject>
@required
/*
 所有的callback数据都应该在这个函数里面进行检查，事实上，到了回调delegate的函数里面是不需要再额外验证返回数据是否为空的。
 因为判断逻辑都在这里做掉了。
 而且本来判断返回数据是否正确的逻辑就应该交给manager去做，不要放到回调到controller的delegate方法里面去做。
 */
- (BOOL)manager:(APIBaseManager *)manager isCorrectWithCallBackData:(NSDictionary *)data;
- (BOOL)manager:(APIBaseManager *)manager isCorrectWithParamsData:(NSDictionary *)data;
@end




/*************************************************************************************************/
/*                               APIManagerParamSource                                          */
/*************************************************************************************************/
/**
 *  请求参数配置的协议
 */
@protocol WTAPIManagerParamSource <NSObject>
@required
- (NSDictionary *)paramsForApi:(APIBaseManager *)manager;
@end

/*
 当产品要求返回数据不正确或者为空的时候显示一套UI，请求超时和网络不通的时候显示另一套UI时，使用这个enum来决定使用哪种UI。（安居客PAD就有这样的需求，sigh～）
 你不应该在回调数据验证函数里面设置这些值，事实上，在任何派生的子类里面你都不应该自己设置manager的这个状态，baseManager已经帮你搞定了。
 强行修改manager的这个状态有可能会造成程序流程的改变，容易造成混乱。
 */
typedef NS_ENUM (NSUInteger, WTAPIManagerErrorType){
    WTAPIManagerErrorTypeDefault,       //没有产生过API请求，这个是manager的默认状态。
    WTAPIManagerErrorTypeSuccess,       //API请求成功且返回数据正确，此时manager的数据是可以直接拿来使用的。
    WTAPIManagerErrorTypeNoContent,     //API请求成功但返回数据不正确。如果回调数据验证函数返回值为NO，manager的状态就会是这个。
    WTAPIManagerErrorTypeParamsError,   //参数错误，此时manager不会调用API，因为参数验证是在调用API之前做的。
    WTAPIManagerErrorTypeTimeout,       //请求超时。CTAPIProxy设置的是20秒超时，具体超时时间的设置请自己去看CTAPIProxy的相关代码。
    WTAPIManagerErrorTypeNoNetWork      //网络不通。在调用API之前会判断一下当前网络是否通畅，这个也是在调用API之前验证的，和上面超时的状态是有区别的。
};
//请求类型
typedef NS_ENUM (NSUInteger, WTAPIManagerRequestType){
    WTAPIManagerRequestTypeGet,
    WTAPIManagerRequestTypePost,
    WTAPIManagerRequestTypePut,
    WTAPIManagerRequestTypeDelete
};



/*************************************************************************************************/
/*                               WTAPIManagerChild                                          */
/*************************************************************************************************/

/**
 *  APIBaseManager的派生类必须符合这些protocal
 */
@protocol WTAPIManagerChild <NSObject>

@required
- (NSString *)relativeURL;
- (Class)serviceType;
- (WTAPIManagerRequestType)requestType;
- (BOOL)shouldCache;

// used for pagable API Managers mainly
@optional
/**
 *
 *   是否从本地请求数据
 *  @return YES/NO .  默认是NO,如果为YES 则子类必须重载loadDataFromNative方法
 */
- (BOOL)shouldLoadFromNative;

/**
 *  从本地加载数据的方法
 *
 *  @return 返回YES表示本地有数据,回调请求成功的代理方法不再继续进行网络请求(),反之则 NO
 */
- (BOOL)loadDataFromNative;

/**
 *  通过方法直接提供的请求的参数,可以不设定数据源代理
 *
 *  @param params 请求的参数配置
 *
 *  @return 请求的requestID
 *   如果调用此方法测必须重写shouldLoadFromNative返会为YES
 */
- (NSInteger)loadDataWithParams:(NSDictionary *)params;

/**
 * 清除当前网络api的缓存
 *
 */
- (void)cleanData;
/**
 *  对请求的参数进行再次配置
 *
 *  @param params 请求的参数
 *
 *  @return 重新配置后的参数
 */
- (NSDictionary *)reformParams:(NSDictionary *)params;

@end

/*************************************************************************************************/
/*                                    APIManagerInterceptor                                    */
/*************************************************************************************************/
/*
 APIBaseManager的派生类必须符合这些protocal,过程的拦截,但是我并没有很好的理解这个协议的益处
 */
@protocol WTAPIManagerInterceptor <NSObject>

@optional
- (BOOL)manager:(APIBaseManager *)manager beforePerformSuccessWithResponse:(WTURLResponse *)response;
- (void)manager:(APIBaseManager *)manager afterPerformSuccessWithResponse:(WTURLResponse *)response;

- (BOOL)manager:(APIBaseManager *)manager beforePerformFailWithResponse:(WTURLResponse *)response;
- (void)manager:(APIBaseManager *)manager afterPerformFailWithResponse:(WTURLResponse *)response;

- (BOOL)manager:(APIBaseManager *)manager shouldCallAPIWithParams:(NSDictionary *)params;
- (void)manager:(APIBaseManager *)manager afterCallingAPIWithParams:(NSDictionary *)params;

@end



/*************************************************************************************************/
/*                                       CTAPIBaseManager                                        */
/*************************************************************************************************/


@interface APIBaseManager : NSObject
@property (nonatomic, weak) id<WTAPIManagerCallBackDelegate> delegate;
@property (nonatomic, weak) id<WTAPIManagerParamSource> paramSource;
@property (nonatomic, weak) id<WTAPIManagerValidator> validator;
@property (nonatomic, weak) id<WTAPIManagerInterceptor> interceptor;
@property (nonatomic, weak) NSObject<WTAPIManagerChild> *child; //里面会调用到NSObject的方法，所以这里不用id

@property (nonatomic, strong, readwrite) id fetchedRawData;
/*
 baseManager是不会去设置errorMessage的，派生的子类manager可能需要给controller提供错误信息。所以为了统一外部调用的入口，设置了这个变量。
 派生的子类需要通过extension来在保证errorMessage在对外只读的情况下使派生的manager子类对errorMessage具有写权限。
 */
@property (nonatomic, copy, readonly) NSString *errorMessage;
@property (nonatomic, readonly) WTAPIManagerErrorType errorType;
@property (nonatomic, strong) WTURLResponse *response;

@property (nonatomic, assign, readonly) BOOL isReachable;
@property (nonatomic, assign, readonly) BOOL isLoading;
@property (nonatomic, assign,readonly) BOOL isNativeDataEmpty;

- (id)fetchDataWithReformer:(id<WTAPIManagerDataReformer>)reformer;

//尽量使用loadData这个方法,这个方法会通过param source来获得参数，这使得参数的生成逻辑位于controller中的固定位置
- (NSInteger)loadData;
//这个方法原作者并不推荐,但是我还是想用,以后弄懂原因再修改 ^_^
- (NSInteger)loadDataWithParams:(NSDictionary *)params;
- (void)cancelAllRequests;
- (void)cancelRequestWithRequestId:(NSInteger)requestID;

// 拦截器方法，继承之后需要调用一下super
- (BOOL)beforePerformSuccessWithResponse:(WTURLResponse *)response;
- (void)afterPerformSuccessWithResponse:(WTURLResponse *)response;

- (BOOL)beforePerformFailWithResponse:(WTURLResponse *)response;
- (void)afterPerformFailWithResponse:(WTURLResponse *)response;

- (BOOL)shouldCallAPIWithParams:(NSDictionary *)params;
- (void)afterCallingAPIWithParams:(NSDictionary *)params;

/*
 用于给继承的类做重载，在调用API之前额外添加一些参数,但不应该在这个函数里面修改已有的参数。
 子类中覆盖这个函数的时候就不需要调用[super reformParams:params]了
 CTAPIBaseManager会先调用这个函数，然后才会调用到 id<CTAPIManagerValidator> 中的 manager:isCorrectWithParamsData:
 所以这里返回的参数字典还是会被后面的验证函数去验证的。
 
 假设同一个翻页Manager，ManagerA的paramSource提供page_size=15参数，ManagerB的paramSource提供page_size=2参数
 如果在这个函数里面将page_size改成10，那么最终调用API的时候，page_size就变成10了。然而外面却觉察不到这一点，因此这个函数要慎用。
 
 这个函数的适用场景：
 当两类数据走的是同一个API时，为了避免不必要的判断，我们将这一个API当作两个API来处理。
 那么在传递参数要求不同的返回时，可以在这里给返回参数指定类型。
 
 具体请参考AJKHDXFLoupanCategoryRecommendSamePriceAPIManager和AJKHDXFLoupanCategoryRecommendSameAreaAPIManager
 
 */
- (NSDictionary *)reformParams:(NSDictionary *)params;
- (void)cleanData;
- (BOOL)shouldCache;

- (void)successedOnCallingAPI:(WTURLResponse *)response;
- (void)failedOnCallingAPI:(WTURLResponse *)response withErrorType:(WTAPIManagerErrorType)errorType;

@end
