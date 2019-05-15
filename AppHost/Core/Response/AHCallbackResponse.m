//
//  AHCallbackResponse.m
//  AppHost
//
//  Created by 王磊 on 2019/5/14.
//  Copyright © 2019 liang. All rights reserved.
//

#import "AHCallbackResponse.h"
#import <objc/runtime.h>
static NSInteger uniqueId = 0;
static NSMutableDictionary *supportActionList = nil;
static NSMutableDictionary *supportCallbackList = nil;
static void selectorImp(id self, SEL _cmd, id arg)
{
    AppHostResponseCallback callback = (AppHostResponseCallback)[supportCallbackList objectForKey: NSStringFromSelector(_cmd)];
    if (callback)
    {
        callback(arg);
    }
    [supportCallbackList removeObjectForKey:NSStringFromSelector(_cmd)];
}

@implementation AHCallbackResponse

+ (NSDictionary<NSString *, NSString *> *)supportActionList
{
    return supportActionList;
}

+ (NSString *)addResponseCallback:(AppHostResponseCallback)callback
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        supportActionList = [NSMutableDictionary new];
        supportCallbackList = [NSMutableDictionary new];
    });
    if (callback)
    {
        NSString *uniqueStr = [NSString stringWithFormat:@"cbk_%zd",uniqueId++];
        NSAssert([supportActionList objectForKey:uniqueStr] == nil, @"native 回调函数重复,不支持多线程");
        [supportActionList setObject:@"1" forKey:[NSString stringWithFormat:@"%@_", uniqueStr]];
        [self addMethodWithBlock:callback andUniqueStr:uniqueStr];
        return uniqueStr;
    }
    return @"";
}

+ (void)addMethodWithBlock:(AppHostResponseCallback)callback andUniqueStr:(NSString *)uniqueStr
{
    NSString *selName = [NSString stringWithFormat:@"%@:", uniqueStr];
    SEL sel = NSSelectorFromString(selName);
    class_addMethod(self, sel, (IMP)selectorImp, "v@:@");
    [supportCallbackList setObject:[callback copy] forKey:NSStringFromSelector(sel)];
}


@end
