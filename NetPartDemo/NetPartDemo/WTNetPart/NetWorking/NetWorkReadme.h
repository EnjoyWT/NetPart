//
//  NetWorkReadme.h
//  NetWorkPart
//
//  Created by lianzhu on 16/6/14.
//  Copyright © 2016年 EnjoyWT. All rights reserved.
//

#ifndef NetWorkReadme_h
#define NetWorkReadme_h
/* 这里介绍一下Net框架的使用方法:
 * 该网络层依赖于AFNet 3.0
 *---$$$$$$$$$$$$$$$$$$$$$$$$$---- Warning ---$$$$$$$$$$$$$$
 *--->写在最前****请求子类请求对象必须被对象(一般是控制器)持有,否则请求或自动取消.报错代码 -999.
 
 *
 *  1.api请求生成:所有api请求必须是APIBaseManger的子类,
 *
 *           1.1 必须实现的协议有: WTAPIManagerChild,
 *           1.2 可选协议:        WTAPIManagerValidator //请求参数验证协议
                                 WTAPIManagerInterceptor//求求拦截协议,可在该子类中实现,也可以在外部实现,即:内部拦截,外部拦截.
 *
 *  2.服务器的配置:
 *
        2.1 配置的生成:每个api都要配置相对应的Services,必须是WTService的子类,并实现WTServiceProtocal协议
 *      /**************************2.2,2.3请忽略****配置策略已更改,只需要在请求的子类中返回相应服务器的类即可.
        2.2 配置的分配: WTServiceFactory负责对应api的service的分配工作.
 *
        2.3 配置的分类: 每个service都有一个serviceType的属性,用来匹配对应的api(api的类中有对应的serviceType方法).
 *
               2.3.1:配置标识符设置处:
 *
                     1.需要每个service对应的const string 在 WTServiceFactory.m 顶部的 service name list 处定义,文件位置--> Net/Service/
                     2.WTNetworkingConfiguration.h中需要 extern 一下.文件路径--> Net/NetworkCustom/WTNetworkingConfiguration
 *
            **************************************************************/
 /*   3.tips:请求回调返回的数据是原生数据(NSArray,NSDic),当需要特定格式时,通过实现WTAPIManagerDataReformer协议即可,转化的逻辑在WTAPIManagerDataReformer实现协议的对象中实现.
   
 *  4.数据持久化.采用的第三方库 MagicalRecord,保存数据是注意采用的是哪个context .
 *
 
 */

#endif /* NetWorkReadme_h */
