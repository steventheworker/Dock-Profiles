//
//  prefsWindowController.m
//  Dock Profiles
//
//  Created by Steven G on 9/9/23.
//

#import "prefsWindowController.h"
#import "prefs.h"
#import "globals.h"
#import "Apps.h"
@import UniformTypeIdentifiers;

@interface prefsWindowController ()

@end

@implementation prefsWindowController
- (void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] // on window closed
        addObserver: self
        selector: @selector(windowDidClose:)
        name: NSWindowWillCloseNotification
        object: [self window]];
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
- (void) exportData {
    NSData* jsonData = [[NSUserDefaults standardUserDefaults] dataForKey: @"data"];
    NSError* error;
    NSSavePanel* savePanel = [NSSavePanel savePanel];
    [savePanel setAllowedContentTypes: @[UTTypeJSON]]; // Restrict to JSON files
    [savePanel setAllowsOtherFileTypes: NO];
    [savePanel setExtensionHidden: NO];
    [savePanel setCanCreateDirectories: YES];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd-HH-mm-ss"];
    NSString* currentDateTime = [dateFormatter stringFromDate: [NSDate date]];
    [savePanel setNameFieldStringValue: [@"Dock Profiles Backup " stringByAppendingString: currentDateTime]];
    NSInteger result = [savePanel runModal];
    if (result != NSModalResponseOK) return;
    NSURL* selectedURL = [savePanel URL];
    if ([jsonData writeToURL: selectedURL options: NSDataWritingAtomic error: &error]) NSLog(@"JSON file saved successfully to %@", selectedURL);
    else NSLog(@"Error saving JSON file: %@", error);
}
- (void) importData {
    NSAlert* alert = [[NSAlert alloc] init];
    [alert setMessageText: @"Enter Text"];
    [alert setInformativeText: @"Paste backup contents:"];
    [alert addButtonWithTitle: @"Import Data"];
    [alert addButtonWithTitle: @"Cancel"];
    NSTextField* inputTextField = [[NSTextField alloc] initWithFrame: NSMakeRect(0, 0, 200, 24)];
    [inputTextField setStringValue: @""];
    [alert setAccessoryView: inputTextField];
    NSInteger button = [alert runModal];
    if (button != NSAlertFirstButtonReturn) return;
    [Apps processImportedTxt: [inputTextField stringValue]];
}
@end
