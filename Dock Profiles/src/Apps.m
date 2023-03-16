//
//  Apps.m
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import "Apps.h"

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

NSString* iconPath(NSString* appPath) {
    //    NSImage *image = [[NSWorkspace sharedWorkspace] iconForFile: appPath];
    NSString* path = [NSString stringWithFormat:@"%@/%@", appPath, @"Contents/Resources/AppIcon.icns"];
    return path;
}

@implementation Apps
+ (NSDictionary*) getAppDict : (NSString*) name : (NSString*) path {
    return @{
        @"name": name,
        @"path": path,
        @"iconPath": iconPath(path)
    };
}
@end
