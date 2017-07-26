//
//  JSContextResponseProtocol.h
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/26.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <JavaScriptCore/JavaScriptCore.h>

@protocol JSContextResponseProtocol <JSExport>
// 转义js的接口  把oc的方法翻译成js的函数    后者翻译成前者       此格式的带参数形式, 无参数形式无需转义
JSExportAs(login,- (void)loginWithUserName:(NSString *)userName withPwd:(NSString *)pwd);

@optional
// 无参无需转义,直接用方法名调用
-(void)test;

@end
