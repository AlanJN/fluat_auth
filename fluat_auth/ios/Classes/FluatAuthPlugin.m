#import "FluatAuthPlugin.h"
#import <ATAuthSDK/ATAuthSDK.h>
#import "FluatAuthCustomBuildModel.h"

@implementation FluatAuthPlugin

FlutterMethodChannel *_methodChannel;

const NSString *errCode = @"errCode";

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
		FlutterMethodChannel* channel = [FlutterMethodChannel
																		 methodChannelWithName:@"fluat_auth"
																		 binaryMessenger:[registrar messenger]];
		FluatAuthPlugin* instance = [[FluatAuthPlugin alloc] initWithRegistrar:registrar methodChannel:channel];
		[registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithRegistrar:(NSObject <FlutterPluginRegistrar> *)registrar methodChannel:(FlutterMethodChannel *)flutterMethodChannel {
		self = [super init];
		if (self) {
				_methodChannel = flutterMethodChannel;
		}
		return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
		if([@"initAliAuthSDK" isEqualToString:call.method]){
				[self setAliAuthInfo:call.arguments result:result];
		} else if([@"aliAuthLogin" isEqualToString:call.method]){
				[self aliAuthLogin:call.arguments result:result];
		} else {
				result(FlutterMethodNotImplemented);
		}
}

#pragma mark - 设置阿里一键登录信息

- (void)setAliAuthInfo:(NSDictionary *)arguments result:(FlutterResult)result{
		if (!arguments[@"iOS"]) {
				result(@NO);
				return;
		}
		NSString *secretKey = arguments[@"iOS"];
		[[TXCommonHandler sharedInstance] setAuthSDKInfo:secretKey complete:^(NSDictionary * _Nonnull resultDic) {
				if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
					
						//设置成功后 检测终端环境是否支持一键登录流程
						[[TXCommonHandler sharedInstance] checkEnvAvailableWithAuthType:PNSAuthTypeLoginToken complete:^(NSDictionary * _Nullable resultDic) {
								if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
										[self accelerateLogin:result];
								}else{
										result(@(NO));
								}
						}];
				}else{
//						result([FlutterError errorWithCode:[NSString stringWithFormat:@"%@",resultDic[@"resultCode"]] message:resultDic[@"msg"] details:@""]);
						result(@(NO));
						return;
				}
		}];
}

#pragma mark - 预取号

- (void)accelerateLogin:(FlutterResult)result{
		[[TXCommonHandler sharedInstance] accelerateVerifyWithTimeout:3 complete:^(NSDictionary * _Nonnull resultDic) {
				if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
						result(@(true)) ;
				}else{
						result(@(NO)) ;
				}
		}];
}

#pragma mark - 一键登录授权页

- (void)aliAuthLogin:(NSDictionary *)arguments result:(FlutterResult)result{
		
		TXCustomModel *model = [FluatAuthCustomBuildModel buildCustomUIModel];
		
		UIView *customView = [self moreLoginWayView];
		model.customViewBlock = ^(UIView * _Nonnull superCustomView) {
				[superCustomView addSubview:customView];
		};
		
		model.customViewLayoutBlock = ^(CGSize screenSize, CGRect contentViewFrame, CGRect navFrame, CGRect titleBarFrame, CGRect logoFrame, CGRect sloganFrame, CGRect numberFrame, CGRect loginFrame, CGRect changeBtnFrame, CGRect privacyFrame) {
				CGRect frame = customView.frame;
				frame.origin.x = (screenSize.width - frame.size.width) * 0.5;
				frame.origin.y = screenSize.height - frame.size.height - 40-[self getSafeAreaBottom];
				customView.frame = frame;
		};
		
		
		//弹起授权页面
		[[TXCommonHandler sharedInstance] getLoginTokenWithTimeout:[arguments[@"timeout"]  integerValue] controller:[self getCurrentViewController] model:model complete:^(NSDictionary * _Nonnull resultDic) {
				if ([PNSCodeLoginControllerPresentSuccess isEqualToString:resultDic[@"resultCode"]]) {
						NSLog(@"弹起授权页成功");
				}else if ([PNSCodeLoginControllerClickLoginBtn isEqualToString:resultDic[@"resultCode"]]) {
						
				}	else if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
						NSString *token = [resultDic objectForKey:@"token"];
						[self authLogin:token];
				}
		}];
}

//获取底部安全区高度
- (CGFloat)getSafeAreaBottom {
		if (@available(iOS 11.0, *)) {
				return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
		}
		return 0.0;
}

#pragma mark - 自定义更多登录方式
- (UIView *)moreLoginWayView{
		UIView *contentBackView = [UIView new];
		NSMutableArray *buttonsArray = [NSMutableArray new];
		
		BOOL weChatInstall = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
		BOOL canAppleLogin = [[UIDevice currentDevice] systemVersion].floatValue > 13.0;
		UIButton *wechatLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[wechatLoginButton setImage:[UIImage imageNamed:@"wechat_login_logo"] forState:UIControlStateNormal];
		wechatLoginButton.adjustsImageWhenHighlighted = NO;
		[wechatLoginButton addTarget:self action:@selector(weChatLogin:) forControlEvents:UIControlEventTouchUpInside];
		if (weChatInstall) {
				wechatLoginButton.frame = CGRectMake(0, 0, 40, 40);
				[contentBackView addSubview:wechatLoginButton];
				[buttonsArray addObject:wechatLoginButton];
		}
		
		UIButton *appleLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[appleLoginButton setImage:[UIImage imageNamed:@"apple_login_logo"] forState:UIControlStateNormal];
		appleLoginButton.adjustsImageWhenHighlighted = NO;
		[appleLoginButton addTarget:self action:@selector(appleLogin:) forControlEvents:UIControlEventTouchUpInside];
		[contentBackView addSubview:appleLoginButton];
		if (canAppleLogin) {
				if (weChatInstall) {
						appleLoginButton.frame = CGRectMake(CGRectGetMaxX(wechatLoginButton.frame)+30,0 , 40, 40);
				}else{
						appleLoginButton.frame = CGRectMake(0, 0, 40, 40);
				}
				[contentBackView addSubview:appleLoginButton];
				[buttonsArray addObject:appleLoginButton];
		}
		
		UIButton *accountLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
		[accountLoginButton setImage:[UIImage imageNamed:@"account_login_logo"] forState:UIControlStateNormal];
		accountLoginButton.adjustsImageWhenHighlighted = NO;
		[accountLoginButton addTarget:self action:@selector(accountLogin:) forControlEvents:UIControlEventTouchUpInside];
		[contentBackView addSubview:accountLoginButton];
		if (weChatInstall) {
				if (canAppleLogin) {
						accountLoginButton.frame = CGRectMake(CGRectGetMaxX(appleLoginButton.frame)+30,0 , 40, 40);
				}else{
						accountLoginButton.frame = CGRectMake(CGRectGetMaxX(wechatLoginButton.frame)+30,0 , 40, 40);
				}
		}else{
				if (canAppleLogin) {
						accountLoginButton.frame = CGRectMake(CGRectGetMaxX(appleLoginButton.frame)+30,0 , 40, 40);
				}else{
						accountLoginButton.frame = CGRectMake(0,0 , 40, 40);
				}
		}
		[contentBackView addSubview:accountLoginButton];
		[buttonsArray addObject:accountLoginButton];
		CGFloat contentWidth = (buttonsArray.count*40+(buttonsArray.count-1)*30);
		contentBackView.frame = CGRectMake(0, 0, contentWidth, 40);
		
		return contentBackView;
}

#pragma mark - 一键登录

- (void)authLogin:(NSString *)token{
		NSDictionary *result = @{errCode:@(0),@"authToken":token};
		[_methodChannel invokeMethod:@"authLoginEvent" arguments:result];
		//取消授权页
		[[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
}

#pragma mark - 微信登录

- (void)weChatLogin:(UIButton *)button{
		NSDictionary *result = @{errCode:@(0)};
		[_methodChannel invokeMethod:@"weChatLoginEvent" arguments:result];
}

#pragma mark - 苹果登录

- (void)appleLogin:(UIButton *)button{
		NSDictionary *result = @{errCode:@(0)};
		[_methodChannel invokeMethod:@"appleLoginEvent" arguments:result];
}

#pragma mark - 账号

- (void)accountLogin:(UIButton *)button{
		NSDictionary *result = @{errCode:@(0)};
		[_methodChannel invokeMethod:@"accountLoginEvent" arguments:result];
		//取消授权页
		[[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
}

#pragma mark - 获取当前controller

- (UIViewController *)getCurrentViewController{
		UIWindow *window = [[UIApplication sharedApplication].delegate window];
		UIViewController *topViewController = [window rootViewController];
		while (true) {
				if (topViewController.presentedViewController) {
						topViewController = topViewController.presentedViewController;
				} else if ([topViewController isKindOfClass:[UINavigationController class]] && [(UINavigationController*)topViewController topViewController]) {
						topViewController = [(UINavigationController *)topViewController topViewController];
				} else if ([topViewController isKindOfClass:[UITabBarController class]]) {
						UITabBarController *tab = (UITabBarController *)topViewController;
						topViewController = tab.selectedViewController;
				} else {
						break;
				}
		}
		return topViewController;
}

@end
