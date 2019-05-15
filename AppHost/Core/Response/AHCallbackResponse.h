//
//  AHCallbackResponse.h
//  AppHost
//
//  Created by 王磊 on 2019/5/14.
//  Copyright © 2019 liang. All rights reserved.
//

#import <AppHost/AppHost.h>

NS_ASSUME_NONNULL_BEGIN

@interface AHCallbackResponse : AppHostResponse

/**
 * 缓存callback
 * 返回callback的唯一标识
 */
+ (NSString *)addResponseCallback:(AppHostResponseCallback)callback;
@end

NS_ASSUME_NONNULL_END
