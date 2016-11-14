//
//  MZCompress.m
//  YoungWan
//
//  Created by 李明丹 on 16/5/17.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "MZCompress.h"

@implementation MZCompress

-( void)CompressMZFilesRawFile:(NSString *)sRawFile sCompressedFile:(NSString*)sCompressedFile bDeleteOriginalFile:(bool)bDeleteOriginalFile
{
//    if (File.Exists(sRawFile))
//    {
//        FileStream fs = File.OpenRead(sRawFile);
//        int nFileSize = (int) fs.Length;
//        byte[] bsFileContent = new byte[nFileSize];
//        fs.Read(bsFileContent, 0, nFileSize);
//        fs.Close();
//        byte[] bsResult = null;
//        
//        bsResult = CompressBuffer(bsFileContent);
//        FileStream fsOutput = File.OpenWrite(sCompressedFile);
//        fsOutput.Write(bsResult, 0, bsResult.Length);
//        fsOutput.Close();
//        
//    }
}

//-(Byte *) CompressBufferbsSource:(Byte * )bsSource
//{
//    MZCompressLZW15 *compressLzw15 =[[MZCompressLZW15 alloc]init];;
//    return compressLzw15.CompressBuffer(bsSource);
//}

/// <summary>
/// 解压文件
/// </summary>
/// <param name="sCompressedFile"></param>
/// <param name="sExpandedFile"></param>
/// <param name="bDeleteOriginalFile"></param>

//-( void) ExpandMZFilesCompressedFile:(NSString *)sCompressedFile sExpandedFile:(NSString *)sExpandedFile bDeleteOriginalFile:(bool)bDeleteOriginalFile
//{
//    if (File.Exists(sCompressedFile))
//    {
//        FileStream fs = File.OpenRead(sCompressedFile);
//        int nFileSize = (int)fs.Length;
//        byte[] bsFileContent = new byte[nFileSize];
//        fs.Read(bsFileContent, 0, nFileSize);
//        fs.Close();
//        byte[] bsResult = null;
//        
//        ExpandBuffer(bsFileContent, ref bsResult);
//        FileStream fsOutput = File.OpenWrite(sExpandedFile);
//        fsOutput.Write(bsResult, 0, bsResult.Length);
//        fsOutput.Close();
//        
//    }
//}


//-(void)ExpandBufferbsSource:(Byte *)bsSource, ref byte[] bsResult)
//{
//    MZCompressLZW15 compressLzw15 = new MZCompressLZW15();
//    compressLzw15.ExpandBuffer(bsSource, ref bsResult);
//}
//
///// <summary>
///// 显示进度的回调函数
///// </summary>
///// <param name="c"></param>
////public void Putc(int c)
////{
//
////}
//}

@end
