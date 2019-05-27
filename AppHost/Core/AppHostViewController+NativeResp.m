//
//  AppHostViewController+NativeResp.m
//  AppHost
//
//  Created by 王磊 on 2019/5/24.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AppHostViewController+NativeResp.h"
#import "AppHostViewController.h"

@implementation AppHostViewController (NativeResp)

ah_doc_begin(getDataWithParamCallback, "测试api注册")
ah_doc_param(text, "text哈哈哈")
ah_doc_code(window.appHost.invoke("getDataWithParamCallback",{"data":"测试参数"},function(data){}))
ah_doc_code_expect("在屏幕上出现 '请稍等...'，多次调用此接口，会出现多个")
ah_doc_end
-(void)registerAllRespHandlers
{
    //1.注意这个回调里调用self需要weak,无论是sdk内部还是sdk外部
    //2.外界注册JS方法需要通过AppHostViewController的实例调用才行
    //3.注释如何生成是个问题？？？？，看来也只能单独建立注册方法把registerHandler语句包含在内，
    //4.可能更好的方式是去掉_$这一坨，只用action寻找，supportActionList的参数是支持的js方法名字，值是selector更合理，不要让页端的action和native的函数直接绑定
    [self registerHandler:@"getDataWithParamCallback" handler:^(id data, AppHostResponseCallback responseCallback) {
        NSString *fromJS = [data objectForKey:@"data"];
        responseCallback(@{@"data":@"fromNativeData"});
    }];
}
@end
