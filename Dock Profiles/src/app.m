//
//  app.m
//  DockAltTab
//
//  Created by Steven G on 5/9/22.
//

#import "app.h"
#import "helper-lib.h"

//config
const NSString* versionLink = @"https://dockprofiles.netlify.app/currentversion.txt";
//hardcoded apple details
//define

@implementation app
// onLaunch
+ (void) init {
    NSLog(@"%@", @"running app :)\n-------------------------------------------------------------------");
    AppDelegate* del = [helperLib getApp];
    //functional
    [del bindScreens]; //load screen data
    del->dockPos = [helperLib getDockPosition];
    del->dockPID = [helperLib getPID:@"com.apple.dock"]; //todo: refresh dockPID every x or so?
    //UI variables
    del->appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    //permissions
    del->_systemWideAccessibilityObject = AXUIElementCreateSystemWide();
//    [app checkForUpdates];
}
+ (void) checkForUpdates {
    AppDelegate* del = [helperLib getApp];
    del->mostCurrentVersion = [app getCurrentVersion];
    if (del->mostCurrentVersion != del->appVersion) 1; // todo: popup window
}
+ (NSString*) getCurrentVersion {return [helperLib get: (NSString*) versionLink];}
+ (void) calcScreens {
    
}
/* UI */
@end

