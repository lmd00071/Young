//
//  NSString+CSVDictionary.h
//  demo2
//
//  Created by Sigbit on 16/1/8.
//  Copyright © 2016年 sigbit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CSVDictionary)

- (NSArray <NSDictionary *>*)csvStringTransformToDictionary;

- (UIColor *)hexadecimalStringToColor;

@end
