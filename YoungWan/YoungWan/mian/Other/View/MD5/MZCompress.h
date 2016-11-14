//
//  MZCompress.h
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MZCompressLZW15.h"
@interface MZCompress : NSObject
-( void)CompressMZFilesRawFile:(NSString *)sRawFile sCompressedFile:(NSString*)sCompressedFile bDeleteOriginalFile:(bool)bDeleteOriginalFile;

-(Byte *) CompressBufferbsSource:(Byte * )bsSource;

-( void) ExpandMZFilesCompressedFile:(NSString *)sCompressedFile sExpandedFile:(NSString *)sExpandedFile bDeleteOriginalFile:(bool)bDeleteOriginalFile;
@end
