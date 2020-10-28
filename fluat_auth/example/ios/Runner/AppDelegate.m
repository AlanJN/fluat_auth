#import "AppDelegate.h"
#import "GeneratedPluginRegistrant.h"
//#import <WebKit/WebKit.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
		
//		//弹出网络权限
//		WKWebView *webView = [[WKWebView alloc] init];
//		NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"https://www.taobao.com/"]];
//		[webView loadRequest:urlRequest];
  [GeneratedPluginRegistrant registerWithRegistry:self];
  // Override point for customization after application launch.
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
