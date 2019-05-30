//
//  AppHostEnum.h
//  AppHost
//
//  Created by liang on 2018/12/28.
//  Copyright © 2018 liang. All rights reserved.
//

#ifndef AppHostEnum_h
#define AppHostEnum_h

// 创建一个超级厉害的宏，https://www.jianshu.com/p/cbb6b71d925d
// 在 debug 模式下打印带前缀的日志，非 debug 模式下，不输出。
#if !defined(AHLog)
#ifdef AH_DEBUG
#define AHLog(format, ...)  do {\
(NSLog)((@"[AppHost] " format), ##__VA_ARGS__); \
} while (0)
#else
#define AHLog(format, ...)
#endif
#endif

//弱引用/强引用
#define kWeakSelf(type)   __weak typeof(type) weak##type = type;
#define kStrongSelf(type) __strong typeof(type) type = weak##type;
//获取设备的物理高度
#define AH_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
//获取设备的物理宽度
#define AH_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define AH_IS_SCREEN_HEIGHT_X (AH_SCREEN_HEIGHT == 812.0f || AH_SCREEN_HEIGHT == 896.0f)

#define AH_PURE_NAVBAR_HEIGHT 44 //单纯的导航的高度
#define AH_NAVIGATION_BAR_HEIGHT (AH_PURE_NAVBAR_HEIGHT + [[UIApplication sharedApplication] statusBarFrame].size.height) //顶部（导航+状态栏）的高度

#define AHColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

// 定义多行文字
#define ah_ml(str) @#str

#endif /* AppHostEnum_h */




#define NOW_TIME [[NSDate date] timeIntervalSince1970] * 1000

// 是否打开 debug server 的日志。
static BOOL kGCDWebServer_logging_enabled = NO;

// core
static NSString * _Nonnull kAHActionKey = @"action";
static NSString * _Nonnull kAHParamKey = @"param";
static NSString * _Nonnull kAHCallbackKey = @"callbackKey";
static NSString * _Nonnull kNativeToWebCallbackKey = @"cbk_";
