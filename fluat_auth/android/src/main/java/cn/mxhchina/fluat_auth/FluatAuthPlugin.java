package cn.mxhchina.fluat_auth;

import com.alibaba.fastjson.JSONObject;
import com.mobile.auth.gatewayauth.CustomInterface;
import com.mobile.auth.gatewayauth.PhoneNumberAuthHelper;
import com.mobile.auth.gatewayauth.TokenResultListener;
import com.mobile.auth.gatewayauth.model.TokenRet;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.app.Activity;
import android.content.Context;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.nfc.Tag;
import android.os.Build;
import android.util.Log;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.ImageView;
import android.widget.RelativeLayout;
import android.widget.Space;
import android.widget.TextView;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.mobile.auth.gatewayauth.AuthRegisterViewConfig;
import com.mobile.auth.gatewayauth.AuthRegisterXmlConfig;
import com.mobile.auth.gatewayauth.AuthUIConfig;
import com.mobile.auth.gatewayauth.AuthUIControlClickListener;
import com.mobile.auth.gatewayauth.PhoneNumberAuthHelper;
import com.mobile.auth.gatewayauth.PreLoginResultListener;
import com.mobile.auth.gatewayauth.TokenResultListener;
import com.mobile.auth.gatewayauth.model.TokenRet;
import com.mobile.auth.gatewayauth.ui.AbstractPnsViewDelegate;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static cn.mxhchina.fluat_auth.AppUtils.dp2px;

/** FluatAuthPlugin */
public class FluatAuthPlugin implements FlutterPlugin, MethodCallHandler ,ActivityAware{
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity

  private final String TAG = "Mxh_Activity_Tag";

  private static final int SERVICE_TYPE_LOGIN = 2;//一键登录
  private MethodChannel channel;
  private TokenResultListener mTokenListener;
  private static Activity activity;
  private static Context mContext;
  private static String token;
  private PhoneNumberAuthHelper mAlicomAuthHelper;

  private JSONObject eventResult = new JSONObject();



  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "fluat_auth");
    Log.v(TAG, "初始化这里了 ");
    channel.setMethodCallHandler(this);

    mContext = flutterPluginBinding.getApplicationContext();

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
      case "getPlatformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "initAliAuthSDK":
        initAuthSDK(call,result);
        break;
      case "aliAuthLogin":
        authLogin(call);
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
  private void initAuthSDK(MethodCall call, final MethodChannel.Result result){
    String appKey = call.argument("android");
    /*
    * 1.初始化获取token实例
    * */
    mTokenListener = new TokenResultListener() {
      @Override
      public void onTokenSuccess(final String s) {
        activity.runOnUiThread(new Runnable() {

          @Override
          public void run() {

            TokenRet tokenRet = null;
            try {
              tokenRet = JSON.parseObject(s, TokenRet.class);
            } catch (Exception e) {
              e.printStackTrace();
            }
            if (tokenRet != null && ("600024").equals(tokenRet.getCode())) {
              //终端检测成功后 预取号
              accelerateLogin(result);
            }else if (tokenRet != null && ("600000").equals(tokenRet.getCode())) {
              token = tokenRet.getToken();
              eventResult.put("errCode", Integer.valueOf(0));
              eventResult.put("authToken", token);
              mAlicomAuthHelper.quitLoginPage();
              channel.invokeMethod("authLoginEvent",eventResult);
            }else {
              result.success(0);
            }
          }
        });
      }

      @Override
      public void onTokenFailed(final String s) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(0);
          }
        });
      }
    };
    /*
    * 2.初始化SDK实例
    * */
    mAlicomAuthHelper = PhoneNumberAuthHelper.getInstance(mContext, mTokenListener);
    mAlicomAuthHelper.setAuthListener(mTokenListener);
    mAlicomAuthHelper.getReporter().setLoggerEnable(true);
    /*
    * 3.设置SDK秘钥
    * */
    mAlicomAuthHelper.setAuthSDKInfo(appKey);

    /*
    * 4.检测终端网络环境是否支持一键登录
    * */
    mAlicomAuthHelper.checkEnvAvailable(SERVICE_TYPE_LOGIN);
}

  /*
  * 预取号
  * */
  private void accelerateLogin(final MethodChannel.Result result){
    mAlicomAuthHelper.accelerateLoginPage(3000, new PreLoginResultListener() {
      @Override
      public void onTokenSuccess(final String vendor) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(1);
          }
        });
      }

      @Override
      public void onTokenFailed(final String vendor, final String ret) {
        activity.runOnUiThread(new Runnable() {
          @Override
          public void run() {
            result.success(0);
          }
        });
      }
    });
  }


  //一键登录 弹出授权页
  private void authLogin(MethodCall call){
    configLoginTokenPort();

    Integer timeout = call.argument("timeout");
    assert timeout != null;
    //唤起授权页
    mAlicomAuthHelper.getLoginToken(activity, timeout*1000);
  }

  private void configLoginTokenPort() {

    mAlicomAuthHelper.removeAuthRegisterXmlConfig();
    mAlicomAuthHelper.removeAuthRegisterViewConfig();

    mAlicomAuthHelper.addAuthRegisterXmlConfig(new AuthRegisterXmlConfig.Builder()
            .setLayout(R.layout.other_login_way, new AbstractPnsViewDelegate() {

              @Override
              public void onViewCreated(View view) {
                if (!isWeChatInstall(mContext)){
                  findViewById(R.id.weChat_login).setVisibility(View.GONE);
                  findViewById(R.id.login_space).setVisibility(View.GONE);
                }else {
                  findViewById(R.id.weChat_login).setVisibility(View.VISIBLE);
                  findViewById(R.id.login_space).setVisibility(View.VISIBLE);
                  findViewById(R.id.weChat_login).setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View v) {
                      eventResult.put("errCode",Integer.valueOf(0));
                      channel.invokeMethod("weChatLoginEvent",eventResult);
                    }
                  });
                }

                findViewById(R.id.account_login).setOnClickListener(new View.OnClickListener() {
                  @Override
                  public void onClick(View v) {
                    mAlicomAuthHelper.quitLoginPage();;
                    eventResult.put("errCode",Integer.valueOf(0));
                    channel.invokeMethod("accountLoginEvent",eventResult);
                  }
                });
              }
            })
            .build());

    int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
    if (Build.VERSION.SDK_INT == 26) {
      authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
    }
    String slogan = "";
    if (mAlicomAuthHelper.getCurrentCarrierName().equals("CMCC")){
      slogan = "中国移动认证";
    }else if (mAlicomAuthHelper.getCurrentCarrierName().equals("CUCC")){
      slogan = "中国联通认证";
    }else{
      slogan = "中国电信认证";
    }
    mAlicomAuthHelper.setAuthUIConfig(new AuthUIConfig.Builder()
            .setLightColor(true)
            .setStatusBarColor(Color.WHITE)
            .setStatusBarUIFlag(View.SYSTEM_UI_FLAG_LOW_PROFILE)
            .setWebNavReturnImgPath("navigation_back_grey")
            .setWebNavColor(Color.WHITE)
            .setWebNavTextColor(Color.parseColor("#333333"))
            .setNavHidden(true)
            .setLogoImgPath("auth_login_logo")
            .setLogoHeight(140)
            .setLogoWidth(375)
            .setLogoOffsetY(40)
            .setSloganOffsetY(260)
            .setSloganText(slogan)
            .setSloganTextSize(14)
            .setSloganTextColor(Color.parseColor("#AAAAAA"))
            .setNumFieldOffsetY(290)
            .setNumberSize(30)
            .setLogBtnOffsetY(350)
            .setLogBtnBackgroundPath("login_button_back_image")
            .setSwitchAccHidden(true)
            .setAppPrivacyOne("《用户协议》", "https://app.mxhchina.com/index/index/agreement.html")
            .setAppPrivacyTwo("《隐私政策》", "https://app.mxhchina.com/index/index/privacypolicy.html")
            .setPrivacyBefore("登录即同意")
            .setAppPrivacyColor(Color.parseColor("#AAAAAA"), Color.parseColor("#AAAAAA"))
            .setPrivacyTextSize(14)
            .setPrivacyOffsetY(420)
            .setPrivacyMargin(70)
            .setCheckboxHidden(true)
            .setAuthPageActIn("in_activity", "out_activity")
            .setAuthPageActOut("in_activity", "out_activity")
            .setVendorPrivacyPrefix("《")
            .setVendorPrivacySuffix("》")
            .setScreenOrientation(authPageOrientation)
            .create());
  }

  /**
   * 判断 用户是否安装微信客户端
   */
  private static boolean isWeChatInstall(Context context) {
    final PackageManager packageManager = context.getPackageManager();
    List<PackageInfo> packageInfo = packageManager.getInstalledPackages(0);
    if (packageInfo != null) {
      for (int i = 0; i < packageInfo.size(); i++) {
        String pn = packageInfo.get(i).packageName;
        if (pn.equalsIgnoreCase("com.tencent.mm")) {
          return true;
        }
      }
    }
    return false;
  }
}
