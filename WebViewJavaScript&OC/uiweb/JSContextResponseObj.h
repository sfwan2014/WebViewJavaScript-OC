//
//  JSContextResponseObj.h
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/26.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSContextResponseProtocol.h"
#import "SFWebConst.h"


@interface JSContextResponseObj : NSObject<JSContextResponseProtocol>

@property (nonatomic, copy) LoginBlock loginBlock;

@end
