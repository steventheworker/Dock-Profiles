//
//  AppDelegate.h
//  Dock Profiles
//
//  Created by Steven G on 10/15/22.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    __weak IBOutlet NSMenu *menu;
    
    __weak IBOutlet NSButton *hasScreenRecordingBtnInfoBtn;
}

@end
