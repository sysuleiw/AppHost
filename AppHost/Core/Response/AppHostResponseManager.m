//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import <CloudKit/CloudKit.h>
#import "AppHostResponseManager.h"
#import "AppHostResponseManager+BuildInResponse.h"
#import "AppHostResponseManager+RemoteDebugCmd.h"
#import "AppHostViewController+Scripts.h"

@implementation AppHostResponseManager

+ (instancetype)sharedManager
{
    static AppHostResponseManager *g_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        g_instance = [AppHostResponseManager new];
    });
    return g_instance;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _respHandlers = [NSMutableDictionary new];
        _remoteDebuggerHandlers = [NSMutableDictionary new];
        _nativeToWebCallbackHandlers = [NSMutableDictionary new];
        _cmtStore = [AppHostCommentStore new];
        [self registerRespHandlers];
        [self registerDebugCmdHandlers];
    }
    return self;
}
#pragma mark - respHandlers
- (void)registerHandler:(NSString *)handlerName handler:(AppHostHandler)handler
{
    if (handlerName.length > 0 && handler)
    {
        //匿名block需要copy
        _respHandlers[handlerName] = [handler copy];
    }
    else
    {
        NSAssert(NO, @"注册信息无效!");
    }
}

- (void)removeHandler:(NSString *)handlerName
{
    if (handlerName.length > 0)
    {
        [_respHandlers removeObjectForKey:handlerName];
    }
    else
    {
        NSAssert(NO, @"信息无效!");
    }
}

- (void)addNativeCallbackRespHandlerWithName:(NSString *)handlerName handler:(AppHostHandler)callback
{
    if (handlerName.length > 0 && callback)
    {
        //匿名block需要copy
        _nativeToWebCallbackHandlers[handlerName] = [callback copy];
    }
    else
    {
        NSAssert(NO, @"注册信息无效!");
    }
}
- (void)removeNativeCallbackHandler:(NSString *)handlerName
{
    if (handlerName.length > 0)
    {
        [_nativeToWebCallbackHandlers removeObjectForKey:handlerName];
    }
    else
    {
        NSAssert(NO, @"信息无效!");
    }
}

- (void)addRemoteDebuggerCallbackRespHandlerWithName:(NSString *)handlerName handler:(AppHostHandler)callback
{
    if (handlerName.length > 0 && callback)
    {
        //匿名block需要copy
        _remoteDebuggerHandlers[handlerName] = [callback copy];
    }
    else
    {
        NSAssert(NO, @"注册信息无效!");
    }
}
- (void)removeRemoteDebuggerCallbackHandler:(NSString *)handlerName
{
    if (handlerName.length > 0)
    {
        [_remoteDebuggerHandlers removeObjectForKey:handlerName];
    }
    else
    {
        NSAssert(NO, @"信息无效!");
    }
}

+ (BOOL)accessInstanceVariablesDirectly
{
    return NO;
}

- (void)fire:(NSString *)actionName param:(NSDictionary *)paramDict callback:(AppHostResponseCallback)callback;
{
    NSAssert(self.webviewVC, @"一定要在初始化webview之后方可调用注册方法");
    [(AppHostViewController *)self.webviewVC fire:actionName param:paramDict callback:callback];
}
@end