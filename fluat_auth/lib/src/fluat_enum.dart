/// [VERIFY] 本机号码验证
/// [LOGIN] 一键登录
enum FluATAuthType { VERIFY, LOGIN }

/// [DEFAULT] UIStatusBarStyleDefault
/// [LIGHT] UIStatusBarStyleLightContent
enum FluStatusBarStyle { DEFAULT, LIGHT }

/// [SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN] View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
/// [SYSTEM_UI_FLAG_LOW_PROFILE] View.SYSTEM_UI_FLAG_LOW_PROFILE
enum FluStatusBarUIFlag { SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN, SYSTEM_UI_FLAG_LOW_PROFILE }

/// [LEFT] NSTextAlignmentLeft/Gravity.LEFT
/// [RIGHT] NSTextAlignmentRight/Gravity.RIGHT
/// [CENTER] NSTextAlignmentCenter/Gravity.CENTER
enum FluPrivacyAlignment { LEFT, RIGHT, CENTER }

extension FluATAuthTypeExtensions on FluATAuthType {
  int toNativeInt() {
    switch (this) {
      case FluATAuthType.VERIFY:
        return 1;
      case FluATAuthType.LOGIN:
        return 2;
    }
    return 0;
  }
}

extension FluStatusBarStyleExtensions on FluStatusBarStyle {
  int toNativeInt() {
    switch (this) {
      case FluStatusBarStyle.DEFAULT:
        return 1;
        break;
      case FluStatusBarStyle.LIGHT:
        return 2;
        break;
    }
    return 0;
  }
}

extension FluStatusBarUIFlagExtensions on FluStatusBarUIFlag {
  int toNativeInt() {
    switch (this) {
      case FluStatusBarUIFlag.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN:
        return 1;
        break;
      case FluStatusBarUIFlag.SYSTEM_UI_FLAG_LOW_PROFILE:
        return 2;
        break;
    }
    return 0;
  }
}

extension FluPrivacyAlignmentExtensions on FluPrivacyAlignment {
  int toNativeInt() {
    switch (this) {
      case FluPrivacyAlignment.LEFT:
        return 1;
        break;
      case FluPrivacyAlignment.RIGHT:
        return 2;
        break;
      case FluPrivacyAlignment.CENTER:
        return 3;
        break;
    }
    return 0;
  }
}
