//
//  profileEditorWindowController.m
//  Dock Profiles
//
//  Created by Steven G on 9/9/23.
//

#import "profileEditorWindowController.h"
#import "globals.h"
#import "helper-lib.h"
#import "app.h"
#import "Apps.h"

@interface profileEditorWindowController ()

@end

@implementation profileEditorWindowController
/* ui */
- (void) addDockItemAdder {
    CGFloat size = 50;
    NSArray* appKeys = [[Apps apps] allKeys];
    int appCount = (int) [appKeys count];
    NSView* rowContainer = [[NSView alloc] initWithFrame: CGRectMake(0, 0, size * appCount, 285)]; // 300 (scrollableContainer height) - 15 (bottom scrollbar height) = 285px
    for (int i = 0; i < appCount; i++) {
        NSString* appName = appKeys[i];
        NSDictionary* app = [Apps getApp: appName];
        CGFloat x = 50 * i++;
        CGFloat y = 0;
        NSImage* img = [[NSWorkspace sharedWorkspace] iconForFile: app[@"path"]];
        NSImageView* imgView = [[NSImageView alloc] initWithFrame: CGRectMake(x, y, size, size)];
        [imgView setImage: [helperLib resizedImage: img toPixelDimensions: NSMakeSize(size, size)]];
        NSLog(@"%@", app);
        [rowContainer addSubview: imgView];
    }
    NSScrollView* scrollableContainer = [[NSScrollView alloc] initWithFrame: CGRectMake(0, 0, 480, 300)];
    [scrollableContainer setDocumentView:rowContainer];
    [scrollableContainer setHasHorizontalScroller: YES];
    [self.window.contentView addSubview: scrollableContainer];
}
- (void) addUI {
    [self addDockItemAdder];
}
- (void) resizeUI {
    NSRect f = self.window.frame;

}

/* lifecycle */
- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] // on window closed
        addObserver: self
        selector: @selector(windowDidClose:)
        name: NSWindowWillCloseNotification
        object: [self window]];
    profileEditorWindowController* selfRef = self;
    [Apps loadConfig: ^{setTimeout(^{
        [[[selfRef window] contentView] setSubviews: @[]];
        [selfRef addUI];
        [selfRef resizeUI];
    }, 70);}];
}
- (void) windowDidClose: (NSNotification*) notification {
    setTimeout(^{ //window still visible, call at end of stack to let close take effect
        int visibleWindows = 0;
        for (NSWindow* win in [[NSApplication sharedApplication] windows]) {
            BOOL isMenubarIconWindow = [win level] == NSStatusWindowLevel;
            if (win.isVisible && !isMenubarIconWindow) visibleWindows++;
        }
        if (!visibleWindows) [[NSApplication sharedApplication] setActivationPolicy: NSApplicationActivationPolicyAccessory]; //remove dock icon
    }, 0);
}
- (void) windowDidResize: (NSNotification*) notification {[self resizeUI];}
@end
