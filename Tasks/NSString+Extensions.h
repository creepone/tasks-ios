#import <Foundation/Foundation.h>

@interface NSString (Extensions)

/**
 Returns the given string or an instance of NSNull if nil.
 */
+ (id)iaa_stringOrNull:(NSString *)string;

- (BOOL)iaa_isEmptyOrWhitespace;

- (NSString *)iaa_stringBySanitizingFileName;

@end
