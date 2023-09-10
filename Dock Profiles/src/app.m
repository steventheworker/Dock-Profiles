//
//  app.m
//  Dock Profiles
//
//  Created by Steven G on 10/19/22.
//

#import "app.h"
#import "helper-lib.h"
#import "globals.h"
#import "prefs.h"
#import "prefsWindowController.h"
#import "profileEditorWindowController.h"

@implementation App
+ (instancetype) init: (NSWindow*) window : (NSMenu*) menu {
    App* app = [[self alloc] init];
    
    // add new app instance's references
    app->permissionWindow = window;
    
    if (![app hasRequiredPermissions]) { //app shouldn't do anything until permissions are granted
        [app renderAndShowPermissionWindow];
        return app;
    }
    
    [app addMenuIcon: menu]; // adds menu icon / references
    
    //load nib/xib
    app->prefsController = [[prefsWindowController alloc] initWithWindowNibName:@"prefs"];
    [app->prefsController loadWindow];
    app->editorController = [[profileEditorWindowController alloc] initWithWindowNibName: @"profileEditor"];
    [app->editorController loadWindow];
    [helperLib activateWindow: [app->editorController window]];
    
    [app startListening];
    
    return app;
}

- (void) addMenuIcon: (NSMenu*) menu {
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength: NSSquareStatusItemLength];
    [[statusItem button] setImage: [NSImage imageNamed: @"MenuIcon"]];
    [statusItem setMenu: menu];
    [statusItem setVisible: [[prefs load][@"showMenubarIcon"] boolValue]];
}
- (void) toggleMenuIcon {[statusItem setVisible: ![[prefs load][@"showMenubarIcon"] boolValue]];}


/* event listening */
- (void) startListening {
    // on appBecameActive
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(appBecameActive:) name: NSApplicationDidBecomeActiveNotification object: nil];
    //give app its dock icon now (so appBecameActive doesn't run immediately)
    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular];
}
- (void) appBecameActive: (NSNotification*) notification {
    // don't raise prefs if sparkle updater visible (may open on launch (and triggers appBecameActive unintentionally))
    NSArray* windows = [[NSApplication sharedApplication] windows];  // window titles: "DockAltTab needs some permissions", "Item-0" (menubar "window" title), "DockAltTab - preferences", "" (Sparkle update window)
    NSString* appTitle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    for (NSWindow* cur in windows) if (cur.isVisible) if ([[cur title] isEqual: @""] || [[cur title] isEqual: @"Software Update"] || [[cur title] isEqual: [@"Updating %@" stringByAppendingString: appTitle]]) return;
        
    // raise prefs window
    [self openEditor];
}



- (BOOL) hasRequiredPermissions { // also adds permission entries into settings
    BOOL hasAccessibility = AXIsProcessTrustedWithOptions(NULL);
//    IOHIDRequestAccess(kIOHIDRequestTypeListenEvent); // add input monitoring entry in settings (has to run as start of app lifecycle (will not work any later))
//    BOOL hasInputMonitoring = IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOReturnSuccess;
//    BOOL hasScreenRecording = CGPreflightScreenCaptureAccess();
    return hasAccessibility;
}
/* rendering - app windows (eg: permissionWindow, prefsWindow (via: [app->prefsController window]), etc.) */
- (void) renderAndShowPermissionWindow {
    [helperLib activateWindow: self->permissionWindow];
    //render
    NSView *mainView = [self->permissionWindow contentView];
    for (NSView *subview in [mainView subviews]) {
        if ([subview isKindOfClass:[NSButton class]]) {
            NSButton *button = (NSButton *)subview;
            [button setFocusRingType:NSFocusRingTypeNone]; // Remove NSFocusRing (focus border/outline)
            //colorize on/off permissions
            if ([button.title isEqual: @"Accessibility"] && AXIsProcessTrustedWithOptions(NULL)) [button setBezelColor: [NSColor systemGreenColor]];
            if ([button.title isEqual: @"Input Monitoring"] && IOHIDCheckAccess(kIOHIDRequestTypeListenEvent) == kIOReturnSuccess) [button setBezelColor: [NSColor systemGreenColor]];
            if ([button.title isEqual: @"Screen Recording"] && CGPreflightScreenCaptureAccess()) [button setBezelColor: [NSColor systemGreenColor]];
        }
    }
}
- (void) openEditor {
//    [[editorController window] setIsVisible: YES];
    [helperLib activateWindow: [editorController window]];
    [prefs render: [editorController window]];
    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular]; //make dock icon visible
}
- (void) openPrefs {
    [[prefsController window] setIsVisible: YES];
//    [prefsController showWindow: [prefsController window]];
    [helperLib activateWindow: [prefsController window]];
    [prefs render: [prefsController window]];
    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular]; //make dock icon visible
}
@end
