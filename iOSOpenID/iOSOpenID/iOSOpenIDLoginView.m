//
//  iOSOpenIDLoginView.m
//  iOSOpenID
//
//  Created by HRWY on 15/4/14.
//  Copyright (c) 2015年 HRWY. All rights reserved.
//

#import "iOSOpenIDLoginView.h"
#import "funcMacroDefine.h"

static CGFloat kTransitionDuration = 0.3;

@interface iOSOpenIDLoginView ()<UIWebViewDelegate>
{
    NSString *_serverURL;
    
    UIView *_view;
    UIWebView *_webView;
    
    UINavigationBar *_navigationBar;
    UIButton *_closeButton;
    
    UIToolbar *_toolBar;
    UIBarButtonItem *_reloadButton;
    UIBarButtonItem *_stopButton;
    UIBarButtonItem *_backButton;
    UIBarButtonItem *_forwardButton;
    
    UIInterfaceOrientation _orientation;
}

@end

@implementation iOSOpenIDLoginView
@synthesize delegate = _delegate;
@synthesize iOSOpenIDToken = _iOSOpenIDToken;

- (id)init:(id<iOSOpenIDLoginViewDelegate>)delegate
{
    self = [self initWithURL:SERVER_IP delegate:delegate];
    return self;
}

- (id)initWithURL:(NSString *)serverURL
         delegate:(id<iOSOpenIDLoginViewDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _serverURL = [NSString stringWithString:serverURL];
        _delegate = delegate;
    }
    return self;
}

- (void)getOpenID
{
    [self createBackgroundView];
    [self createWebView];
    [self createToolBar];
    [self createNavigationBar];
    
    [self load];
    [self sizeToFitOrientation:NO];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window)
    {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self];
    
    [self changeWebViewSize];
}




#pragma mark -
#pragma mark 绘制界面
- (void)createBackgroundView
{
    _view = [[UIView alloc] initWithFrame:CGRectMake(Zero, Zero, ScreenWidth, ScreenHeight)];
    _view.backgroundColor = [UIColor whiteColor];
    [self addSubview:_view];
}

- (void)createCloseButton
{
    UIImage* closeImage = [UIImage imageNamed:@"close_btn_src_normal.png"];
    UIImage* backImage =[UIImage imageNamed:@"closeimg.png"];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setImage:closeImage forState:UIControlStateNormal];
    [_closeButton setBackgroundImage:backImage forState:UIControlStateNormal];
    [_closeButton setFrame:CGRectMake(ScreenWidth - backImage.size.width,
                                      Zero,
                                      backImage.size.width,
                                      backImage.size.height)];
    [_closeButton addTarget:self
                     action:@selector(cancelLoginView)
           forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_closeButton];
}

- (void)createWebView
{
    _webView = [[UIWebView alloc] init];
    _webView.delegate = self;
    _webView.frame = self.bounds;
    _webView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.scalesPageToFit = YES;
    [self addSubview:_webView];
}

- (void)changeWebViewSize
{
    _webView.frame = CGRectMake(self.bounds.origin.x, self.bounds.origin.y + NAVIGATION_BAR_HEIGHT, self.bounds.size.width, self.bounds.size.height - TOOL_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT);
}

- (void)createReloadButton
{
    _reloadButton = [[UIBarButtonItem alloc] initWithTitle:@"刷新"
                                                     style:UIBarButtonItemStyleDone
                                                    target:self
                                                    action:@selector(reloadDidPush)];
}

- (void)createStopButton
{
    _stopButton = [[UIBarButtonItem alloc] initWithTitle:@"停止"
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(stopDidPush)];
}

- (void)createBackButton
{
    _backButton = [[UIBarButtonItem alloc] initWithTitle:@"后退"
                                                   style:UIBarButtonItemStyleDone
                                                  target:self
                                                  action:@selector(backDidPush)];
}

- (void)createForwardButton
{
    _forwardButton = [[UIBarButtonItem alloc] initWithTitle:@"前进"
                                                      style:UIBarButtonItemStyleDone
                                                     target:self
                                                     action:@selector(forwardDidPush)];
}

- (void)createToolBar
{
    _toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(Zero, ScreenHeight - 60, ScreenWidth, TOOL_BAR_HEIGHT)];
    [self createReloadButton];
    [self createStopButton];
    [self createBackButton];
    [self createForwardButton];
    NSArray *buttons = [NSArray arrayWithObjects:_backButton, _forwardButton,
                        _reloadButton, _stopButton, nil];
    [_toolBar setItems:buttons];
    [self addSubview:_toolBar];
}

- (void)createNavigationBar
{
    _navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(Zero, Zero, ScreenWidth, 67)];
    
    UINavigationItem *item = [[UINavigationItem alloc] initWithTitle:@""];
    
    _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
    [_closeButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    [_closeButton setFrame:CGRectMake(Zero,
                                      Zero,
                                      67,
                                      67)];
    [_closeButton addTarget:self
                     action:@selector(cancelLoginView)
           forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:_closeButton];
    [item setLeftBarButtonItem:leftButton];
    [_navigationBar pushNavigationItem:item animated:NO];
    
    [self addSubview:_navigationBar];
}

- (void)updateControlEnable
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = _webView.loading;
}


#pragma mark -
#pragma mark webView 返回功能

/**
 * 网页请求完毕时的响应事件
 * @param webView 当前的界面
 */
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    OIDLog(@"请求地址 = %@", webView.request.URL.absoluteString);
    if ([self fetchToken:KEYFORTOKEN urlStr:webView.request.URL.absoluteString])
    {
        
        NSArray *strArray = [webView.request.URL.absoluteString componentsSeparatedByString:KEYFORTOKEN];
        NSString *token = [strArray objectAtIndex:1];
        [self fetchTokenSucc:token];
        [self cancelLoginView];
    }
}

/**
 * 网页开始请求时的响应事件
 * @param webView 当前的界面
 */
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    OIDLog(@"开始请求 请求地址 = %@", webView.request.URL.absoluteString);
}

/**
 * 网页请求出错时的响应事件
 * @param webView 当前的界面
 * @param error 错误信息
 */
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    OIDLog(@"取消请求 请求地址 = %@", webView.request.URL.absoluteString);
}


#pragma mark -
#pragma mark webView 响应操作

- (void)reloadDidPush
{
    [_webView reload];
}

- (void)stopDidPush
{
    if (_webView.loading)
    {
        [_webView stopLoading];
    }
}

- (void)backDidPush
{
    if (_webView.canGoBack)
    {
        [_webView goBack];
    }
}

- (void)forwardDidPush
{
    if (_webView.canGoForward)
    {
        [_webView goForward];
    }
}

/**
 * 点击关闭按钮之后的响应
 */
- (void)cancelLoginView
{
    _webView.delegate = nil;
    [_webView stopLoading];
    [self dismiss:YES];
}

- (void)dismiss:(BOOL)animated
{
    if (animated)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:kTransitionDuration];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(postDismissCleanup)];
        self.alpha = 0;
        [UIView commitAnimations];
    }
    else
    {
        [self postDismissCleanup];
    }
}

- (void)postDismissCleanup
{
    
    [self removeObservers];
    [self removeFromSuperview];
}

- (void)dismissWithError:(NSError *)error animated:(BOOL)animated
{
    [self dismiss:animated];
}

- (void)removeObservers
{
    
}

/**
 *  对服务器返回信息进行判断，判断是否含有 Token 字符串
 *
 *  @param checkStr 检查的字符串
 *  @param urlStr   网址字符串
 *
 *  @return 是否包含
 */
- (BOOL)fetchToken:(NSString *)checkStr urlStr:(NSString *)urlStr
{
    NSRange range = [urlStr rangeOfString:checkStr];
    if (range.length > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)load
{
    NSURL *loadULR = [NSURL URLWithString:_serverURL];
    OIDLog(@"请求的 IP 地址为： %@", loadULR);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:loadULR];
    [_webView loadRequest:request];
}

- (void)sizeToFitOrientation:(BOOL)transform
{
    if (transform)
    {
        self.transform = CGAffineTransformIdentity;
    }
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    CGPoint center = CGPointMake(frame.origin.x + ceil(frame.size.width / 2),
                                 frame.origin.y + ceil(frame.size.height / 2));
    CGFloat scale_factor = 1.0f;
    CGFloat width = floor(scale_factor * frame.size.width);
    CGFloat height = floor(scale_factor * frame.size.height);
    
    _orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsLandscape(_orientation))
    {
        self.frame = CGRectMake(0, 0, height, width);
    }
    else
    {
        self.frame = CGRectMake(0, 0, width, height);
    }
    self.center = center;
    if (transform)
    {
        self.transform = [self transformForOrientation];
    }
}

- (CGAffineTransform)transformForOrientation
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
        return CGAffineTransformMakeRotation(M_PI * 1.5);
    }
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
        return CGAffineTransformMakeRotation(M_PI / 2);
    }
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        return CGAffineTransformMakeRotation(-M_PI);
    }
    else
    {
        return CGAffineTransformIdentity;
    }
}


#pragma mark -
#pragma mark 回调函数
- (void)fetchTokenSucc:(NSString *)token
{
    [_delegate performSelector:@selector(iOSOpenIDFetchTokenSucc:) withObject:token];
}

- (void)fetchTokenFail
{
    [_delegate performSelector:@selector(iOSOpenIDFetchTokenFail)];
}

- (void)fetchTokenError:(NSError *)error
{
    [_delegate performSelector:@selector(iOSOpenIDFetchTokenError:) withObject:error];
}

@end