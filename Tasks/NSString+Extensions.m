#import "NSString+Extensions.h"

@implementation NSString (Extensions)

- (BOOL)iaa_isEmptyOrWhitespace {
	// A nil or NULL string is not the same as an empty string
	return 0 == self.length ||
	![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (NSString *)iaa_stringBySanitizingFileName {
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"/\\?%*|\"<>"];
    return [[self componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@""];
}

@end
