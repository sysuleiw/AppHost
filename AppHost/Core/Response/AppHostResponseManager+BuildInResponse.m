//
// Created by 王磊 on 2019/5/29.
// Copyright (c) 2019 liang. All rights reserved.
//

#import "AppHostResponseManager+BuildInResponse.h"
#import <UIKit/UIKit.h>
#import "AppHostEnum.h"
@import SafariServices;

@implementation AppHostResponseManager (BuildInResponse)

-(void)registerRespHandlers
{
    kWeakSelf(self);
    self.cmtStore.addMethodDesc(@"openExternalUrl",@"王磊测试方法说明")
                 .addMethodParam(@"url",@"要打开的url")
                 .addMethodReturnValue(@"nothing",@"没有参数");

    [self registerHandler:@"openExternalUrl" handler:^NSDictionary *(id data, AppHostResponseCallback responseCallback) {
        NSDictionary *paramDict = (NSDictionary *)data;
        NSString *urlTxt = [paramDict objectForKey:@"url"];
        BOOL forceOpenInSafari = [[paramDict objectForKey:@"openInSafari"] boolValue];
        if (forceOpenInSafari) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt] options:@{} completionHandler:nil];
        } else {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlTxt]];
            [((AppHostViewController *)weakself.webviewVC).navigationController presentViewController:safari animated:YES completion:nil];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
    [self registerHandler:@"openExternalUrl" handler:^(id data, AppHostResponseCallback responseCallback)
    {
        NSDictionary *paramDict = (NSDictionary *)data;
        NSString *urlTxt = [paramDict objectForKey:@"url"];
        BOOL forceOpenInSafari = [[paramDict objectForKey:@"openInSafari"] boolValue];
        if (forceOpenInSafari) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlTxt] options:@{} completionHandler:nil];
        } else {
            SFSafariViewController *safari = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:urlTxt]];
            [((AppHostViewController *)weakself.webviewVC).navigationController presentViewController:safari animated:YES completion:nil];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];

    [self registerHandler:@"startNewPage" handler:^(id data, AppHostResponseCallback responseCallback)
    {

        NSDictionary *paramDict = (NSDictionary *)data;
        AppHostViewController *freshOne = [[self.class alloc] init];
        freshOne.url = [paramDict objectForKey:@"url"];
        freshOne.pageTitle = [paramDict objectForKey:@"title"];
        freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];

        freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
        NSString *loadType = [paramDict objectForKey:@"type"];
        if (freshOne.backPageParameter) {
            //额外插入一个页面；
            [weakself insertShadowView:freshOne.backPageParameter];
        }
        if ([@"replace" isEqualToString:loadType]) {
            NSArray *viewControllers =  ((AppHostViewController *)self.webviewVC).navigationController.viewControllers;

            if (viewControllers.count > 1) {
                // replace的目的就是调整到新的list页面；需要替换旧list和新的回复页面；
                NSMutableArray *newViewControllers = [[viewControllers subarrayWithRange:NSMakeRange(0, [viewControllers count] - 2)] mutableCopy];
                [newViewControllers addObject:freshOne];
                freshOne.hidesBottomBarWhenPushed = YES;
                [((AppHostViewController *)weakself.webviewVC).navigationController setViewControllers:newViewControllers animated:YES];
            } else {
                [((AppHostViewController *)weakself.webviewVC).navigationController popViewControllerAnimated:YES];
            }
        } else {
            [((AppHostViewController *)weakself.webviewVC).navigationController pushViewController:freshOne animated:YES];
        }
        kAsyncCallbackAndReturnSyncResult(kResponseResultOK);
    }];
}
- (void)insertShadowView:(NSDictionary *)paramDict
{
    AppHostViewController *freshOne = [[self.class alloc] init];
    freshOne.url = [paramDict objectForKey:@"url"];
    freshOne.pageTitle = [paramDict objectForKey:@"title"];
    freshOne.rightActionBarTitle = [paramDict objectForKey:@"actionTitle"];
    freshOne.backPageParameter = [paramDict objectForKey:@"backPageParameter"];
    //
    NSArray *viewControllers = ((AppHostViewController *)self.webviewVC).navigationController.viewControllers;

    if (viewControllers.count > 0) {
        //在A->B页面里，点击返回到C，然后C返回到A，形成 A-C-B，简化下成A——C；
        NSMutableArray *newViewControllers = [viewControllers mutableCopy];
        [newViewControllers addObject:freshOne];
        freshOne.hidesBottomBarWhenPushed = YES;
        ((AppHostViewController *)self.webviewVC).navigationController.viewControllers = newViewControllers;
    }
}
@end
