//
//  AppHostViewController+NativeResp.m
//  AppHost
//
//  Created by 王磊 on 2019/5/24.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AppHostViewController+NativeResp.h"
#import "AppHostViewController.h"

@import SafariServices;

// 保存 weinre 注入脚本的地址，方便在加载其它页面时也能自动注入。
static NSString *kLastWeinreScript = nil;
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

    [self registerHandler:@"openExternalUrl" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        NSDictionary *paramDict = (NSDictionary *)data;
        NSString *urlTxt = [paramDict objectForKey:@"url"];
        BOOL forceOpenInSafari = [[paramDict objectForKey:@"openInSafari"] boolValue];
        if (forceOpenInSafari) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt] options:@{} completionHandler:nil];
        } else {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlTxt]];
            [self.navigationController presentViewController:safari animated:YES completion:nil];
        }
    }];
    [self registerHandler:@"startNewPage" handler:^(id data, AppHostResponseCallback responseCallback)
    {

        NSDictionary *paramDict = (NSDictionary *)data;
        AppHostViewController *freshOne = [[self.class alloc] init];
        freshOne.url = [paramDict objectForKey:@"url"];
        freshOne.pageTitle = [paramDict objectForKey:@"title"];
        freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];

        freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
        NSString *loadType = [paramDict objectForKey:@"type"];
        if (freshOne.backPageParameter) {
            //额外插入一个页面；
            [self insertShadowView:freshOne.backPageParameter];
        }
        if ([@"replace" isEqualToString:loadType]) {
            NSArray *viewControllers = self.navigationController.viewControllers;

            if (viewControllers.count > 1) {
                // replace的目的就是调整到新的list页面；需要替换旧list和新的回复页面；
                NSMutableArray *newViewControllers = [[viewControllers subarrayWithRange:NSMakeRange(0, [viewControllers count] - 2)] mutableCopy];
                [newViewControllers addObject:freshOne];
                freshOne.hidesBottomBarWhenPushed = YES;
                [self.navigationController setViewControllers:newViewControllers animated:YES];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else {
            [self.navigationController pushViewController:freshOne animated:YES];
        }
    }];

    [self registerAllDebugMethod];
}
- (void)insertShadowView:(NSDictionary *)paramDict
{
    AppHostViewController *freshOne = [[self.class alloc] init];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];
    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
    //
    NSArray *viewControllers = self.navigationController.viewControllers;

    if (viewControllers.count > 0) {
        //在A->B页面里，点击返回到C，然后C返回到A，形成 A-C-B，简化下成A——C；
        NSMutableArray *newViewControllers = [viewControllers mutableCopy];
        [newViewControllers addObject:freshOne];
        freshOne.hidesBottomBarWhenPushed = YES;
        self.navigationController.viewControllers = newViewControllers;
    }
}

- (void)registerAllDebugMethod
{
#ifdef AH_DEBUG
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"eval" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        [self evalExpression:[data objectForKey:@"code"] completion:^(id  _Nonnull result, NSString * _Nonnull error) {
            AHLog(@"%@, error = %@", result, error);
            NSDictionary *r = nil;
            if (result) {
                r = @{
                      @"result":[NSString stringWithFormat:@"%@", result]
                      };
            } else {
                r = @{
                      @"error":[NSString stringWithFormat:@"%@", error]
                      };
            }
            [self fire:@"eval" param:r];
        }];
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"list" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        [self fire:@"list" param:@{@"JSBridge":self.respHandlers.allKeys}];
    }];

    [self addRemoteDebuggerCallbackRespHandlerWithName:@"weinre" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        // $ weinre --boundHost 10.242.24.59 --httpPort 9090
        BOOL disabled = [[data objectForKey:@"disabled"] boolValue];
        if (disabled) {
            [self disableWeinreSupport];
        } else {
            kLastWeinreScript = [data objectForKey:@"url"];
            [self enableWeinreSupport];
        }
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"timing" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        BOOL mobile = [[data objectForKey:@"mobile"] boolValue];
        if (mobile) {
            [self fire:@"requestToTiming" param:@{}];
        } else {
            [self.webView evaluateJavaScript:@"window.performance.timing.toJSON()" completionHandler:^(NSDictionary *_Nullable r, NSError * _Nullable error) {
                [self fire:@"requestToTiming_on_mac" param:r];
            }];
        }
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"clearCookie" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        // 清理 WKWebview 的 Cookie，和 NSHTTPCookieStorage 是独立的
        WKHTTPCookieStore * _Nonnull cookieStorage = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
        [cookieStorage getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull cookie, NSUInteger idx, BOOL * _Nonnull stop) {
                [cookieStorage deleteCookie:cookie completionHandler:nil];
            }];

            [self fire:@"clearCookieDone" param:@{@"count":@(cookies.count)}];
        }];
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"apropos" handler:^(id data, AppHostResponseCallback responseCallback)
    {
//        NSString *signature = [data objectForKey:@"signature"];
//        Class appHostCls = [[AHResponseManager defaultManager] responseForActionSignature:signature];
//        SEL targetMethod = ah_doc_selector(signature);
//        NSString *funcName = [@"apropos." stringByAppendingString:signature];
//        if (appHostCls && [appHostCls respondsToSelector:targetMethod]) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
//            NSDictionary *doc = [appHostCls performSelector:targetMethod withObject:nil];
//#pragma clang diagnostic pop
//
//            [self fire:funcName param:doc];
//        } else {
//            NSString *err = nil;
//            if (appHostCls) {
//                err = [NSString stringWithFormat:@"The doc of method (%@) is not found!", signature];
//            } else {
//                err = [NSString stringWithFormat:@"The method (%@) doesn't exsit!", signature];
//            }
//            [self fire:funcName param:@{@"error":err}];
//        }
    }];

#endif
}
// 注入 weinre 文件
- (void)enableWeinreSupport
{
    if (kLastWeinreScript.length == 0) {
        return;
    }
    [AppHostViewController prepareJavaScript:[NSURL URLWithString:kLastWeinreScript] when:WKUserScriptInjectionTimeAtDocumentEnd key:@"weinre.js"];
    [self fire:@"weinre.enable" param:@{@"jsURL": kLastWeinreScript}];
}

- (void)disableWeinreSupport
{
    kLastWeinreScript = nil;
    [AppHostViewController removeJavaScriptForKey:@"weinre.js"];
}
@end
