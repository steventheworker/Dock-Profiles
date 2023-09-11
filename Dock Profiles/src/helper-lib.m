//
//  helper-lib.m
//  Dock Profiles
//
//  Created by Steven G on 10/18/22.
//

#import "helper-lib.h"

//info needed to add to dock
NSDictionary* runningAppInfo(NSRunningApplication* app) {
    NSString* bundlePath = app.bundleURL.path;
    NSDictionary* infoPlist = [NSDictionary dictionaryWithContentsOfFile: [bundlePath stringByAppendingPathComponent:@"Contents/Info.plist"]];
    NSString* executableName = infoPlist[@"CFBundleExecutable"]; // === appDict[@"tile-data"][@"file-label"],
    NSLog(@"%@", executableName); //todo: fix returns "Electron" instead of Visual Studio Code (localizedName)
    return @{
        @"name": executableName ? executableName : app.localizedName,
        @"BID": app.bundleIdentifier,
        @"tileType": @"runningApp"
    };
}
NSDictionary* persistentAppInfo(NSDictionary* persistentDict) {
    /* enum TileType: String {         ===        { "tile-data": {"file-label": ""}, "tile-type": "spacer-tile" }
         case spacer = "spacer-tile"
         case smallSpacer = "small-spacer-tile"
         case flexSpacer = "flex-spacer-tile"
         case file = "file-tile"
         case directory = "directory-tile"
         case url = "url-tile"
     } */
    NSDictionary* spacerTileTypes = @{@"spacer-tile": @1, @"small-spacer-tile": @1, @"flex-spacer-tile": @1};
    BOOL isSpacer = spacerTileTypes[persistentDict[@"tile-type"]]; // if BID === null && name === ""  =>  spacer
    return @{
        @"name": (isSpacer ? persistentDict[@"tile-type"] : (persistentDict[@"tile-data"][@"file-label"])),
        @"BID": (isSpacer ? persistentDict[@"tile-type"] : (persistentDict[@"tile-data"][@"bundle-identifier"])),
        @"tileType": persistentDict[@"tile-type"]
    };
}
@implementation helperLib
+ (NSArray*) dockApps {return [self dockApps: true];} // by default includes finder
+ (NSArray*) dockApps: (BOOL) includeFinder {
    NSMutableArray* dockApps = [NSMutableArray new];
    // iterate persistent-apps directly from dock.plist
    NSString *dockPrefsPath = [@"~/Library/Preferences/com.apple.dock.plist" stringByExpandingTildeInPath];
    NSDictionary *dockPrefs = [NSDictionary dictionaryWithContentsOfFile:dockPrefsPath];
    NSArray *persistentAppsArray = dockPrefs[@"persistent-apps"];
    for (NSDictionary *appDictionary in persistentAppsArray) [dockApps addObject: [NSMutableDictionary dictionaryWithDictionary: persistentAppInfo(appDictionary)]];
    //iterate nsrunningapp's
    NSArray* runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    int persistentAppCount = (int) dockApps.count;
    NSDictionary* finderDict;
    for (NSRunningApplication* cur in runningApps) {
        if (!includeFinder && [cur.localizedName isEqual:@"Finder"]) continue; //don't add finder, since it's forced onto the dock
        if ([cur activationPolicy] != NSApplicationActivationPolicyRegular) continue;
        //filter out persistent apps that are also running
        BOOL isPersistentApp = NO;
        for (int j = 0; j < persistentAppCount; j++) if ([dockApps[j][@"BID"] isEqual: cur.bundleIdentifier]) isPersistentApp = YES;
        if (!isPersistentApp) {
            if ([cur.localizedName isEqual:@"Finder"]) finderDict = runningAppInfo(cur);
            else [dockApps addObject: runningAppInfo(cur)]; //add running apps (ie: what comes after the persistent apps)
        }
    }
    if (includeFinder) [dockApps insertObject: finderDict atIndex:0]; // if includes finder, add to start of list
    return dockApps;
}



//misc
+ (NSImage*) resizedImage: (NSImage*) sourceImage toPixelDimensions: (NSSize) newSize {
    if (!sourceImage.isValid) return nil;
    NSBitmapImageRep* rep = [[NSBitmapImageRep alloc]
              initWithBitmapDataPlanes: NULL
                            pixelsWide: newSize.width
                            pixelsHigh: newSize.height
                         bitsPerSample: 8
                       samplesPerPixel: 4
                              hasAlpha: YES
                              isPlanar: NO
                        colorSpaceName: NSCalibratedRGBColorSpace
                           bytesPerRow: 0
                          bitsPerPixel: 0];
    rep.size = newSize;
    [NSGraphicsContext saveGraphicsState];
    [NSGraphicsContext setCurrentContext: [NSGraphicsContext graphicsContextWithBitmapImageRep: rep]];
    [sourceImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height) fromRect: NSZeroRect operation: NSCompositingOperationCopy fraction: 1.0];
    [NSGraphicsContext restoreGraphicsState];
    NSImage* newImage = [[NSImage alloc] initWithSize: newSize];
    [newImage addRepresentation: rep];
    return newImage;
}
+ (void) activateWindow: (NSWindow*) window {
    [NSApp activateIgnoringOtherApps: YES];
    [window makeKeyAndOrderFront: nil];
}
+ (BOOL)isAppSandboxed {
    BOOL isSandboxed = YES;
    NSDictionary *entitlements = nil;
    SecCodeRef codeRef = NULL;
    if (SecCodeCopySelf(kSecCSDefaultFlags, &codeRef) == errSecSuccess) {
        CFDictionaryRef codeDict = NULL;
        if (SecCodeCopySigningInformation(codeRef, kSecCSSigningInformation, &codeDict) == errSecSuccess) {
            if (codeDict) {
                entitlements = CFBridgingRelease(CFDictionaryGetValue(codeDict, kSecCodeInfoEntitlementsDict));
                if (entitlements && entitlements[@"com.apple.security.app-sandbox"] != nil) isSandboxed = [entitlements[@"com.apple.security.app-sandbox"] boolValue];
                else NSLog(@"Entitlements dictionary is NULL.");
            } else NSLog(@"Signing information dictionary is NULL.");
        }
    }
    return isSandboxed;
}


/* Stolen from: https://stackoverflow.com/questions/15305845/how-can-a-mac-gui-app-relaunch-itself-without-using-sparkle */
+ (void) restartApp {
    // Get the path to the current running app executable
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* executablePath = [mainBundle executablePath];
    const char* execPtr = [executablePath UTF8String];

    #if ATEXIT_HANDLING_NEEDED
        // Get the pid of the parent process
        pid_t originalParentPid = getpid();

        // Fork a child process
        pid_t pid = fork();
        if (pid != 0) // Parent process - exit so atexit() is called
        {
            exit(0);
        }

        // Now in the child process

        // Wait for the parent to die. When it does, the parent pid changes.
        while (getppid() == originalParentPid)
        {
            usleep(250 * 1000); // Wait .25 second
        }
    #endif

    // Do the relaunch
    execl(execPtr, execPtr, NULL);
}
@end
