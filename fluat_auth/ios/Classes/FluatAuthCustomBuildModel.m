//
//  FluatAuthCustomBuildModel.m
//  fluat_auth
//
//  Created by 李梓楠 on 2020/9/1.
//

#import "FluatAuthCustomBuildModel.h"

@implementation FluatAuthCustomBuildModel

+ (TXCustomModel *)buildCustomUIModelWith:(NSDictionary *)config{
		TXCustomModel *model = [[TXCustomModel alloc] init];
		
		//状态栏
		int statusBarStyle = [config[@"statusBarStyle"] intValue];
		switch (statusBarStyle) {
				case 1:
						model.preferredStatusBarStyle = UIStatusBarStyleDefault;
						break;
					case 2:
						model.preferredStatusBarStyle = 	UIStatusBarStyleLightContent;
						break;
				default:
						break;
		}
		model.prefersStatusBarHidden = [config[@"statusBarHidden"] boolValue];
		
		//导航栏
		model.navIsHidden = [config[@"navIsHidden"] boolValue];
		model.navColor = [self colorWithHexString:config[@"navColor"]];

		NSMutableDictionary *navAttributes = [NSMutableDictionary dictionary];
		navAttributes[NSForegroundColorAttributeName] = [self colorWithHexString:config[@"navTitleColor"]];
		navAttributes[NSFontAttributeName] = [UIFont systemFontOfSize:[config[@"navTitleSize"] floatValue]];
		model.navTitle = [[NSAttributedString alloc] initWithString:config[@"navTitle"] attributes:navAttributes];
		model.navBackImage = [UIImage imageNamed:config[@"navBackImage"]];
		model.hideNavBackItem = [config[@"hideNavBackItem"] boolValue];
		
		//协议详情页
		model.privacyNavColor = [self colorWithHexString:config[@"privacyNavColor"]];
		model.privacyNavTitleColor =[self colorWithHexString:config[@"privacyNavTitleColor"]];
		model.privacyNavTitleFont = [UIFont systemFontOfSize:[config[@"privacyNavTitleSize"] floatValue]];
		model.privacyNavBackImage = [UIImage imageNamed:config[@"privacyNavBackImage"]];
		
		//logo
		model.logoImage =  [UIImage imageNamed:config[@"logoImage"]];
		model.logoFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = (screenSize.width- [config[@"logoWidth"] doubleValue])/2;
				frame.origin.y = [config[@"logoOffsetY"] doubleValue];
				frame.size.width = [config[@"logoWidth"] doubleValue];
				frame.size.height = [config[@"logoHeight"] doubleValue];
				return frame;
		};
		
		//slogan
		NSString *text = config[@"sloganText"];
		model.sloganText =  [[NSAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [self colorWithHexString:config[@"sloganTextColor"]],NSFontAttributeName : [UIFont systemFontOfSize:[config[@"sloganTextSize"] floatValue]]}];
		model.sloganFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.y = [config[@"sloganOffsetY"] doubleValue];
				return frame;
		};
		
		//phone number
		model.numberFont = [UIFont boldSystemFontOfSize:[config[@"numberSize"] integerValue]];
		model.numberColor = [self colorWithHexString:config[@"numberColor"]];
		model.numberFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.y = [config[@"numberOffsetY"] doubleValue];
				return frame;
		};
		
		//登录按钮
		model.autoHideLoginLoading = [config[@"loginLoadingHidden"] boolValue];
		NSArray *imageArray = config[@"loginBtnBgImgs"];
		model.loginBtnBgImgs = @[[UIImage imageNamed:imageArray[0]],[UIImage imageNamed:imageArray[1]],[UIImage imageNamed:imageArray[2]]];
		model.loginBtnText =  [[NSAttributedString alloc] initWithString:config[@"loginBtnText"] attributes:@{NSForegroundColorAttributeName : [self colorWithHexString:config[@"loginBtnTextColor"]],NSFontAttributeName : [UIFont boldSystemFontOfSize:[config[@"loginBtnTextSize"] floatValue]]}];
		model.loginBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = [config[@"loginBtnLRPadding"] doubleValue];
				frame.origin.y = [config[@"loginBtnOffsetY"] doubleValue];
				frame.size.height = [config[@"loginBtnHeight"] doubleValue];
				return frame;
		};
		
		//切换其他方式按钮
		model.changeBtnIsHidden = [config[@"changeBtnIsHidden"] boolValue];
		model.changeBtnTitle = [[NSAttributedString alloc] initWithString:config[@"changeBtnText"] attributes:@{NSForegroundColorAttributeName : [self colorWithHexString:config[@"changeBtnTextColor"]],NSFontAttributeName : [UIFont boldSystemFontOfSize:[config[@"changeBtnTextSize"] floatValue]]}];
		model.changeBtnFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.y = [config[@"changeBtnOffsetY"] doubleValue];
				return frame;
		};
		
		//协议
		model.checkBoxIsHidden = [config[@"checkBoxIsHidden"] boolValue];;
		model.checkBoxIsChecked = [config[@"checkBoxIsChecked"] boolValue];;
		NSArray *checkImages = config[@"checkBoxImages"];
		if (checkImages.count == 2) {
				model.checkBoxImages = @[[UIImage imageNamed:checkImages[0]],[UIImage imageNamed:checkImages[1]]];
		}
		model.checkBoxWH =  [config[@"checkBoxWH"] doubleValue];
		NSArray *one = config[@"privacyOne"];
		NSArray *two = config[@"privacyTwo"];
		NSArray *three = config[@"privacyThree"];
		if (one.count == 2) {
				model.privacyOne = one;
		}
		if (two.count == 2) {
				model.privacyTwo = two;
		}
		if (three.count == 2) {
				model.privacyThree = three;
		}
		model.privacyPreText = config[@"privacyPreText"];
		model.privacySufText = config[@"privacySufText"];
		model.privacyOperatorPreText = config[@"privacyOperatorPreText"];
    model.privacyOperatorSufText = config[@"privacyOperatorSufText"];
		
		int  alignment = [config[@"privacySufText"] intValue];
		switch (alignment) {
				case 1:
						model.privacyAlignment = NSTextAlignmentLeft;
						break;
				case 2:
						model.privacyAlignment = NSTextAlignmentRight;
						break;
				case 3:
						model.privacyAlignment = NSTextAlignmentCenter;
						break;
				default:
						break;
		}
		model.privacyFont = [UIFont boldSystemFontOfSize:[config[@"privacyTextSize"] floatValue]];
		NSArray *colors = config[@"privacyColors"];
		model.privacyColors = @[[self colorWithHexString:colors[0]], [self colorWithHexString:colors[1]]];
		model.privacyFrameBlock = ^CGRect(CGSize screenSize, CGSize superViewSize, CGRect frame) {
				frame.origin.x = [config[@"privacyLRPadding"] doubleValue];
				frame.origin.y = [config[@"privacyOffsetY"] doubleValue];
				return frame;
		};
		
		return model;
}

+ (UIColor *)colorWithHexString:(NSString *)color{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]){
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6){
        return [UIColor clearColor];
    }
     
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
     
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1];
}

@end
