//
//  WKMessageHandleRoute.h
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/26.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

#import "SFWebConst.h"


@interface WKMessageHandleRoute : NSObject<WKScriptMessageHandler>
@property (nonatomic, copy) LoginBlock loginBlock;
@end
