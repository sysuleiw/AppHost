//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppHostEnum.h"
#import "AppHostCommentStore.h"
#import "AppHostViewController.h"

@interface AppHostResponseManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, weak) id<WKNavigationDelegate> webviewVC;
/**
 * 自定义js方法列表
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *respHandlers;

/**
 * native 调用页面js的回调集合
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *nativeToWebCallbackHandlers;

/**
 * 远程调试命令响应函数
 */
@property (nonatomic, strong, readonly) NSMutableDictionary *remoteDebuggerHandlers;



- (void)addNativeCallbackRespHandlerWithName:(NSString *)handlerName handler:(AppHostHandler)callback;
- (void)removeNativeCallbackHandler:(NSString *)handlerName;

- (void)addRemoteDebuggerCallbackRespHandlerWithName:(NSString *)handlerName handler:(AppHostHandler)callback;
- (void)removeRemoteDebuggerCallbackHandler:(NSString *)handlerName;


/****理论上SDK之外关于JSBridge只需要关注一下几个方法即可****/
- (void)registerHandler:(NSString *)handlerName handler:(AppHostHandler)handler;
- (void)removeHandler:(NSString *)handlerName;
- (void)fire:(NSString *)actionName param:(NSDictionary *)paramDict callback:(AppHostResponseCallback)callback;
/**
 * 存放函数注释
 */
@property (nonatomic, strong, readonly) AppHostCommentStore *cmtStore;
/****理论上SDK之外关于JSBridge只需要关注一下几个方法即可****/
@end
