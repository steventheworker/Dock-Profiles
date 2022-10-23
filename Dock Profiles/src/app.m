//
//  app.m
//  Dock Profiles
//
//  Created by Steven G on 10/19/22.
//

#import "app.h"
#import "helper-lib.h"
#import "globals.h"

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
    [app checkForUpdates];
    loadConfig(^{
        NSLog(@"apps loaded! render UI!");
    });
}
+ (void) saveAppList : (void(^)(void)) cb {
    void (^processShellOutput)(NSString* data) = ^(NSString* data) {
        return NSLog(@"%@", [data substringWithRange: NSMakeRange([data length] - 1000, 1000)]);
//        [[NSXMLDocument document] initWithData:<#(nonnull NSData *)#> encoding:<#(NSStringEncoding)#>]
        NSXMLDocument* xml = [[NSXMLDocument document] initWithXMLString:data options:0 error:nil];
        
        NSLog(@"%@", [xml childAtIndex:0]);
        NSLog(@"childCount %lu", [xml childCount]);

//        NSLog(@"%@", xml);

        //             NSLog(@"%@", [[[[xml childAtIndex:0] childAtIndex:0] childAtIndex:0] childAtIndex:3]);
        // Config[key] = parsedxml;
        // write config.json = json.stringify(Config)
        cb();
    };
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/usr/sbin/system_profiler"]; // system_profiler -detailLevel full SPApplicationsDataType
    [task setArguments:[NSArray arrayWithObjects:@"-detailLevel", @"full", @"SPApplicationsDataType", @"-xml", nil]];
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];
    NSFileHandle *fileHandle = [pipe fileHandleForReading];
    NSMutableArray* buff = [NSMutableArray new];
    [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:fileHandle queue: nil
    usingBlock:^(NSNotification * _Nonnull notification) {
        NSData* data = [notification.object availableData];
        NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (![str isEqual:@""]) {
            [notification.object waitForDataInBackgroundAndNotify];
            [buff addObject:str];
        } else processShellOutput([buff componentsJoinedByString:@"\n"]);
    }];
    [fileHandle waitForDataInBackgroundAndNotify];
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
