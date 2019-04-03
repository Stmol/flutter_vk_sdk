#import "VkSdkPlugin.h"
#import <flutter_vk_sdk/flutter_vk_sdk-Swift.h>

@implementation VkSdkPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVkSdkPlugin registerWithRegistrar:registrar];
}
@end
