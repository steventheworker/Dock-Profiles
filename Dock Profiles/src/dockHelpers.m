//
//  dockHelpers.m
//  Dock Profiles
//
//  Created by Steven G on 9/12/23.
//

#import "dockHelpers.h"

typedef NS_ENUM(NSInteger, DockTileType) {
    DockTileTypeFile,
    DockTileTypeDirectory,
    DockTileTypeURL,
    DockTileTypeSpacer,
    DockTileTypeSmallSpacer,
    DockTileTypeFlexSpacer
};

typedef NS_ENUM(NSInteger, DockSection) {
    DockSectionUnknown,
    DockSectionPersistentApps,
    DockSectionOther,
    DockSectionRecentApps
};


//  {  GUID = 1706939552;
//    "tile-data" =             {
//        book = {length = 592, bytes = 0x626f6f6b 50020000 00000410 30000000 ... 04000000 00000000 };
//        "bundle-identifier" = "com.apple.TV";
//        "dock-extra" = 0;
//        "file-data" =                 {
//            "_CFURLString" = "file:///System/Applications/TV.app/";
//            "_CFURLStringType" = 15;
//        };
//        "file-label" = TV;
//        "file-mod-date" = 3665116737;
//        "file-type" = 41;
//        "parent-mod-date" = 3665366337;
//    };
//    "tile-type" = "file-tile"; }

NSMutableDictionary* emptyTile(void) {
    uint32_t newGUID = arc4random_uniform(1000000000) + 1000000000;
    return [NSMutableDictionary dictionaryWithDictionary: @{@"guid": @((int) newGUID)}];
}

@implementation dockHelpers
+ (NSDictionary*) dockItemDictWithType : (long) type {//DockTileTypeURL DockTileTypeFile DockTileTypeSpacer DockTileTypeDirectory DockTileTypeFlexSpacer DockTileTypeSmallSpacer
    NSMutableDictionary* ret = emptyTile();
    NSString* recognizedTypeString = @"";
    switch(type) {
        case DockTileTypeURL: recognizedTypeString = @"url-tile";break;
        case DockTileTypeFile: recognizedTypeString = @"file-tile";break;
        case DockTileTypeSpacer: recognizedTypeString = @"spacer-tile";break;
        case DockTileTypeDirectory: recognizedTypeString = @"directory-tile";break;
        case DockTileTypeFlexSpacer: recognizedTypeString = @"flex-spacer-tile";break;
        case DockTileTypeSmallSpacer: recognizedTypeString = @"small-spacer-tile";break;
        default: NSLog(@"unrecognized tile type");return ret;break;
    }
    ret[@"tile-type"] = recognizedTypeString;
    ret[@"tile-data"] = @{@"file-label": @""};
    return ret;
}
+ (NSDictionary*) dockItemDictWithURL : (NSURL*) url {
    NSMutableDictionary* ret = emptyTile();
    ret[@"tile-data"] = @{
//        book = {length = 612, bytes = 0x626f6f6b 64020000 00000410 30000000 ... 04000000 00000000 };
        @"bundle-identifier": @"com.steventheworker.DockAltTab", //app alias produces ":no-bundle:1296122707"
        @"dock-extra": @0, //??????
        @"file-data": @{
            @"_CFURLString": [url absoluteString], //"file:///Applications/MyApps/DockAltTab.app" "file:///Users/super/Desktop/important/SystemFiles/Spotlight%20Search.app/"
            @"_CFURLStringType": @15 //??????
        },
        @"file-label": @"DockAltTab",
        @"file-mod-date": @244215617621445,
        @"file-type": @45, //alias=45, but actual .app=41
        @"is-beta": @0,
        @"parent-mod-date": @194278032834572
    };
    ret[@"tile-type"] = @"file-tile";
    return ret;
}
@end
