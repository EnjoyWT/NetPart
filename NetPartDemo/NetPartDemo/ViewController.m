//
//  ViewController.m
//  NetPartDemo
//
//  Created by lianzhu on 16/10/10.
//  Copyright © 2016年 WT. All rights reserved.
//

#import "ViewController.h"
#import "FirstReformer.h"
@interface ViewController ()
@property (nonatomic,strong) RequestFirst *firstRequest;
@property (nonatomic,strong) FirstReformer *firstReformer;
@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
  //  [self.firstRequest loadDataWithParams:nil];

    //使用 block
    __weak typeof(self) weakSelf = self;
    [self.firstRequest loadDataWithParams:@{@"key":@"value"} withCompleteBlock:^(WTURLResponse *response, WTAPIManagerErrorType error) {
        
        if (error!=WTAPIManagerErrorTypeSuccess) {
            NSLog(@"请求出错错误类型%lu",(unsigned long)error);
            return ;
        }
        __strong typeof (weakSelf) strongSelf = weakSelf;
        id data = [strongSelf.firstRequest fetchDataWithReformer:self.firstReformer];
        
        NSLog(@" %@",data);
    }];


}
#pragma mark- WTAPIManagerCallBackDelegate
- (void)managerCallAPIDidSuccess:(APIBaseManager *)manager {
    
    if (manager==self.firstRequest) {
        
       id data = [manager fetchDataWithReformer:self.firstReformer];
        
        NSLog(@"firstRequest Reviece data %@",data);
    }
}
- (void)managerCallAPIDidFailed:(APIBaseManager *)manager {
  
}
- (RequestFirst *)firstRequest {
    
    if (_firstRequest == nil) {
        _firstRequest = [[RequestFirst alloc]init];
        _firstRequest.delegate = self;
    }
    
    return _firstRequest;
}
- (FirstReformer *)firstReformer {
    if (_firstRequest==nil) {
        _firstReformer = [[FirstReformer alloc]init];
    }
    return _firstReformer;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
@end
