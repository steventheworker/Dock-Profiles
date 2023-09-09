//
//  prefs.h
//  Dock Profiles
//
//  Created by Steven G on 9/8/23.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "app.h"

NS_ASSUME_NONNULL_BEGIN

@interface prefs : NSObject
+ (void) checkMenubarIcon: (id) sender : (App*) app;
+ (NSDictionary*) load;
+ (void) render: (NSWindow*) a;

@end

NS_ASSUME_NONNULL_END
