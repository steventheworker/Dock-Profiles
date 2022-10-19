//
//  AppDelegate.m
//  Dock Profiles
//
//  Created by Steven G on 10/15/22.
//

#import "AppDelegate.h"
#import "src/helper-lib.h"
#import "src/app.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
/* Events */
- (void) bindScreens {[app calcScreens];}
- (void) bindClick:(CGEventRef)e {
    NSLog(@"click");
}
/* UI */

/* LifeCycle */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*) sender {[[NSApplication sharedApplication] terminate: self];return true;} // NSApplication.shared.terminate(self)
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {[app init];}
- (void)applicationWillTerminate:(NSNotification *)aNotification {}
- (BOOL)applicationSupportsSecureRestorableState:(NSApplication *)app {return YES;}

@end
