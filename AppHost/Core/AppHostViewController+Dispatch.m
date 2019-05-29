//
//  AppHostViewController+Dispatch.m
//  AppHost
//
//  Created by liang on 2019/3/23.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AppHostViewController+Dispatch.h"
#import "AppHostViewController+Scripts.h"
#import "AppHostViewController+Utils.h"

@implementation AppHostViewController (Dispatch)

#pragma mark - core
- (void)dispatchParsingParameter:(NSDictionary *)contentJSON
{
    // 增加对异常参数的catch
    @try {
        NSString *actionKey = [contentJSON objectForKey:kAHActionKey];
        NSDictionary *paramDict = [contentJSON objectForKey:kAHParamKey];
        NSString *callbackKey = [contentJSON objectForKey:kAHCallbackKey];
        [self callNative:actionKey parameter:paramDict callbackKey:callbackKey];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAppHostInvokeRequestEvent object:contentJSON];
    } @catch (NSException *exception) {
        [self showTextTip:@"H5接口异常"];
        AHLog(@"h5接口解析异常，接口数据：%@", contentJSON);
    } @finally {
    }
}

#pragma mark - public
// 延迟初始化； 短路判断
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict
{
    return [self callNative:action parameter:paramDict callbackKey:nil];
}

#pragma mark - private
- (BOOL)callNative:(NSString *)action parameter:(NSDictionary *)paramDict callbackKey:(NSString *)key
{
    AppHostHandler handler = (AppHostHandler)[self.respHandlers objectForKey:action];
    if (!handler)
    {
        //是NativeToWeb的回调
        handler = (AppHostHandler)[self.nativeToWebCallbackHandlers objectForKey:action];
    }

    if (!handler)
    {
        //是NativeToWeb的回调
        handler = (AppHostHandler)[self.remoteDebuggerHandlers objectForKey:action];
    }

    AppHostResponseCallback calback = NULL;
    if (key.length > 0)
    {
        calback = ^(id responseData){
            if (responseData == nil) {
                responseData = [NSNull null];
            }
            [self fireCallback:key param:responseData];
        };
    }
    else
    {
        calback = ^(id responseData){};
    }
    if (handler == nil) {
        NSString *errMsg = [NSString stringWithFormat:@"action (%@) not supported yet.", action];
        AHLog(@"action (%@) not supported yet.", action);
        [self fire:@"NotSupported" param:@{
                                           @"error": errMsg
                                           }];
        return NO;
    } else {
        //calback已经是堆block无需copy
        handler(paramDict,calback);
        return YES;
    }
}

@end
