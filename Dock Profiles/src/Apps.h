//
//  Apps.h
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Apps : NSObject
+ (NSDictionary*) apps;
+ (NSDictionary*) getApp: (NSString*) appName;
+ (void) loadConfig: (void (^)(void))cb;
+ (void) saveAppList: (void(^)(void)) cb;
+ (void) processImportedTxt: (NSString*) jsonString;
@end

NS_ASSUME_NONNULL_END
