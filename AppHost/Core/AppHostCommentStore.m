//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import "AppHostCommentStore.h"

@interface AppHostCommentStore()
@property (nonatomic, strong) NSMutableDictionary *store;
@property (nonatomic, copy) NSString *currentFuncName;
@end
@implementation AppHostCommentStore
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _store = [NSMutableDictionary new];
    }
    return  self;
}
- (NSDictionary *)getMethodCommentWithName:(NSString *)funcName
{
    return [self.store objectForKey:funcName];
}
- (AppHostCommentStore *(^)(NSString *funcName, NSString *Desc))addMethodDesc
{
    return ^id(NSString *funcName, NSString *Desc){
        NSAssert(Desc&&funcName, @"参数不可为空");
        self.currentFuncName = funcName;
        NSMutableDictionary *mDict = [NSMutableDictionary new];
        [mDict setObject:Desc forKey:@"discuss"];
        [mDict setObject:funcName forKey:@"name"];

        NSMutableArray *mAry = [NSMutableArray new];
        [mDict setObject:mAry forKey:@"param"];


        NSMutableArray *mAry2 = [NSMutableArray new];
        [mDict setObject:mAry2 forKey:@"return"];
        [self.store setObject:mDict forKey:funcName];
        return self;
    };
}

- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodParam
{
    return ^id(NSString *param, NSString *Desc){
        NSAssert(Desc&&param, @"参数不可为空");
        NSMutableArray *mAry = [[self.store objectForKey:self.currentFuncName] objectForKey:@"param"];
        [mAry addObject:@{param: Desc}];
        return self;
    };
}

- (AppHostCommentStore *(^)(NSString *param, NSString *Desc))addMethodReturnValue
{
    return ^id(NSString *param, NSString *Desc){
        NSAssert(Desc&&param, @"参数不可为空");
        NSMutableArray *mAry = [[self.store objectForKey:self.currentFuncName] objectForKey:@"return"];
        [mAry addObject:@{param: Desc}];
        return self;
    };
}
@end
