//
//  Apps.m
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import "Apps.h"
#import "prefs.h"
#import "helper-lib.h"

//NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];

//NSString* fullPath(NSString* name, NSString* path) {
////    if (!bid) {
////        NSLog(@"???wtf %@", name);
////        return [NSURL new];
////    }
////    NSLog(@"? %@", bid);
////    if ([bid isEqual:@"com.apple.bootcampassistant"] || [bid isEqual:@"com.adobe.accmac"]) {
////        NSLog(@" buttocks");
////        return [NSURL new];
////    }
////    return [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: bid];
//    NSBundle* bundle =  [NSBundle bundleWithPath: path];
////    NSLog(@"%@ ,,, %@", path, name);
////    return !bid || [[bid bundleIdentifier] isEqual:@""] ? name : [bid bundleIdentifier];
////    if (![bundle bundleIdentifier]) NSLog(@"dne %@", name);
//    NSString* BID = [bundle bundleIdentifier] ? [bundle bundleIdentifier] : name;
//    NSURL* a = [[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: BID];
//    NSString* p = !a || [[a absoluteString] isEqual:@""] ?  [NSString stringWithFormat:@"file:///%@/", path] : [a absoluteString];
//    NSLog(@"%@", [[NSWorkspace sharedWorkspace] iconForFile:p] ? @"y" : @"n");
//    return @"";
////    if (!a) NSLog(@"%@ ---- %@", BID, path);
////    return [[[NSWorkspace sharedWorkspace] URLForApplicationWithBundleIdentifier: BID] absoluteString];
//
//
//    if (a) {
////        NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile:path];
//////        [image drawInRect:<#(NSRect)#> fromRect:<#(NSRect)#> operation:<#(NSCompositingOperation)#> fraction:<#(CGFloat)#>]
//////        NSLog(@"%@", image);
//        NSLog(@"%@", [a absoluteString]);
//    }
//    if (!a) NSLog(@"%@", path);
////    if (!a) NSLog(@"%@ - %@", name, path);
////    if (a) return [a absoluteString];
//    return [NSString stringWithFormat:@"file:///%@/", path];
//}

NSDictionary* const DefaultConfig = @{
    @"scannedApps": @{}, //apps retrieved via systemprofiler
    @"manuallyAddedApps": @{}, //
    @"apps": @{}, //app library
    @"profiles": @{}
};
NSMutableDictionary* Config = nil; // uses the "data" NSUserDefault to hold json for the whole config

NSString* iconPath(NSString* appPath) {return [NSString stringWithFormat:@"%@/%@", appPath, @"Contents/Resources/AppIcon.icns"];}
void AddAppToConfig(NSString* name, NSString* path) {
    if (![[Config[@"apps"] allKeys] count]) Config[@"apps"] = [NSMutableDictionary new]; // [Config insertValue:[] inPropertyWithKey:@"apps"];
    Config[@"apps"][name] = @{
        @"name": name,
        @"path": path,
        @"iconPath": iconPath(path)
    };
}
void saveToPrefs(void) {
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject: Config options: NSJSONWritingPrettyPrinted error: nil];
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject: jsonData forKey: @"data"];
    [userDefaults synchronize];
}

@implementation Apps
+ (NSDictionary*) apps {return Config[@"apps"];}
+ (NSDictionary*) getApp: (NSString*) appName {return Config[@"apps"][appName];}
+ (void)loadConfig:(void (^)(void))cb {
    Config = [NSMutableDictionary dictionaryWithDictionary: DefaultConfig];
    NSData* jsonData = [[NSUserDefaults standardUserDefaults] dataForKey:@"data"];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData ? jsonData : [NSData dataWithBytes:nil length:0] options:NSJSONReadingAllowFragments error:nil];
    [Config addEntriesFromDictionary: jsonDict];
    if (![[Config[@"apps"] allKeys] count]) [Apps saveAppList : cb]; else cb(); // get full apps list (if DNE), save in config.json
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
        saveToPrefs();
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
@end
