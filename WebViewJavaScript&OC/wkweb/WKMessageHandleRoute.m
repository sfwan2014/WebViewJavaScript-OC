//
//  WKMessageHandleRoute.m
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/26.
//  Copyright © 2017年 DBC. All rights reserved.
//
/*
 
 appObj.jsGetAppToken=function(){
 window.webkit.messageHandlers.order.postMessage('{"type":"getToken"}')
 };
 
 appObj.createOrder=function(a){
 window.webkit.messageHandlers.order.postMessage('{"type":"createOrder", "orderId":'+a+'}')
 };

 appObj.login=function(userName, pwd){
 window.webkit.messageHandlers.user.postMessage('{\"type\":\"login\",\"username\":\"'+userName+'\", \"password\":\"'+pwd+'\"}')
 };
 
 user 是根据
 [userContentController addScriptMessageHandler:messageHandle name:@"user"];
 的user 变化的
 message.name 也是相关联的
 */
#import "WKMessageHandleRoute.h"

@implementation WKMessageHandleRoute
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if ([message.name isEqualToString:@"user"]) {
        
        NSString *body = message.body;
        
        NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *result = [self objectFromData:data];
        NSString *action = [result objectForKey:@"type"];
        if ([action isEqualToString:@"login"]) {
            NSString *userName = result[@"username"];
            NSString *pwd = result[@"password"];
            if (self.loginBlock) {
                self.loginBlock(userName, pwd);
            }
        }
        
        
    }
}


- (id)objectFromData:(NSData *)jsonData{
    
    NSError *error = nil;
    
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                     
                                                    options:NSJSONReadingAllowFragments
                     
                                                      error:&error];
    
    if (jsonObject != nil && error == nil) {
        
        return jsonObject;
        
    } else {
        
        // 解析错误
        
        return nil;
        
    }
    
}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
}

@end
