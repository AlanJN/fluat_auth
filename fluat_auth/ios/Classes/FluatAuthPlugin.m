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
		if ([@"initAliAuthSDK" isEqualToString:call.method]){
				[self setAliAuthInfo:call result:result];
		} else if ([@"checkEnvAvailable" isEqualToString:call.method]){
				[self checkEnvAvailable:call result:result];
		} else if ([@"showAuthLoginPage" isEqualToString:call.method]){
				[self showAuthLoginPage:call result:result];
		} else if ([@"getVerifyToken" isEqualToString:call.method]){
				[self getVerifyToken:call result:result];
		} else if ([@"closeAuthPage" isEqualToString:call.method]){
				[self closeLoginVC];
		} else {
				result(FlutterMethodNotImplemented);
		}
}

#pragma mark - 设置阿里一键登录信息

- (void)setAliAuthInfo:(FlutterMethodCall *)call result:(FlutterResult)result{
	
		if (!call.arguments[@"inIOS"]) {
				result(@NO);
				return;
		}
		
		NSString *secretKey = call.arguments[@"iOSSecretKey"];
		[[TXCommonHandler sharedInstance] setAuthSDKInfo:secretKey complete:^(NSDictionary * _Nonnull resultDic) {
				if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
						result(@YES);
				}else{
						result(@NO);
				}
		}];
}

#pragma mark - 检查当前设备环境

- (void)checkEnvAvailable:(FlutterMethodCall *)call result:(FlutterResult)result{
		
		NSNumber *typeNumber = call.arguments[@"authType"];
		PNSAuthType authType = PNSAuthTypeLoginToken;
		if ([typeNumber isEqualToNumber:@1]) {
				authType = PNSAuthTypeVerifyToken;
		}
		
		BOOL accelerate = (BOOL)call.arguments[@"accelerate"];
		NSNumber *timeOut = call.arguments[@"timeOut"];
		
		[[TXCommonHandler sharedInstance] checkEnvAvailableWithAuthType:authType complete:^(NSDictionary * _Nullable resultDic) {
				
				if ([PNSCodeSuccess isEqualToString:[resultDic objectForKey:@"resultCode"]]) {
						result(@YES);
						if (accelerate) {
								if (authType == PNSAuthTypeVerifyToken) {
										[self accelerateVerify:timeOut.intValue];
								}else{
										[self accelerateLogin:timeOut.intValue];
								}
						}
				}else{
						result(@NO);
				}
				NSDictionary *authResult = @{errCode:resultDic[@"resultCode"]};
				[_methodChannel invokeMethod:@"fluatCheckEnvEvent" arguments:authResult];
		}];
}


#pragma mark - 加速获取本机号码校验token

- (void)accelerateVerify:(int)timeOut{
		[[TXCommonHandler sharedInstance] accelerateVerifyWithTimeout:timeOut complete:^(NSDictionary * _Nonnull resultDic) {
				NSDictionary *authResult = @{errCode:resultDic[@"resultCode"]};
				[_methodChannel invokeMethod:@"fluatAccelerateEvent" arguments:authResult];
		}];
}

#pragma mark - 加速一键登录授权页弹起

- (void)accelerateLogin:(int)timeOut{
		[[TXCommonHandler sharedInstance] accelerateLoginPageWithTimeout:timeOut complete:^(NSDictionary * _Nonnull resultDic) {
				NSDictionary *authResult = @{errCode:resultDic[@"resultCode"]};
				[_methodChannel invokeMethod:@"fluatAccelerateEvent" arguments:authResult];
		}];
}

#pragma mark - 一键登录授权页

- (void)showAuthLoginPage:(FlutterMethodCall *)call result:(FlutterResult)result{
		NSNumber *timeOut = call.arguments[@"timeOut"];
		NSDictionary *config = call.arguments[@"config"];
		TXCustomModel *model;
		if (config) {
				model = [FluatAuthCustomBuildModel buildCustomUIModelWith:call.arguments[@"config"]];
		}else{
				model= nil;
		}
		//弹起授权页面
		[[TXCommonHandler sharedInstance] getLoginTokenWithTimeout:timeOut.integerValue controller:[self getCurrentViewController] model:model complete:^(NSDictionary * _Nonnull resultDic) {
				NSMutableDictionary *authResult = [[NSMutableDictionary alloc] initWithDictionary:@{errCode:resultDic[@"resultCode"]}];
				if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
						NSString *token = [resultDic objectForKey:@"token"];
						[authResult setValue:token forKey:@"token"];
				}else{
						[authResult setValue:@"" forKey:@"token"];
				}
				[_methodChannel invokeMethod:@"fluatAuthEvent" arguments:authResult];
		}];
}

#pragma mark - 获取本机号码校验token

- (void)getVerifyToken:(FlutterMethodCall *)call result:(FlutterResult)result{
		NSNumber *timeOut = call.arguments[@"timeOut"];
		[[TXCommonHandler sharedInstance] getVerifyTokenWithTimeout:timeOut.integerValue complete:^(NSDictionary * _Nonnull resultDic) {
				NSMutableDictionary *authResult = [[NSMutableDictionary alloc] initWithDictionary:@{errCode:[NSNumber numberWithInt:[resultDic[@"resultCode"] intValue]]}];
				if ([PNSCodeSuccess isEqualToString:resultDic[@"resultCode"]]) {
						NSString *token = [resultDic objectForKey:@"token"];
						[authResult setValue:token forKey:@"token"];
				}else{
						[authResult setValue:@"" forKey:@"token"];
				}
				[_methodChannel invokeMethod:@"fluatAuthEvent" arguments:authResult];
		}];
}


//获取底部安全区高度
- (CGFloat)getSafeAreaBottom {
		if (@available(iOS 11.0, *)) {
				return [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
		}
		return 0.0;
}

#pragma mark - 关闭授权页

- (void)closeLoginVC{
		[[TXCommonHandler sharedInstance] cancelLoginVCAnimated:YES complete:nil];
}

#pragma mark - 获取当前controller

- (UIViewController *)getCurrentViewController{
		UIWindow *keyWindow;
		for (UIWindow *window in [UIApplication sharedApplication].windows) {
				if (window.isKeyWindow) {
						keyWindow = window;
						break;
				}
		}
		
		UIViewController *topViewController = keyWindow.rootViewController;
		while (topViewController.presentedViewController) {
				topViewController = topViewController.presentedViewController;
		}
		return topViewController;
}

@end
