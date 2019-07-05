//
//  BARUserGuideWebView.m
//  ARSDK
//
//  Created by yuxin on 2016/11/3.
//  Copyright © 2016年 Baidu. All rights reserved.
//
#ifdef BAR_FOR_OPENSDK
#import "BARUserGuideWebView.h"
#import <JavaScriptCore/JavaScriptCore.h>
#import <WebKit/WebKit.h>

#define RequestTimeOut 5.0

@interface BARUserGuideWebView  ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSURL *requestURL;
@property (nonatomic, assign) BOOL loadSuccess;

@end

@implementation BARUserGuideWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initViewWithFrame:frame];
        
    }
    return self;
}

- (void)initViewWithFrame:(CGRect)frame
{
    [self setBackgroundColor:[UIColor clearColor]];
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc]init];
    WKUserContentController *userContentController = [[WKUserContentController alloc]init];
    [userContentController addScriptMessageHandler:self name:@"observe"];
    configuration.userContentController = userContentController;
    
    _webView = [[WKWebView alloc]initWithFrame:frame configuration:configuration];
    self.webView.backgroundColor = [UIColor clearColor];
    self.webView.navigationDelegate  = self;
    self.webView.opaque = NO;
    self.webView.scrollView.bounces = NO;
    [self addSubview:self.webView];    
    self.hidden = YES;
}

-(void)dealloc
{
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"observe"];
    self.webView.navigationDelegate = nil;
    
    //BARLog(@"end");
}

- (void)closeButtonClick:(id)sender
{
    if(self.closeBlock){
        self.closeBlock(self.requestURL, self.loadSuccess);
    }
//    [self dismiss];
}

- (void)cancelRequest
{
    [self.webView stopLoading];
}

- (void)dismiss
{
    [self.webView stopLoading];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:@"observe"];
    self.webView.navigationDelegate = nil;
    [self.webView removeFromSuperview];
    [self removeFromSuperview];
}

- (void)requestURL:(NSURL *)requestURL
{
    _requestURL = requestURL;
    
    NSURLRequest *theRequest = [[NSURLRequest alloc]initWithURL:self.requestURL
                                                 cachePolicy:NSURLRequestUseProtocolCachePolicy
                                             timeoutInterval:RequestTimeOut];
    [self.webView loadRequest:theRequest];
}

#pragma mark- WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    decisionHandler(WKNavigationActionPolicyAllow);
    //BARLog(@"web 1");
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    //BARLog(@"web 2");
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{

    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;        
        //http状态码校验，非指定状态都当做异常处理
        if(response.statusCode == 200 ||
           response.statusCode == 201 ||
           response.statusCode == 301 ||
           response.statusCode == 302 ){
            if(decisionHandler){
                decisionHandler(WKNavigationResponsePolicyAllow);
            }
        }
        else {
            NSError *error = [NSError errorWithDomain:@"response error" code:response.statusCode userInfo:nil];
            if(self.failedBlock){
                self.failedBlock(self.requestURL, error);
            }
            
            [self dismiss];
            if(decisionHandler){
                decisionHandler(WKNavigationResponsePolicyCancel);
            }
        }
    }
    else {
        if(decisionHandler){
            decisionHandler(WKNavigationResponsePolicyAllow);
        }
    }

    //BARLog(@"web 3");
}

//- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
//{
//    //BARLog(@"web 4");
//
//}

- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    //BARLog(@"web 5");
    self.loadSuccess = YES;
    if(self.successBlock){
        self.successBlock(self.requestURL);
    }
    self.hidden = NO;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
//    _loadSuccess = YES;
//    if(self.successBlock){
//        self.successBlock(self.requestURL);
//    }
//    self.hidden = NO;

    //BARLog(@"web 6");
}

//请求出错时，直接不显示引导页
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    //BARLog(@"web 7 :%@",error.localizedDescription);
    if(self.failedBlock){
        self.failedBlock(self.requestURL, error);
    }
    
    [self dismiss];
}

//请求出错时，直接不显示引导页
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    //BARLog(@"8 :%@",error.localizedDescription);
    if(self.failedBlock){
        self.failedBlock(self.requestURL, error);
    }
//    [self dismiss];
}

#pragma mark- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;
{
    if([message.name isEqualToString:@"observe"]){
        NSError *error = nil;
        NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:[message.body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        if(!error){
            NSString *namespace = [resp objectForKey:@"namespace"];
            NSString *method = [resp objectForKey:@"method"];
            
            if([namespace isEqualToString:@"page"] &&
               [method isEqualToString:@"close"]){
                [self closeButtonClick:nil];
            }
        }
    }
}

@end
#endif
