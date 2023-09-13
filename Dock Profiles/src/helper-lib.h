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
+ (NSArray*) dockApps;
+ (NSArray*) dockApps: (BOOL) includeFinder;

//misc
+ (void) activateWindow: (NSWindow*) window;
+ (NSImage*) resizedImage: (NSImage*) sourceImage toPixelDimensions: (NSSize) newSize;
+ (BOOL) isAppSandboxed;
+ (void) killDock;
+ (void) restartApp;
@end
NS_ASSUME_NONNULL_END
