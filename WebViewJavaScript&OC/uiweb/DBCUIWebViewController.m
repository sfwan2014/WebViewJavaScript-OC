//
//  DBCUIWebViewController.m
//  WebViewJavaScript&OC
//
//  Created by DBC on 2017/7/24.
//  Copyright © 2017年 DBC. All rights reserved.
//

#import "DBCUIWebViewController.h"
#import "NSString+URL.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import "JSContextResponseObj.h"

#define kUserName   @"Fred"
#define kPassword   @"123456"

@interface DBCUIWebViewController ()<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) JSContext *context;
@end

@implementation DBCUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *htmlString = [self fileContentWithFileName:@"uiWebViewTest.html"];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:htmlString baseURL:bundleURL];
    
    
    self.webView.delegate = self;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 1 url 传值方式
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString rangeOfString:@"app://"].location != NSNotFound) {
        
        // 登录
        if ([urlString rangeOfString:@"login"].location != NSNotFound) {
            NSString *query = [request.URL query];
            query = [query URLDecodedString];
            
            NSArray *qArr = [query componentsSeparatedByString:@"&"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            for (NSString *qStr in qArr) {
                NSArray *arr = [qStr componentsSeparatedByString:@"="];
                NSString *key = [arr firstObject];
                NSString *value = [arr lastObject];
                [dic setObject:value forKey:key];
            }
            
            NSString *userName = dic[@"username"];
            NSString *pwd = dic[@"password"];
            if ([self checkUser:userName password:pwd]) {
                [self loginSuccess:0 userName:userName];
            }
        }
        
        return NO;
    }
    
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    JSContextResponseObj *appObj = [[JSContextResponseObj alloc] init];
    // 插入对象   appObj.login(a,b)
    context[@"appObj"] = appObj;
    __weak DBCUIWebViewController *this = self;
    appObj.loginBlock = ^(NSString *userName, NSString *pwd) {
        if ([this checkUser:userName password:pwd]) {
            [this loginSuccess:1 userName:userName];
        }
    };
    self.context = context;
    
    return YES;
}
- (void)webViewDidStartLoad:(UIWebView *)webView{
}
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    
    void* loginFunc =(__bridge void *)(^(NSString *userName, NSString *pwd){
        
        if ([self checkUser:userName password:pwd]) {
            [self loginSuccess:1 userName:userName];
        }
    });
    // 直接插入方法 login(a,b)
    self.context[@"login"] = (__bridge id)(loginFunc);
}
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
}


-(void)loginSuccess:(int)type userName:(NSString *)userName{
    
    // 登录成功  调用js的方法
    if (type == 0) { // stringByEvaluatingJavaScriptFromString 桥接方式调用js
        NSString *msg = [NSString stringWithFormat:@"登录成功!\n 交互传值:URL方式\n 用户名:%@  \n会员等级:超级会员", userName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        NSString *result = [NSString stringWithFormat:@"<p>登录成功!</p> <p style=\"color:#f54223\">交互传值:URL方式</p> <p>用户名:%@</p>  <p>会员等级:超级会员</p>", userName];
        NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
        [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];
        
    } else if (type == 1) { // JSContext 调用js
        NSString *msg = [NSString stringWithFormat:@"登录成功!\n 交互传值:JSContext\n 用户名:%@ \n 会员等级:超级会员", userName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App提示" message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        
        
        NSString *result = [NSString stringWithFormat:@"<p>登录成功!</p> <p style=\"color:#4223f5\">交互传值:JSContext</p> <p>用户名:%@</p>  <p>会员等级:超级会员</p>", userName];
        
        // 1
//        NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
//        [self.context evaluateScript:javaScriptString];
        
        // 2
//        JSValue *function = [self.context objectForKeyedSubscript:@"loginCallBack"]; //获得JS脚本
        JSValue *function = self.context[@"loginCallBack"]; //获得js脚本
        [function callWithArguments:@[result]];
    }
}

-(BOOL)checkUser:(NSString *)userName password:(NSString *)pwd{
    return YES;
    if (![userName isEqualToString:kUserName]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App提示" message:@"用户不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    if (![pwd isEqualToString:kPassword]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"App提示" message:@"密码不正确" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    return YES;
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
