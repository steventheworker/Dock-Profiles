//
//  prefsWindowController.m
//  Dock Profiles
//
//  Created by Steven G on 9/9/23.
//

#import "prefsWindowController.h"
#import "prefs.h"
#import "globals.h"

@interface prefsWindowController ()

@end

@implementation prefsWindowController
- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter]     // on window closed
        addObserver:self
        selector:@selector(windowDidClose:)
        name:NSWindowWillCloseNotification
        object:[self window]];
}
- (void) windowDidClose:(NSNotification *)notification {
    setTimeout(^{ //window still visible, call at end of stack to let close take effect
        int visibleWindows = 0;
        for (NSWindow* win in [[NSApplication sharedApplication] windows]) {
            BOOL isMenubarIconWindow = [win level] == NSStatusWindowLevel;
            if (win.isVisible && !isMenubarIconWindow) visibleWindows++;
        }
        if (!visibleWindows) [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyAccessory]; //remove dock icon
    }, 0);
}
@end
