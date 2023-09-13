//
//  dockHelpers.h
//  Dock Profiles
//
//  Created by Steven G on 9/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface dockHelpers : NSObject
+ (NSDictionary*) dockItemDictWithType : (long) type;
+ (NSDictionary*) dockItemDictWithURL : (NSURL*) url;
@end

NS_ASSUME_NONNULL_END
