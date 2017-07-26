＃WebViewJavaScript-OC
主要演示了 webView 与 JavaScript 的交互

交互方式:
  1. 传统的url传值监听   UIWebView 的stringByEvaluatingJavaScriptFromString 方法调用js

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{

    // 1 url 传值方式
    NSString *urlString = [[request URL] absoluteString];
    if ([urlString rangeOfString:@"app://"].location != NSNotFound) {

        // 登录
        if ([urlString rangeOfString:@"login"].location != NSNotFound) {

        }

        return NO;
    }
    return YES;
}

    NSString *result = [NSString stringWithFormat:@"<p>登录成功!</p> <p style=\"color:#f54223\">交互传值:URL方式</p> <p>用户名:%@</p>  <p>会员等级:超级会员</p>", userName];
    NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
    [self.webView stringByEvaluatingJavaScriptFromString:javaScriptString];








  2. UIWebView 新引入的JSContext 导入对象/函数到js达到监听js回调,     JSContext  evaluateScript 方法调用 js

    // shouldStartLoadWithRequest 中调用
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

    - (void)webViewDidFinishLoad:(UIWebView *)webView{
        void* loginFunc =(__bridge void *)(^(NSString *userName, NSString *pwd){

        if ([self checkUser:userName password:pwd]) {
            [self loginSuccess:1 userName:userName];
        }
        });

        // 直接插入方法 login(a,b)
        self.context[@"login"] = (__bridge id)(loginFunc);
    }
    


    
    



        NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
        [self.context evaluateScript:javaScriptString];





  3. WKWebView   WKUserScript 导入js运行脚本, WKUserContentController 监听 window.webkit.messageHandlers.message.postMessage()函数得到js回调     WKWebView evaluateJavaScript 方法调用js



    // 注入js
    NSString *jsName = @"wkAppObj.js";
    NSString *source = [self fileContentWithFileName:jsName];

    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:source injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [userContentController addUserScript:userScript];

    // 监听
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


    // 调用js

    NSString *javaScriptString = [NSString stringWithFormat:@"self.loginCallBack('%@')", result];
    [self.webView evaluateJavaScript:javaScriptString completionHandler:^(id _Nullable res, NSError * _Nullable error) {
        NSLog(@"res:%@ err:%@", res, error);
    }];


