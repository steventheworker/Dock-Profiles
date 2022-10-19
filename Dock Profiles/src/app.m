//
//  app.m
//  Dock Profiles
//
//  Created by Steven G on 10/19/22.
//

#import "app.h"
#import "helper-lib.h"

//config
NSDictionary* const DefaultConfig = @{
    @"item1": @4
};
NSString* const versionLink = @"https://dockprofiles.netlify.app/currentversion.txt";
NSMutableDictionary* Config = nil;
//hardcoded apple details
//define

NSDictionary* getConfigDict(void) {
    return @{
        @"item1": @2
    };
}
void loadConfig(void) {
    Config = [NSMutableDictionary dictionaryWithDictionary: DefaultConfig];
    [Config addEntriesFromDictionary: getConfigDict()];
    NSLog(@"%@", Config);
}

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
   loadConfig();
}
+ (void) checkForUpdates {
    [helperLib fetch: versionLink : ^(NSString* data) {
        AppDelegate* del = [helperLib getApp];
        del->mostCurrentVersion = data;
        if (del->mostCurrentVersion != del->appVersion) NSLog(@"--update popup--");
    }];
}
+ (void) calcScreens {
    AppDelegate* del = [helperLib getApp];
    NSScreen* primScreen = [helperLib getScreen:0];
    NSScreen* extScreen = [helperLib getScreen:1];
    del->primaryScreenWidth = NSMaxX([primScreen frame]);
    del->primaryScreenHeight = NSMaxY([primScreen frame]);
    del->extScreenWidth = [extScreen frame].size.width;
    del->extScreenHeight =  [extScreen frame].size.height;
    del->extendedOffsetX = [extScreen frame].origin.x;
    del->extendedOffsetY = [extScreen frame].origin.y;
    del->extendedOffsetYBottom = !extScreen ? 0 : fabs(del->primaryScreenHeight - del->extScreenHeight) - del->extendedOffsetY;
}
/* UI */
@end
