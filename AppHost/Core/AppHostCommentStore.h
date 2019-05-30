// 存储自定义注册函数相关注释说明
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppHostCommentStore : NSObject

/**
 * 增加函数说明
 * @return 返回值是自身的block，目的是为了链式调用
 */
- (AppHostCommentStore *(^)(NSString *funcName, NSString *Desc))addMethodDesc;

/**
 * 增加函数参数说明
 * @return 返回值是自身的block，目的是为了链式调用
 */
- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodParam;

/**
 * 增加方法返回值说明
 * @return 返回值是自身的block，目的是为了链式调用
 */
- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodReturnValue;

/**
 * 根据方法名称返回相关注释明细
 * @param 注册的js名称
 * @return 返回值是注释相关信息
 */
- (NSDictionary *)getMethodCommentWithName:(NSString *)funcName;
@end
