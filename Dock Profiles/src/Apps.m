//
//  Apps.m
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import "Apps.h"

@implementation Apps
+ (NSDictionary*) getAppDict : (NSString*) name : (NSString*) path {
    return @{
        @"name": name,
        @"path": path
    };
}
@end
