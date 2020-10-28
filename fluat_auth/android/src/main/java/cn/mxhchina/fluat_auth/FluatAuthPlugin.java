package cn.mxhchina.fluat_auth;

import com.alibaba.fastjson.JSONObject;
import com.mobile.auth.gatewayauth.PhoneNumberAuthHelper;
import com.mobile.auth.gatewayauth.ResultCode;
import com.mobile.auth.gatewayauth.TokenResultListener;
import com.mobile.auth.gatewayauth.model.TokenRet;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.graphics.Color;
import android.os.Build;
import android.util.Log;
import android.view.View;

import com.alibaba.fastjson.JSON;
import com.mobile.auth.gatewayauth.AuthUIConfig;
import com.mobile.auth.gatewayauth.PreLoginResultListener;

import java.lang.reflect.Field;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/** FluatAuthPlugin */
public class FluatAuthPlugin implements FlutterPlugin, MethodCallHandler ,ActivityAware{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private final String TAG = "Fluat_Auth_Plugin";

  private static MethodChannel channel;
  private TokenResultListener mCheckEnvListener;
  private TokenResultListener mTokenListener;
  private static Activity activity;
  private static Context mContext;
  private static String token;
  private PhoneNumberAuthHelper authHelper;
  private JSONObject eventResult = new JSONObject();


  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(),
            "fluat_auth");
    mContext = flutterPluginBinding.getApplicationContext();
    channel.setMethodCallHandler(new FluatAuthPlugin());
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "fluat_auth");

    channel.setMethodCallHandler(new FluatAuthPlugin());
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch (call.method) {
      case "initAliAuthSDK":
        initAuthSDK(call,result);
        break;
      case "checkEnvAvailable":
        checkEnvAvailable(call,result);
        break;
      case "showAuthLoginPage":
        showAuthLoginPage(call,result);
        break;
      case "getVerifyToken":
        getVerifyToken(call,result);
        break;
      case "closeAuthPage":
        closeAuthPage(call,result);
        break;
      default:
        result.notImplemented();
        break;
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    activity = binding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {

  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {

  }

  @Override
  public void onDetachedFromActivity() {

  }


  //初始化SDK 设置秘钥
  private void initAuthSDK(MethodCall call, final Result result){
    String androidSecretKey = call.argument("androidSecretKey");
    final boolean inAndroid = (boolean)call.argument("inAndroid");
    final boolean logEnable = (boolean)call.argument("loggerEnable");

    if (!inAndroid){
      result.success(false);
      return;
    }

    if (androidSecretKey.isEmpty()){
      Log.v(TAG,"android_SecretKey is illegal");
      result.success(false);
      return;
    }


    /*
     * 初始化SDK实例
     * */

    authHelper = PhoneNumberAuthHelper.getInstance(mContext, null);
    /*
    * 设置SDK秘钥
    * */
    authHelper.setAuthSDKInfo(androidSecretKey);
    authHelper.getReporter().setLoggerEnable(logEnable);
    result.success(true);
}

  /*
   * 检测环境是否支持一键登录或者号码验证
   * */
  private void checkEnvAvailable(MethodCall call, final Result result){

    int type = PhoneNumberAuthHelper.SERVICE_TYPE_AUTH;
    if ((int)call.argument("authType") == 2){
      type = PhoneNumberAuthHelper.SERVICE_TYPE_LOGIN;
    }

    final boolean accelerate = (boolean)call.argument("accelerate");
    final int authType = type;
    final int timeOut = (int)call.argument("timeOut");

    mCheckEnvListener = new TokenResultListener() {
      @Override
      public void onTokenSuccess(final String ret) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            TokenRet tokenRet = null;
            try {
              tokenRet = JSON.parseObject(ret, TokenRet.class);
            } catch (Exception e) {
              e.printStackTrace();
            }
            assert tokenRet != null;
            eventResult.put("errCode", tokenRet.getCode());
            if (ResultCode.CODE_ERROR_ENV_CHECK_SUCCESS.equals(tokenRet.getCode())) {
              result.success(true);
              channel.invokeMethod("fluatCheckEnvEvent",eventResult);
              if (accelerate){
                if (authType == PhoneNumberAuthHelper.SERVICE_TYPE_AUTH){
                  accelerateVerify(timeOut);
                }else {
                  accelerateLogin(timeOut);
                }
              }
            }else {
              result.success(false);
            }
            channel.invokeMethod("fluatCheckEnvEvent",eventResult);
          }
        });
      }

      @Override
      public void onTokenFailed(final String ret) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(false);
            eventResult.put("errCode",ret);
            channel.invokeMethod("fluatCheckEnvEvent",eventResult);
          }
        });
      }
    };

    authHelper.checkEnvAvailable(type);
    authHelper.setAuthListener(mCheckEnvListener);
  }

  /*
   * 加速获取本机号码token
   * */
  private void accelerateVerify(int timeOut){

    authHelper.accelerateVerify(timeOut*1000, new PreLoginResultListener() {
      @Override
      public void onTokenSuccess(final String vendor) {
        eventResult.put("errCode","600000");
        channel.invokeMethod("fluatAccelerateEvent",eventResult);
      }

      @Override
      public void onTokenFailed(final String vendor, final String ret) {
        eventResult.put("errCode",ret);
        channel.invokeMethod("fluatAccelerateEvent",eventResult);
      }
    });
  }


  /*
  * 加速弹出授权页
  * */
  private void accelerateLogin(int timeOut){
    authHelper.accelerateLoginPage(timeOut*1000, new PreLoginResultListener() {
      @Override
      public void onTokenSuccess(final String vendor) {
        eventResult.put("errCode","600000");
        channel.invokeMethod("fluatAccelerateEvent",eventResult);
      }

      @Override
      public void onTokenFailed(final String vendor, final String ret) {
        eventResult.put("errCode",vendor+'：'+ret);
        channel.invokeMethod("fluatAccelerateEvent",eventResult);
      }
    });
  }

  /*
   * 弹出授权页
   * */
  private void showAuthLoginPage(MethodCall call,final Result result){
    customLoginPage((Map<String, Object>) call.argument("config"));
    int timeout = (int) call.argument("timeout");
    mTokenListener = new TokenResultListener() {
      @Override
      public void onTokenSuccess(final String ret) {
        activity.runOnUiThread(new Runnable() {

          @Override
          public void run() {
            TokenRet tokenRet = null;
            try {
              tokenRet = JSON.parseObject(ret, TokenRet.class);
            } catch (Exception e) {
              e.printStackTrace();
            }
            assert tokenRet != null;

            eventResult.put("errCode", tokenRet.getCode());
            if (ResultCode.CODE_GET_TOKEN_SUCCESS.equals(tokenRet.getCode())) {

              eventResult.put("token", tokenRet.getToken());
            }else {
              eventResult.put("token", "");
            }
            channel.invokeMethod("fluatAuthEvent",eventResult);
          }
        });
      }

      @Override
      public void onTokenFailed(final String ret) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(false);
            eventResult.put("errCode",ret);
            channel.invokeMethod("authErrorEvent",eventResult);
          }
        });
      }
    };
    authHelper.getLoginToken(activity, timeout*1000);
    authHelper.setAuthListener(mTokenListener);
  }

  /*
   * 获取号码验证token
   * */
  private void getVerifyToken(MethodCall call,final Result result){
    int timeout = (int) call.argument("timeout");
    mTokenListener = new TokenResultListener() {
      @Override
      public void onTokenSuccess(final String ret) {
        activity.runOnUiThread(new Runnable() {

          @Override
          public void run() {
            TokenRet tokenRet = null;
            try {
              tokenRet = JSON.parseObject(ret, TokenRet.class);
            } catch (Exception e) {
              e.printStackTrace();
            }
            assert tokenRet != null;

            eventResult.put("errCode", tokenRet.getCode());
            if (ResultCode.CODE_GET_TOKEN_SUCCESS.equals(tokenRet.getCode())) {

              result.success(true);
              token = tokenRet.getToken();
              authHelper.setAuthListener(null);
            }else {
              result.success(false);
            }
            channel.invokeMethod("fluatAuthEvent",eventResult);
          }
        });
      }

      @Override
      public void onTokenFailed(final String ret) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(false);
            eventResult.put("errCode",ret);
            channel.invokeMethod("authErrorEvent",eventResult);
          }
        });
      }
    };
    authHelper.getVerifyToken(timeout*1000);
    authHelper.setAuthListener(mTokenListener);
  }

  /*
   * 退出授权页
   * */
  private void closeAuthPage(MethodCall call,final Result result){
    authHelper.setAuthListener(null);
    authHelper.quitLoginPage();
  }

  /*
   * 自定义授权页
   * */
  private void customLoginPage(Map<String,Object> config) {
    authHelper.removeAuthRegisterXmlConfig();
    authHelper.removeAuthRegisterViewConfig();
    boolean navIsHidden = (boolean) config.get("navIsHidden");
    String navColor = (String) config.get("navColor");
    String navTitle = (String) config.get("navTitle");
    int navTitleSize = (int) config.get("navTitleSize");
    String navTitleColor = (String) config.get("navTitleColor");
    String navBackImage = (String) config.get("navBackImage");
    boolean hideNavBackItem = (boolean) config.get("hideNavBackItem");
    boolean statusBarHidden = (boolean) config.get("statusBarHidden");
    boolean statusBarIsLightColor = (boolean) config.get("statusBarIsLightColor");
    int statusBarUIFlag = (int) config.get("statusBarUIFlag") == 1?
            View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN:View.SYSTEM_UI_FLAG_LOW_PROFILE;
    String logoImage = (String) config.get("logoImage");
    boolean logoIsHidden = (boolean) config.get("logoIsHidden");
    int logoWidth = (int) config.get("logoWidth");
    int logoHeight = (int) config.get("logoHeight");
    int logoOffsetY = (int) config.get("logoOffsetY");
    boolean sloganHidden = (boolean) config.get("sloganHidden");
    String sloganText = (String) config.get("sloganText");
    String sloganTextColor = (String) config.get("sloganTextColor");
    int sloganTextSize = (int) config.get("sloganTextSize");
    int sloganOffsetY = (int) config.get("sloganOffsetY");
    String numberColor = (String) config.get("numberColor");
    int numberSize = (int) config.get("numberSize");
    int numberOffsetY = (int) config.get("numberOffsetY");
    String loginBtnText = (String) config.get("loginBtnText");
    String loginBtnTextColor = (String) config.get("loginBtnTextColor");
    int loginBtnTextSize = (int) config.get("loginBtnTextSize");
    List<String> loginBtnBgImgs = (List<String>) config.get("loginBtnBgImgs");
    boolean loginLoadingHidden = (boolean) config.get("loginLoadingHidden");
    int loginBtnLRPadding = (int) config.get("loginBtnLRPadding");
    int loginBtnHeight = (int) config.get("loginBtnHeight");
    int loginBtnOffsetY = (int) config.get("loginBtnOffsetY");
    List<String> checkBoxImages = (List<String>) config.get("checkBoxImages");
    boolean checkBoxIsChecked = (boolean) config.get("checkBoxIsChecked");
    boolean checkBoxIsHidden = (boolean) config.get("checkBoxIsHidden");
    int checkBoxWH = (int) config.get("checkBoxWH");
    List<String> privacyOne = (List<String>) config.get("privacyOne");
    List<String> privacyTwo = (List<String>) config.get("privacyTwo");
    List<String> privacyThree = (List<String>) config.get("privacyThree");
    List<String> privacyColors = (List<String>) config.get("privacyColors");
    int privacyTextSize = (int) config.get("privacyTextSize");
    int privacyLRPadding = (int) config.get("privacyLRPadding");
    int privacyOffsetY = (int) config.get("privacyOffsetY");
    String privacyOperatorPreText = (String) config.get("privacyOperatorPreText");
    String privacyOperatorSufText = (String) config.get("privacyOperatorSufText");
    String privacyPreText = (String) config.get("privacyPreText");
    String privacySufText = (String) config.get("privacySufText");
    String privacyNavColor = (String) config.get("privacyNavColor");
    String privacyNavTitleColor = (String) config.get("privacyNavTitleColor");
    int privacyNavTitleSize = (int) config.get("privacyNavTitleSize");
    String privacyNavBackImage = (String) config.get("privacyNavBackImage");
    boolean changeBtnIsHidden = (boolean) config.get("changeBtnIsHidden");
    String changeBtnText = (String) config.get("changeBtnText");
    String changeBtnTextColor = (String) config.get("changeBtnTextColor");
    int changeBtnTextSize = (int) config.get("changeBtnTextSize");
    int changeBtnOffsetY = (int) config.get("changeBtnOffsetY");



    int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
    if (Build.VERSION.SDK_INT == 26) {
      authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
    }
    String slogan = "";

    assert loginBtnBgImgs != null;
    assert checkBoxImages != null;
    assert privacyOne != null;
    assert privacyTwo != null;
    assert privacyThree != null;
    authHelper.setAuthUIConfig(new AuthUIConfig.Builder()
            .setNavHidden(navIsHidden)
            .setNavColor(Color.parseColor(navColor))
            .setNavText(navTitle)
            .setNavTextSize(navTitleSize)
            .setNavTextColor(Color.parseColor(navTitleColor))
            .setNavReturnImgPath(navBackImage)
            .setNavReturnHidden(hideNavBackItem)
            .setStatusBarHidden(statusBarHidden)
            .setLightColor(statusBarIsLightColor)
            .setStatusBarColor(Color.WHITE)
            .setStatusBarUIFlag(statusBarUIFlag)
            .setLogoImgPath(logoImage)
            .setLogoHidden(logoIsHidden)
            .setLogoWidth(logoWidth)
            .setLogoHeight(logoHeight)
            .setLogoOffsetY(logoOffsetY)
            .setSloganHidden(sloganHidden)
            .setSloganText(sloganText)
            .setSloganTextColor(Color.parseColor(sloganTextColor))
            .setSloganTextSize(sloganTextSize)
            .setSloganOffsetY(sloganOffsetY)
            .setNumberColor(Color.parseColor(numberColor))
            .setNumberSize(numberSize)
            .setNumFieldOffsetY(numberOffsetY)
            .setLogBtnText(loginBtnText)
            .setLogBtnTextSize(loginBtnTextSize)
            .setLogBtnTextColor(Color.parseColor(loginBtnTextColor))
            .setLogBtnBackgroundPath(loginBtnBgImgs.size()>1?loginBtnBgImgs.get(0):null)
            .setLogBtnToastHidden(loginLoadingHidden)
            .setLogBtnMarginLeftAndRight(loginBtnLRPadding)
            .setLogBtnHeight(loginBtnHeight)
            .setLogBtnOffsetY(loginBtnOffsetY)
            .setCheckedImgPath(checkBoxImages.size()>1?checkBoxImages.get(1):null)
            .setUncheckedImgPath(checkBoxImages.size()>1?checkBoxImages.get(0):null)
            .setCheckboxHidden(checkBoxIsHidden)
            .setPrivacyState(checkBoxIsChecked)
            .setCheckBoxWidth(checkBoxWH)
            .setCheckBoxHeight(checkBoxWH)
            .setAppPrivacyOne(privacyOne.size() == 2?privacyOne.get(0):"",privacyOne.size() == 2?
                    privacyOne.get(0):"")
            .setAppPrivacyTwo(privacyTwo.size() == 2?privacyTwo.get(0):"",privacyTwo.size() == 2?
                    privacyTwo.get(0):"")
            .setAppPrivacyThree(privacyThree.size() == 2?privacyThree.get(0):"",privacyThree.size() == 2?
                    privacyThree.get(0):"")
            .setAppPrivacyColor(
                    privacyColors.size() == 2?Color.parseColor(privacyColors.get(0)):
                    Color.parseColor("#aaaaaa"),
                    privacyColors.size() == 2?Color.parseColor(privacyColors.get(1)):
                    Color.parseColor("#aaaaaa"))
            .setPrivacyTextSize(privacyTextSize)
            .setPrivacyMargin(privacyLRPadding)
            .setPrivacyOffsetY(privacyOffsetY)
            .setVendorPrivacyPrefix(privacyOperatorPreText)
            .setVendorPrivacySuffix(privacyOperatorSufText)
            .setPrivacyBefore(privacyPreText)
            .setPrivacyEnd(privacySufText)
            .setWebNavReturnImgPath(privacyNavBackImage)
            .setWebNavColor(Color.parseColor(privacyNavColor))
            .setWebNavTextColor(Color.parseColor(privacyNavTitleColor))
            .setWebNavTextSize(privacyNavTitleSize)
            .setWebNavReturnImgPath("privacyNavBackImage")
            .setSwitchAccHidden(changeBtnIsHidden)
            .setSwitchAccText(changeBtnText)
            .setSwitchAccTextColor(Color.parseColor(changeBtnTextColor))
            .setSwitchAccTextSize(changeBtnTextSize)
            .setSwitchOffsetY(changeBtnOffsetY)
            .setScreenOrientation(authPageOrientation)
            .create());
  }


}
