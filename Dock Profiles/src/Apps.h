//
//  Apps.h
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Apps : NSObject
+ (void) loadConfig: (void (^)(void))cb;
+ (void) saveAppList: (void(^)(void)) cb;

+ (NSDictionary*) apps;
+ (NSDictionary*) getApp: (NSString*) appName;
@end

NS_ASSUME_NONNULL_END
