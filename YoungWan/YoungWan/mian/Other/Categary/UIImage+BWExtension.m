//
//  UIImage+BWExtension.m
//  WisdomTeacher
//
//  Created by Sigbit on 16/3/23.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "UIImage+BWExtension.h"

@implementation UIImage (BWExtension)

//圆角图片, cornerRadius圆角半径
- (UIImage *)roundedCornerImageWithCornerRadius:(CGFloat)cornerRadius {
    CGFloat w = self.size.width;
    CGFloat h = self.size.height;
    CGFloat scale = [UIScreen mainScreen].scale;
    // 防止圆角半径小于0，或者大于宽/高中较小值的一半。
    if (cornerRadius < 0)
        cornerRadius = 0;
    else if (cornerRadius > MIN(w, h))
        cornerRadius = MIN(w, h) / 2.;
    
    UIImage *image = nil;
    CGRect imageFrame = CGRectMake(0., 0., w, h);
    UIGraphicsBeginImageContextWithOptions(self.size, NO, scale);
    [[UIBezierPath bezierPathWithRoundedRect:imageFrame cornerRadius:cornerRadius] addClip];
    [self drawInRect:imageFrame];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

//圆形图片
- (UIImage *)roundedImage
{
    return [self roundedCornerImageWithCornerRadius:self.size.width * 0.5];
}

@end
