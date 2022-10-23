//
//  app.m
//  Dock Profiles
//
//  Created by Steven G on 10/19/22.
//

#import "app.h"
#import "helper-lib.h"
#import "globals.h"
#import "Apps.h"

NSDictionary* const DefaultConfig = @{
    @"item1": @4
};
NSString* const versionLink = @"https://dockprofiles.netlify.app/currentversion.txt";
NSMutableDictionary* Config = nil;

/* helpers fn's */
// config
NSData* fileData(NSString* fileName, NSString* fileType) {return [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:fileName ofType:fileType]];}
NSDictionary* loadJSON(NSString* fileName) {return [NSJSONSerialization JSONObjectWithData: fileData(fileName, @"json") options:kNilOptions error:nil];}
void loadConfig(void (^cb) (void)) {
    Config = [NSMutableDictionary dictionaryWithDictionary: DefaultConfig];
    [Config addEntriesFromDictionary: loadJSON(@"config")];
    if (!Config[@"apps"]) [app saveAppList : cb]; else cb(); // get full apps list (if DNE), save in config.json
}
void AddAppToConfig(NSString* name, NSString* path) {
    if (!Config[@"apps"]) Config[@"apps"] = [NSMutableDictionary new]; // [Config insertValue:[] inPropertyWithKey:@"apps"];
    Config[@"apps"][name] = [Apps getAppDict: name : path];
}


void AddEventListeners(void) {
    [helperLib listenClicks]; // ask for input monitoring first
    // ask for accessibility
    NSDictionary* options = @{(__bridge NSString*)(kAXTrustedCheckOptionPrompt) : @YES};
    if (!AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)options)) {
        [NSTimer scheduledTimerWithTimeInterval:3.0
        repeats:YES
        block:^(NSTimer* timer) {
            if (AXIsProcessTrusted()) { // [self relaunchIfProcessTrusted];
                [NSTask launchedTaskWithLaunchPath:[[NSBundle mainBundle] executablePath] arguments:@[]];
                [NSApp terminate:nil];
            }
        }];
    }
    // permission-free events
    [helperLib listenScreens];
}
@implementation app
// onLaunch
+ (void) init {
    NSLog(@"%@", @"running app :)\n-------------------------------------------------------------------");
    AppDelegate* del = [helperLib getApp];
    //add permissions
    del->_systemWideAccessibilityObject = AXUIElementCreateSystemWide();
    AddEventListeners();
    //functional
    [del bindScreens]; //load screen data
    del->dockPos = [helperLib getDockPosition];
    del->dockPID = [helperLib getPID:@"com.apple.dock"]; //todo: refresh dockPID every x or so?
    //UI variables
    del->appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [app checkForUpdates];
    loadConfig(^{
        NSLog(@"apps loaded! render UI!");
    });
}
+ (void) saveConfig {
    // nsdictionary* -> json string
}
+ (void) saveAppList : (void(^)(void)) cb {
    void (^processShellOutput)(NSString* data) = ^(NSString* data) {
        NSXMLDocument* xml = [[NSXMLDocument document] initWithXMLString:data options:0 error:nil];
        NSXMLNode *el = [[[[xml childAtIndex:0] childAtIndex:0] childAtIndex:0] childAtIndex:11];
        for (NSXMLNode* _el in [el children]) {
//                        if ([_el childCount] >= 11 && [[[_el childAtIndex:10] stringValue] isEqual:@"path"])
//                        if ( [[[_el childAtIndex:8] stringValue] isEqual:@"path"])
            NSString* appName;
            NSString* path;
            for (int i = 0; i < [_el childCount] / 2; i++) {
                NSXMLNode* label = [_el childAtIndex: i * 2];
                NSXMLNode* val = [_el childAtIndex: i * 2 + 1];
                if ([[label stringValue] isEqual:@"_name"]) appName = [val stringValue];
                if ([[label stringValue] isEqual:@"path"]) path = [val stringValue];
            }
            AddAppToConfig(appName, path);
        }
        [app saveConfig];
        cb();
    };
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/system_profiler"]; // system_profiler -detailLevel full SPApplicationsDataType
    [task setArguments:[NSArray arrayWithObjects:@"-detailLevel", @"full", @"SPApplicationsDataType", @"-xml", nil]];
    NSPipe *outputPipe = [NSPipe pipe];
    [task setStandardOutput:outputPipe];
    //wait until ReadToEndOfFile finished
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleReadToEndOfFileCompletionNotification object:[outputPipe fileHandleForReading] queue:nil usingBlock:^(NSNotification * _Nonnull notification) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleReadToEndOfFileCompletionNotification object:[notification object]];
        NSData* data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
        processShellOutput([[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
    [[outputPipe fileHandleForReading] readToEndOfFileInBackgroundAndNotify];
    [task launch];
}
+ (void) checkForUpdates {
    AppDelegate* del = [helperLib getApp];
    [helperLib fetch: versionLink : ^(NSString* data) {
        del->mostCurrentVersion = data;
        if (del->mostCurrentVersion != del->appVersion) NSLog(@"--✨ show update popup ✨--");
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
