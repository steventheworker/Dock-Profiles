//
//  prefs.m
//  Dock Profiles
//
//  Created by Steven G on 9/8/23.
//

#import "prefs.h"

//grab pref & use default value if unset
BOOL getBoolPref(NSString* key, BOOL defaultVal) {id val = [[NSUserDefaults standardUserDefaults] valueForKey: key];return (val == nil) ? defaultVal : [val boolValue];}
BOOL getStringPref(NSString* key, NSString* defaultVal) {id val = [[NSUserDefaults standardUserDefaults] valueForKey: key];return (val == nil) ? defaultVal : [val stringValue];}
BOOL getIntegerPref(NSString* key, int defaultVal) {id val = [[NSUserDefaults standardUserDefaults] valueForKey: key];return (val == nil) ? defaultVal : [val integerValue];}
BOOL getDoublePref(NSString* key, double defaultVal) {id val = [[NSUserDefaults standardUserDefaults] valueForKey: key];return (val == nil) ? defaultVal : [val doubleValue];}
BOOL getFloatPref(NSString* key, float defaultVal) {id val = [[NSUserDefaults standardUserDefaults] valueForKey: key];return (val == nil) ? defaultVal : [val floatValue];}

@implementation prefs
+ (NSDictionary*) load {
    NSMutableDictionary* ret = [NSMutableDictionary dictionary];
    ret[@"showMenubarIcon"] = @(getBoolPref(@"showMenubarIcon", YES));
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
