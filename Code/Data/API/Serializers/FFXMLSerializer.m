//
//  PDXMLSerializer.m
//  ParseDemo
//
//  Created by matata on 23.04.14.
//  Copyright (c) 2014 matata. All rights reserved.
//

#import "FFXMLSerializer.h"
#import <XMLDictionary/XMLDictionary.h>

@implementation FFXMLSerializer

+ (instancetype)serializer {
    FFXMLSerializer * serializer = [[self alloc] init];
    return serializer;
}
- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", @"text/html", nil];
    return self;
}

#pragma mark - AFURLResponseSerialization

static BOOL AFErrorOrUnderlyingErrorHasCode(NSError *error, NSInteger code) {
    if (error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return AFErrorOrUnderlyingErrorHasCode(error.userInfo[NSUnderlyingErrorKey], code);
    }
	
    return NO;
}
- (id)responseObjectForResponse:(NSHTTPURLResponse *)response data:(NSData *)data error:(NSError *__autoreleasing *)error {
	
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (AFErrorOrUnderlyingErrorHasCode(*error, NSURLErrorCannotDecodeContentData)) {
            return nil;
        }
    }
	
    return [NSDictionary dictionaryWithXMLData:data];
}

@end
