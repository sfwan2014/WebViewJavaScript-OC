//
//  JSContextResponseObj.m
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/26.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import "JSContextResponseObj.h"

@implementation JSContextResponseObj
- (void)loginWithUserName:(NSString *)userName withPwd:(NSString *)pwd{
    if (self.loginBlock) {
        self.loginBlock(userName, pwd);
    }
}
@end
