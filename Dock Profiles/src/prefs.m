//
//  prefs.m
//  Dock Profiles
//
//  Created by Steven G on 9/8/23.
//

#import "prefs.h"

@implementation prefs
+ (NSDictionary*) load {
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    ret[@"showMenubarIcon"] = @([[NSUserDefaults standardUserDefaults] boolForKey: @"showMenubarIcon"]);

    return ret;
}
+ (void) checkMenubarIcon: (id) sender : (App*) app {
    [app toggleMenuIcon];
    [[NSUserDefaults standardUserDefaults] setBool: ((BOOL) [sender state]) forKey: @"showMenubarIcon"];
}
+ (void) render: (NSWindow*) win {
    for (NSView* el in [[win contentView] subviews]) {
        if ([el isKindOfClass:[NSButton class]]) {
            NSButton* menuCheckbox = (NSButton*) el;
            [menuCheckbox setState: [[self load][@"showMenubarIcon"] boolValue]];
        }
    }
}
@end
