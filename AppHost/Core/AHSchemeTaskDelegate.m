//
//  AHSchemeTaskResponse.m
//  AppHost
//
//  Created by liang on 2018/12/29.
//  Copyright © 2018 liang. All rights reserved.
//

#import "AHSchemeTaskDelegate.h"
#import "AppHostEnum.h"
@interface AHSchemeTaskDelegate()

/**
 保存自定义的
 handles
 */
@property (nonatomic, strong) NSMutableDictionary *customHandles;

@end

@implementation AHSchemeTaskDelegate

- (instancetype)init
{
    if (self = [super init]) {
        self.customHandles = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

- (void)dealloc
{
    AHLog(@"AHSchemeTaskDelegate dealloc");
}

- (void)addHandler:(bSchemeTaskHandler)handler forDomain:(NSString */* js */)domain;
{
    if (domain.length == 0 || handler == nil) {
        AHLog(@"domain or handle is null");
        return;
    }
    
    [self.customHandles setObject:handler forKey:domain];
}

#pragma mark - url task

- (void)webView:(WKWebView *)webView startURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask
{
    NSURLRequest *request = urlSchemeTask.request;
    AHLog(@"URL = %@, allKey = %@", request.URL, [request.allHTTPHeaderFields allKeys]);
    NSData *data;
    NSString *host = [request.URL host];
    
    if (host.length == 0) {
        return;
    }
    
    NSString *mime = nil;
    bSchemeTaskHandler handle = [self.customHandles objectForKey:host];
    if (handle) {
        data = handle(webView, urlSchemeTask, &mime);
    }
    
    if (data == nil) {
        NSError *err = [[NSError alloc] initWithDomain:@"自定义的资源无法解析" code:-4003 userInfo:nil];
        [urlSchemeTask didFailWithError:err];
    } else {
        NSURLResponse *response = [[NSURLResponse alloc] initWithURL:urlSchemeTask.request.URL MIMEType:mime?:@"text/plain" expectedContentLength:data.length textEncodingName:nil];
        [urlSchemeTask didReceiveResponse:response];
        [urlSchemeTask didReceiveData:data];
        [urlSchemeTask didFinish];
    }
}

- (void)webView:(nonnull WKWebView *)webView stopURLSchemeTask:(nonnull id<WKURLSchemeTask>)urlSchemeTask {
    //
    AHLog(@"%@", NSStringFromSelector(_cmd));
}


@end
