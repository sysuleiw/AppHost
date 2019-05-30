//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppHostCommentStore.h"
#import "AppHostViewController.h"

#define kResponseResultOK @{@"res":@"1"}
#define kResponseResultErr @{@"res":@"0"}

//在注册的函数回调里面需要调用下面宏完成最终同步&异步返回
#define kAsyncCallbackAndReturnSyncResult(dic)\
({\
responseCallback(dic);\
return dic;\
})
typedef void (^AppHostResponseCallback)(id responseData);
typedef NSDictionary* (^AppHostHandler)(id data, AppHostResponseCallback responseCallback);

@interface AppHostResponseManager : NSObject

+ (instancetype)sharedManager;

/**
 * WebviewController
 */
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
