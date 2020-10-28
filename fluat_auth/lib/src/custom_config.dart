import '../fluat.dart';

/// 1.此配置类只包含大部分通用配置
/// 2.某个配置不实现均按默认处理 具体请参考阿里文档
/// 3.颜色均以16进制为标准 例: #333333,#ffffff 字母不区分大小写
/// 4.某些配置 只支持Android 或 iOS 请看好注释

class AuthLoginUIConfig {
  /** 导航栏*/
  /// 导航栏是否隐藏,默认false
  bool navIsHidden = false;

  /// 导航栏颜色
  String navColor = "#ffffff";

  /// 导航栏标题内容
  String navTitle = "FluatAuth";

  /// 导航栏标题大小
  int navTitleSize = 16;

  /// 导航栏标题颜色
  String navTitleColor = "#333333";

  /// 导航栏返回按钮图片
  String navBackImage = "fluat_navigation_back";

  /// 是否隐藏授权页导航栏返回按钮,默认false
  bool hideNavBackItem = false;

  /** 状态栏 */
  /// 状态栏是否隐藏,默认false
  bool statusBarHidden = false;

  /// 状态栏主题风格,默认DEFAULT,仅iOS有效
  FluStatusBarStyle statusBarStyle = FluStatusBarStyle.DEFAULT;

  /// 状态栏字体颜色,true为黑色,默认false,仅安卓有效
  bool statusBarIsLightColor = false;

  /// 状态栏UI属性,仅安卓有效
  FluStatusBarUIFlag statusBarUIFlag = FluStatusBarUIFlag.SYSTEM_UI_FLAG_LOW_PROFILE;

  /** LOGO */
  /// logo图片
  String logoImage = "fluat_auth_logo";

  /// logo是否隐藏,默认false
  bool logoIsHidden = false;

  /// logo宽
  int logoWidth = 50;

  /// logo高
  int logoHeight = 50;

  /// logo相对导航栏底部的Y轴距离
  int logoOffsetY = 40;

  /** slogan */
  /// slogan是否隐藏,默认false
  bool sloganHidden = false;

  /// slogan内容
  String sloganText = "FluatAuth认证";

  /// slogan颜色
  String sloganTextColor = "#333333";

  /// slogan文字大小
  int sloganTextSize = 20;

  /// slogan相对导航栏底部的Y轴距离
  int sloganOffsetY = 150;

  /** number */
  /// 手机号码字体颜色
  String numberColor = "#333333";

  /// 手机号码字体大小,小于16不生效
  int numberSize = 18;

  /// 手机号码相对导航栏底部的Y轴距离
  int numberOffsetY = 180;

  /** LoginButton */
  /// 登录按钮文字
  String loginBtnText = "立即登录";

  /// 登录按钮文字颜色
  String loginBtnTextColor = "#333333";

  /// 登录按钮文字大小
  int loginBtnTextSize = 16;

  // /// 登录按钮背景图片路径 仅安卓有效
  // String loginBtnBgImage;

  /// 登录按钮背景图片组，@[激活状态的图片,失效状态的图片,高亮状态的图片],
  /// 安卓取[0] iOS取全部
  List<String> loginBtnBgImgs = [
    "fluat_login_button_image",
    "fluat_login_button_image",
    "fluat_login_button_image"
  ];

  /// 是否隐藏点击登录按钮之后授权页上的loading 默认true
  bool loginLoadingHidden = true;

  /// 登录按钮相对content view的左右边距，按钮宽度必须大于等于屏幕的一半，
  int loginBtnLRPadding = 20;

  /// 登录按钮高度，小于40.0pt不生效
  int loginBtnHeight = 50;

  /// 登录按钮相对导航栏底部的Y轴距离
  int loginBtnOffsetY = 240;

  /** 协议 */
  /// checkBox图片组，@[uncheckedImg,checkedImg],
  List<String> checkBoxImages = ["fluat_auth_unchecked", "fluat_auth_checked"];

  /// checkBox是否勾选，默认false
  bool checkBoxIsChecked = false;

  /// checkBox是否隐藏，默认false
  bool checkBoxIsHidden = false;

  /// checkBox大小，高宽一样，必须大于0
  int checkBoxWH = 20;

  /// 协议1，[协议名称,协议Url]，注：三个协议名称不能相同
  List<String> privacyOne = ["《协议1》", "https://www.baidu.com"];

  /// 协议2，[协议名称,协议Url]，注：三个协议名称不能相同
  List<String> privacyTwo = ["《协议2》", "https://www.baidu.com"];

  /// 协议3，[协议名称,协议Url]，注：三个协议名称不能相同
  List<String> privacyThree = ["《协议3》", "https://www.baidu.com"];

  /// 协议文字颜色，[非点击文案颜色，点击文案颜色]
  List<String> privacyColors = ["#aaaaaa", "#aaaaaa"];

  /// 协议文案支持居中、居左设置，默认居左 仅iOS有效
  FluPrivacyAlignment privacyAlignment = FluPrivacyAlignment.CENTER;

  /// 协议文案字体大小 小于12不生效
  int privacyTextSize = 12;

  /// 协议整体（包括checkBox）相对content view的左右边距，
  /// 当协议整体宽度小于（content view宽度-2*左右边距）且居中模式，则左右边距设置无效，不能小于0
  int privacyLRPadding = 10;

  /// 协议整体相对导航栏底部的Y轴距离
  int privacyOffsetY = 400;

  /// 运营商协议名称前缀文案，仅支持 <([《（【『
  String privacyOperatorPreText = "《";

  /// 运营商协议名称后缀文案，仅支持 >)]》）】』
  String privacyOperatorSufText = "》";

  /// 协议整体文案，前缀部分文案
  String privacyPreText = "登录即同意";

  /// 协议整体文案，后缀部分文案
  String privacySufText = "";

  /** 协议详情页 */
  /// 协议详情页导航栏颜色
  String privacyNavColor = "#ffffff";

  /// 协议详情页导航栏标题颜色
  String privacyNavTitleColor = "#333333";

  /// 协议详情页导航栏标题文字大小
  int privacyNavTitleSize = 14;

  /// 协议详情页导航栏返回按钮
  String privacyNavBackImage = "fluat_navigation_back";

  /** 切换方式*/
  /// 切换到其他方式按钮是否隐藏 默认false
  bool changeBtnIsHidden = false;

  /// 切换到其他方式按钮文字
  String changeBtnText = "其他登录";

  /// 切换到其他方式按钮文字颜色
  String changeBtnTextColor = "#333333";

  /// 切换到其他方式按钮文字大小
  int changeBtnTextSize = 16;

  /// 切换到其他方式按钮 距离导航栏底部的Y轴距离
  int changeBtnOffsetY = 300;
}

extension AuthLoginUIConfigExtension on AuthLoginUIConfig {
  Map toNativeUIConfig() {
    return {
      "navIsHidden": navIsHidden,
      "navColor": navColor,
      "navTitle": navTitle,
      "navTitleSize": navTitleSize,
      "navTitleColor": navTitleColor,
      "navBackImage": navBackImage,
      "hideNavBackItem": hideNavBackItem,
      "statusBarHidden": statusBarHidden,
      "statusBarStyle": statusBarStyle.toNativeInt(),
      "statusBarIsLightColor": statusBarIsLightColor,
      "statusBarUIFlag": statusBarUIFlag.toNativeInt(),
      "logoImage": logoImage,
      "logoIsHidden": logoIsHidden,
      "logoWidth": logoWidth,
      "logoHeight": logoHeight,
      "logoOffsetY": logoOffsetY,
      "sloganHidden": sloganHidden,
      "sloganText": sloganText,
      "sloganTextColor": sloganTextColor,
      "sloganTextSize": sloganTextSize,
      "sloganOffsetY": sloganOffsetY,
      "numberColor": numberColor,
      "numberSize": numberSize,
      "numberOffsetY": numberOffsetY,
      "loginBtnText": loginBtnText,
      "loginBtnTextColor": loginBtnTextColor,
      "loginBtnTextSize": loginBtnTextSize,
      "loginBtnBgImgs": loginBtnBgImgs,
      "loginLoadingHidden": loginLoadingHidden,
      "loginBtnLRPadding": loginBtnLRPadding,
      "loginBtnHeight": loginBtnHeight,
      "loginBtnOffsetY": loginBtnOffsetY,
      "checkBoxImages": checkBoxImages,
      "checkBoxIsChecked": checkBoxIsChecked,
      "checkBoxIsHidden": checkBoxIsHidden,
      "checkBoxWH": checkBoxWH,
      "privacyOne": privacyOne,
      "privacyTwo": privacyTwo,
      "privacyThree": privacyThree,
      "privacyColors": privacyColors,
      "privacyAlignment": privacyAlignment.toNativeInt(),
      "privacyTextSize": privacyTextSize,
      "privacyLRPadding": privacyLRPadding,
      "privacyOffsetY": privacyOffsetY,
      "privacyOperatorPreText": privacyOperatorPreText,
      "privacyOperatorSufText": privacyOperatorSufText,
      "privacyPreText": privacyPreText,
      "privacySufText": privacySufText,
      "privacyNavColor": privacyNavColor,
      "privacyNavTitleColor": privacyNavTitleColor,
      "privacyNavTitleSize": privacyNavTitleSize,
      "privacyNavBackImage": privacyNavBackImage,
      "changeBtnIsHidden": changeBtnIsHidden,
      "changeBtnText": changeBtnText,
      "changeBtnTextColor": changeBtnTextColor,
      "changeBtnTextSize": changeBtnTextSize,
      "changeBtnOffsetY": changeBtnOffsetY
    };
  }
}
