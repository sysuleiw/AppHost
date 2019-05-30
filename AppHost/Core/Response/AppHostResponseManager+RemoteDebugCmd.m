//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import "AppHostResponseManager+RemoteDebugCmd.h"
#import "AppHostViewController+Scripts.h"
#import "AppHostCommentStore.h"
#import "AppHostEnum.h"
// 保存 weinre 注入脚本的地址，方便在加载其它页面时也能自动注入。
static NSString *kLastWeinreScript = nil;

@implementation AppHostResponseManager (RemoteDebugCmd)
-(void)registerDebugCmdHandlers
{
#ifdef AH_DEBUG
    kWeakSelf(self);
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"eval" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        [(AppHostViewController *)weakself.webviewVC evalExpression:[data objectForKey:@"code"] completion:^(id  _Nonnull result, NSString * _Nonnull error) {
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
            [(AppHostViewController *)weakself.webviewVC fire:@"eval" param:r];
        }];
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"list" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        [(AppHostViewController *)weakself.webviewVC fire:@"list" param:@{@"JSBridge":weakself.respHandlers.allKeys}];
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];

    [self addRemoteDebuggerCallbackRespHandlerWithName:@"weinre" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        // $ weinre --boundHost 10.242.24.59 --httpPort 9090
        BOOL disabled = [[data objectForKey:@"disabled"] boolValue];
        if (disabled) {
            [weakself disableWeinreSupport];
        } else {
            kLastWeinreScript = [data objectForKey:@"url"];
            [weakself enableWeinreSupport];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"timing" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        BOOL mobile = [[data objectForKey:@"mobile"] boolValue];
        if (mobile) {
            [(AppHostViewController *)weakself.webviewVC fire:@"requestToTiming" param:@{}];
        } else {
            [((AppHostViewController *)weakself.webviewVC).webView evaluateJavaScript:@"window.performance.timing.toJSON()" completionHandler:^(NSDictionary *_Nullable r, NSError * _Nullable error) {
                [(AppHostViewController *)weakself.webviewVC fire:@"requestToTiming_on_mac" param:r];
            }];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"clearCookie" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        // 清理 WKWebview 的 Cookie，和 NSHTTPCookieStorage 是独立的
        WKHTTPCookieStore * _Nonnull cookieStorage = [WKWebsiteDataStore defaultDataStore].httpCookieStore;
        [cookieStorage getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull cookies) {
            [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull cookie, NSUInteger idx, BOOL * _Nonnull stop) {
                [cookieStorage deleteCookie:cookie completionHandler:nil];
            }];

            [(AppHostViewController *)weakself.webviewVC fire:@"clearCookieDone" param:@{@"count":@(cookies.count)}];
        }];
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
    [self addRemoteDebuggerCallbackRespHandlerWithName:@"apropos" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback)
    {
        NSString *signature = [data objectForKey:@"signature"];
        NSString *funcName = [@"apropos." stringByAppendingString:signature];
        NSDictionary *doc = [weakself.cmtStore getMethodCommentWithName:signature];
        if (doc) {
            [(AppHostViewController *)weakself.webviewVC fire:funcName param:doc];
        } else {
            NSString *err = [NSString stringWithFormat:@"The method (%@) doesn't exsit!", signature];
            [(AppHostViewController *)weakself.webviewVC fire:funcName param:@{@"error":err}];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
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
    [(AppHostViewController *)self.webviewVC fire:@"weinre.enable" param:@{@"jsURL": kLastWeinreScript}];
}

- (void)disableWeinreSupport
{
    kLastWeinreScript = nil;
    [AppHostViewController removeJavaScriptForKey:@"weinre.js"];
}
@end
