//
//  FluatAuthCustomBuildModel.m
//  fluat_auth
//
//  Created by 李梓楠 on 2020/9/1.
//

#import "FluatAuthCustomBuildModel.h"

@implementation FluatAuthCustomBuildModel

+ (TXCustomModel *)buildCustomUIModel{
		TXCustomModel *model = [[TXCustomModel alloc] init];
		
		//状态栏
		model.preferredStatusBarStyle = UIStatusBarStyleLightContent;
		
		//导航栏
		model.navIsHidden = true;
		model.privacyNavColor = [UIColor whiteColor];
		model.privacyNavTitleColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		model.privacyNavBackImage = [UIImage imageNamed:@"navigation_back_grey"];
		
		//logo
		model.logoImage =  [UIImage imageNamed:@"auth_login_logo"];
		model.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = (screenSize.width-375)/2;
				frame.origin.y = 40;
				frame.size.width = 375;
				frame.size.height = 140;
				return frame;
		};
		
		//slogan
		NSString *text = @"";
		if ([TXCommonUtils isChinaUnicom]) {
				text = @"中国联通认证";
		}
		if ([TXCommonUtils isChinaMobile]) {
				text = @"中国移动认证";
		}
		if ([TXCommonUtils isChinaTelecom]) {
				text = @"中国电信认证";
		}
		model.sloganText =  [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1.0],NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0]}];
		model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.y = 210;
				return frame;
		};
		
		//phone number
		model.numberFont = [UIFont boldSystemFontOfSize:30];
		model.numberColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
		model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.y = 230;
				return frame;
		};
		
		//登录按钮
		model.loginBtnBgImgs = @[[UIImage imageNamed:@"login_button_back_image"],[UIImage imageNamed:@"login_button_back_image"],[UIImage imageNamed:@"login_button_back_image"]];
		model.loginBtnText =  [[NSAttributedString alloc] initWithString:@"一键登录" attributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0],NSFontAttributeName : [UIFont boldSystemFontOfSize:16.0]}];
		model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = (screenSize.width-295)/2;
				frame.origin.y = 290;
				frame.size.width = 295;
				frame.size.height = 44;
				return frame;
		};
		
		//隐藏切换其他方式按钮
		model.changeBtnIsHidden = true;
		
		//协议
		model.checkBoxIsHidden = true;
		model.privacyOne = @[@"《用户协议》",@"https://app.mxhchina.com/index/index/agreement.html"];
		model.privacyTwo = @[@"《隐私政策》",@"https://app.mxhchina.com/index/index/privacypolicy.html"];
		model.privacyPreText = @"登录即同意";
		model.privacyOperatorPreText = @"《";
    model.privacyOperatorSufText = @"》";
		model.privacyAlignment = NSTextAlignmentCenter;
		model.privacyFont = [UIFont boldSystemFontOfSize:14];
		model.privacyColors = @[[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1],[UIColor colorWithRed:170/255.0 green:170/255.0 blue:170/255.0 alpha:1]];
		model.privacyFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = (screenSize.width-260)/2;
				frame.origin.y = 360;
				frame.size.width = 260;
				return frame;
		};
		
		return model;
}

@end
