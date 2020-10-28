//
//  FluatAuthCustomBuildModel.h
//  fluat_auth
//
//  Created by 李梓楠 on 2020/9/1.
//

#import <Foundation/Foundation.h>
#import <ATAuthSDK/ATAuthSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface FluatAuthCustomBuildModel : NSObject

+ (TXCustomModel *)buildCustomUIModelWith:(NSDictionary *)config;
@end

NS_ASSUME_NONNULL_END
