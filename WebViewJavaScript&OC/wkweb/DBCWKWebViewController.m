//
//  DBCWKWebViewController.m
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/24.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import "DBCWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "WKMessageHandleRoute.h"

@interface DBCWKWebViewController ()<WKNavigationDelegate>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation DBCWKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    
    WKUserContentController *userContentController = [[WKUserContentController alloc] init];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    
    NSString *jsName = @"wkAppObj.js";
    NSString *source = [self fileContentWithFileName:jsName];
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:userScript];
    
    // 自适应屏幕宽度js
    NSString *autoScale = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);";
    WKUserScript *wkAutoScaleScript = [[WKUserScript alloc] initWithSource:autoScale injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    // 添加自适应屏幕宽度js调用的方法
    [userContentController addUserScript:wkAutoScaleScript];
    
    WKMessageHandleRoute *messageHandle = [[WKMessageHandleRoute alloc] init];
    [userContentController addScriptMessageHandler:messageHandle name:@"user"];
    __weak DBCWKWebViewController *this = self;
    messageHandle.loginBlock = ^(NSString *userName, NSString *pwd) {
        [this loginSuccessUserName:userName];
    };
    
    
    config.userContentController = userContentController;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, width, height-64) configuration:config];

    
    NSString *htmlString = [self fileContentWithFileName:@"wkWebViewTest.html"];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    [webView loadHTMLString:htmlString baseURL:bundleURL];
    webView.navigationDelegate = self;
    [self.view addSubview:webView];
    self.webView = webView;
}


-(void)loginSuccessUserName:(NSString *)userName{
    
    // 登录成功  调用js的方法
    NSString *msg = [NSString stringWithFormat:@"登录成功!\n 交互传值:WKScript\n 用户名:%@  \n会员等级:超级会员", userName];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
    
    NSString *result = [NSString stringWithFormat:@"<p>登录成功!</p> <p style=\"color:#42f523\">交互传值:WKScript</p> <p>用户名:%@</p>  <p>会员等级:超级会员</p>", userName];
    NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSLog(@"res:%@ err:%@", res, error);
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString *)fileContentWithFileName:(NSString *)fileName{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:nil];
    NSError *error = nil;
    NSString *result = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"load text error: %@", error);
        return nil;
    }
    return result;
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    
    NSURL *actionURL = navigationResponse.response.URL;
    NSString *actionAbsoluteString = [actionURL absoluteString];
    NSLog(@"%@", actionAbsoluteString);
    
    decisionHandler(WKNavigationResponsePolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
}

@end
