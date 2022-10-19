//
//  app.h
//  DockAltTab
//
//  Created by Steven G on 5/9/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface app : NSObject
+ (void) init;
+ (void) checkForUpdates;
+ (void) calcScreens;
+ (NSString*) getCurrentVersion;
@end
NS_ASSUME_NONNULL_END
