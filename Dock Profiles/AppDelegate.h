//
//  AppDelegate.h
//  Dock Profiles
//
//  Created by Steven G on 10/15/22.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    //permissions
    @public AXUIElementRef          _systemWideAccessibilityObject;
        
    //system vars
    @public float           primaryScreenHeight;
    @public float           primaryScreenWidth;
    @public float           extendedOffsetX;
    @public float           extendedOffsetY;
    @public float           extendedOffsetYBottom;
    @public float           extScreenWidth;
    @public float           extScreenHeight;
    @public CGFloat         dockWidth;
    @public CGFloat         dockHeight;
    @public NSString*       dockPos;
    pid_t                  dockPID;

    //app vars
    NSString*              appVersion;
    NSString*              mostCurrentVersion;

    //UI
    
}
- (void) bindClick: (CGEventRef) e : (CGEventType) type;
- (void) bindScreens;
@end

