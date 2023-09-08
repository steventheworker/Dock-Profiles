//
//  helper-lib.h
//  Dock Profiles
//
//  Created by Steven G on 10/18/22.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN
@interface helperLib : NSObject {}
+ (void) activateWindow: (NSWindow*) window;
+ (void) restartApp;
@end
NS_ASSUME_NONNULL_END
