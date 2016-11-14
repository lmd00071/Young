//
//  UIImage+BWExtension.h
//  WisdomTeacher
//
//  Created by Sigbit on 16/3/23.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (BWExtension)

//圆角图片, cornerRadius圆角半径
- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius;

//圆形图片
- (UIImage *)roundedImage;

@end
