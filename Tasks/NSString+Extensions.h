#import <Foundation/Foundation.h>

@interface NSString (Extensions)

- (BOOL)iaa_isEmptyOrWhitespace;

- (NSString *)iaa_stringBySanitizingFileName;

@end
