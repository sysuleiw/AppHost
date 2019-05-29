//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AppHostCommentStore : NSObject

- (AppHostCommentStore *(^)(NSString *funcName, NSString *Desc))addMethodDesc;
- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodParam;
- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodReturnValue;
- (NSDictionary *)getFuncCommentWithName:(NSString *)funcName;
@end
