//
//  Apps.h
//  Dock Profiles
//
//  Created by Steven G on 10/23/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Apps : NSObject
+ (NSDictionary*) getAppDict : (NSString*) name : (NSString*) path;
@end

NS_ASSUME_NONNULL_END
