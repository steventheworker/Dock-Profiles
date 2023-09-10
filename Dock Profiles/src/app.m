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
    [self openEditor]; //give app its dock icon now (so appBecameActive doesn't run immediately)
}
- (void) appBecameActive: (NSNotification*) notification {
    NSArray* windows = [[NSApplication sharedApplication] windows];
    // don't raise mainWindow if app already has a visible app (ignore menubar icon)
    for (NSWindow* cur in windows) if (cur.isVisible) {if (cur.level == NSStatusWindowLevel) continue; else return;}
        
    // raise main window
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
    [helperLib activateWindow: [editorController window]];
    [prefs render: [editorController window]];
    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular]; //make dock icon visible
}
- (void) openPrefs {
    [helperLib activateWindow: [prefsController window]];
    [prefs render: [prefsController window]];
    [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyRegular]; //make dock icon visible
}
@end
