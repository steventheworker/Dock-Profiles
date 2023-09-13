//
//  profileEditorWindowController.m
//  Dock Profiles
//
//  Created by Steven G on 9/9/23.
//

#import "profileEditorWindowController.h"
#import "globals.h"
#import "helper-lib.h"
#import "dockHelpers.h"
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




- (void) setDock {
    
    //NSDictionary* DockFileDataDictionaryForURL(NSURL* url) {
    //  base::apple::ScopedCFTypeRef<CFPropertyListRef> property_list(_CFURLCopyPropertyListRepresentation(base::apple::NSToCFPtrCast(url)));
    //  CFDictionaryRef dictionary = base::apple::CFCast<CFDictionaryRef>(property_list);
    //  if (!dictionary) return nil;
    //  return base::apple::CFToNSOwnershipCast((CFDictionaryRef)property_list.release());
    //}

    NSString* installed_path = @"/Users/super/Desktop/iCloud Photos";
//    CFArrayRef ray = CFArrayCreate(NULL, NULL, 0, NULL); //empty array
    NSMutableArray* ray = [NSMutableArray array];
    // Set up the new Dock tile.
    NSURL* url = [NSURL fileURLWithPath:installed_path isDirectory:YES];
    NSDictionary* url_dict = [dockHelpers dockItemDictWithURL: url];
    if (!url_dict) return NSLog(@"couldn't make url_dict");
//    NSDictionary* new_tile_data = @{@"file-data" : url_dict};
//    NSDictionary* new_tile = @{@"tile-data" : new_tile_data};
    NSDictionary* new_tile = [dockHelpers dockItemDictWithURL: url];
    
    // Add the new tile to the Dock.
    [ray insertObject:new_tile atIndex:0];
  
    CFPreferencesSetAppValue(CFSTR("persistent-apps"), (__bridge CFArrayRef) ray, CFSTR("com.apple.dock"));
    CFPreferencesAppSynchronize(CFSTR("com.apple.dock"));
    [helperLib killDock];
}
@end
