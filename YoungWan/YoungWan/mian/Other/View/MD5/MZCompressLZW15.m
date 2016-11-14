////
////  MZCompressLZW15.m
////  YoungWan
////
////  Created by 李明丹 on 16/5/17.
////  Copyright © 2016年 李明丹. All rights reserved.
////
//
//#import "MZCompressLZW15.h"
//@interface MZCompressLZW15 ()
//
//@property (nonatomic,strong)NSMutableArray *Dict;
//@property (nonatomic,strong)NSMutableArray *dict;
//
//@end
//@implementation MZCompressLZW15
//
//
//- (NSMutableArray *)dict
//{
//    if (_dict == nil) {
//        
//        self.dict = [NSMutableArray array];
//    }
//    return _dict;
//}
//
//
//- (instancetype)init
//{
//    self.TABLE_SIZE=35023;
//    self.TABLE_BANKS=((self.TABLE_SIZE >> 8) + 1);
//    self.BITS=15;
//    self.MAX_CODE= ((1 << self.BITS) - 1);
//    self.END_OF_STREAM=256;
//    self.BUMP_CODE=257;
//    self.FLUSH_CODE=258;
//    self.FIRST_CODE=259;
//    self.UNUSED=-1;
//    self.decode_stack= *((char*)malloc(12*sizeof(char)));
//    //CompressDictionary dict[self.TABLE_BANKS][256];
//    for (int i=0; i<self.TABLE_BANKS; i++) {
//        for (int j=0; j<256; j++) {
//            CompressDictionary *model=[[CompressDictionary alloc]init];
//            [self.dict addObject:model];
//            
//        }
//    }
//    
//    return self;
//}
//
//
//
//-(void)InitializeDictionary
//{
//    //for (int i = 0; i < TABLE_BANKS; i++)
//    //{
//    //    for (int j = 0; j < 256; j++)
//    //    {
//    //        dict[i, j].CodeValue = UNUSED;
//    //    }
//    //}
//    
//    //for (int i = 0; i < TABLE_BANKS; i++)
//    //{
//    //    DICT(i).CodeValue = UNUSED;
//    //}
//    self.nextCode = self.FIRST_CODE;
//    //TCMZCompress::Putc('F');
//    self.current_code_bits = 9;
//    self.nextBumpCode = 511;
//}
//
///// <summary>
///// 获取压缩规则的字典数据
///// </summary>
///// <param name="index"></param>
///// <returns></returns>
//-(CompressDictionary *)CompressDictionaryDICTindex:(int )index
//{
//    NSInteger x=index >> 8;
//    NSInteger y=index & 0xff;
//    return self.dict[(y-1)*self.TABLE_BANKS+x];
//}
//
///// <summary>
///// 解开一个Buffer
///// </summary>
///// <param name="input"></param>
///// <param name="output"></param>
//-(void)ExpandBufferinput:(Byte *)input output:(Byte *)output
//{
//    short new_code;
//    short oldCode;
//    int character;
//    int count;
//    
//    //[self InitializeStorage];
//    
//    MZBitFile *inputFile =[[MZBitFile alloc]init];
//    inputFile.ReadBuffer = input;
//    for (;;)
//    {
//        [self InitializeDictionary];
//        MZCompressBitio *mzcompressBi=[[MZCompressBitio alloc]init];
//        oldCode = (short)[mzcompressBi InputBitsbit_file:inputFile bit_count:self.current_code_bits];
//        if (oldCode == END_OF_STREAM)
//        {
//            //[self ReleaseStorage];
//            return;
//        }
//        character = oldCode;
//        
//        //[inputFile AddByte:oldCode(bytes)];
//        //inputFile.AddByte((byte) oldCode);
//        
//        for (;;)
//        {
//            MZCompressBitio *mzcompressB=[[MZCompressBitio alloc]init];
//            new_code = (short)[mzcompressB InputBitsbit_file:inputFile bit_count:self.current_code_bits];
//            if (new_code == END_OF_STREAM)
//            {
//               // [self ReleaseStorage];
//                //output = (byte[])inputFile.OutputBuffer.ToArray(typeof(Byte));
//                return;
//            }
//            if (new_code == FLUSH_CODE)
//                break;
//            
//            if (new_code == BUMP_CODE)
//            {
//                self.current_code_bits++;
//                //TCMZCompress::Putc('B');
//                continue;
//            }
//            if (new_code >=self.nextCode)
//            {
//                decode_stack[0] = (char) character;
//                count = DecodeString(1, oldCode);
//            }
//            else
//                count = DecodeString(0, new_code);
//            
//            character = decode_stack[count - 1];
//            
//            while (count > 0)
//            {
//                inputFile.AddByte((byte) decode_stack[--count]);
//            }
//            
//            CompressDictionary *model=[[CompressDictionary alloc]init];
//            model=[self CompressDictionaryDICTindex:self.nextCode];
//            model.ParentCode=oldCode;
//            model.Character=(short)character;
//            NSInteger x=self.nextCode >> 8;
//            NSInteger y=self.nextCode & 0xff;
//            [self.dict replaceObjectAtIndex:((y-1)*self.TABLE_BANKS+x) withObject:model];
////            DICT(self.nextCode).ParentCode = oldCode;
////            DICT(self.nextCode).Character = (char) character;
//            self.nextCode++;
//            oldCode = new_code;
//        }
//    }
//}
//
///// <summary>
///// 压缩一个Buffer
///// </summary>
///// <param name="input"></param>
///// <param name="output"></param>
//internal byte[] CompressBuffer(byte[] input)
//{
//    int character, stringCode;
//    int index;
//    
//    InitializeStorage();
//    InitializeDictionary();
//    stringCode = input[0];
//    
//    MZBitFile outputFile = new MZBitFile();
//    
//    for (int i = 1; i < input.Length; i++)
//    {
//        character = input[i];
//        index = FindChildNode(stringCode, character);
//        if (DICT(index).CodeValue != -1)
//        {
//            stringCode = DICT(index).CodeValue;
//        }
//        else
//        {
//            DICT(index).CodeValue = nextCode++;
//            DICT(index).ParentCode = stringCode;
//            DICT(index).Character = (char) character;
//            
//            MZCompressBitio.OutputBits(outputFile, (short) stringCode, current_code_bits);
//            stringCode = character;
//            if (nextCode > MAX_CODE)
//            {
//                MZCompressBitio.OutputBits(outputFile, (short) FLUSH_CODE, current_code_bits);
//                InitializeDictionary();
//            }
//            else if (nextCode > nextBumpCode)
//            {
//                MZCompressBitio.OutputBits(outputFile, (short) BUMP_CODE, current_code_bits);
//                current_code_bits++;
//                nextBumpCode <<= 1;
//                nextBumpCode |= 1;
//                //// TCMZCompress::Putc('B');
//            }
//        }
//    }
//    MZCompressBitio.OutputBits(outputFile, (short) stringCode, current_code_bits);
//    MZCompressBitio.OutputBits(outputFile, (short) END_OF_STREAM, current_code_bits);
//    if (outputFile.Mask != 0x80)
//    {
//        outputFile.AddByte((byte) outputFile.Rack);
//    }
//    return (byte[]) outputFile.OutputBuffer.ToArray(typeof (Byte));
//}
//
///// <summary>
///// 寻找下一个节点
///// </summary>
///// <param name="parentCode"></param>
///// <param name="childCharacter"></param>
///// <returns></returns>
//private int FindChildNode(int parentCode, int childCharacter)
//{
//    int index;
//    int offset;
//    index = (childCharacter << (BITS - 8)) ^ parentCode;
//    if (index == 0)
//        offset = 1;
//    else
//        offset = TABLE_SIZE - index;
//    for (;;)
//    {
//        if (DICT(index).CodeValue == UNUSED)
//            return (short) index;
//        if (DICT(index).ParentCode == parentCode &&
//            DICT(index).Character == (char) childCharacter)
//            return (index);
//        if (index >= offset)
//        {
//            index -= (short) offset;
//        }
//        else
//        {
//            index += TABLE_SIZE - offset;
//        }
//    }
//}
//
///// <summary>
///// 反编码
///// </summary>
///// <param name="count"></param>
///// <param name="code"></param>
///// <returns></returns>
//private int DecodeString(short count, short code)
//{
//    while (code > 255)
//    {
//        decode_stack[count++] = DICT(code).Character;
//        code = (short) DICT(code).ParentCode;
//    }
//    decode_stack[count++] = (char) code;
//    return (count);
//}
//
///// <summary>
///// 初始化压缩字典表数据
///// </summary>
//- (void)InitializeStorage
//{
//    
//        for (i=0; i<TABLE_BANKS; i++)
//        {
//            dicts[i] = (struct dictionary *)calloc(256,sizeof(struct dictionarys));
//            if (dicts[i] == NULL)
//            {
//                //?? throw "Error allocating dictionary space";
//            }
//        }
//
//    for (int i = 0; i < TABLE_BANKS; i++)
//    {
//        for (int j = 0; j < 256; j++)
//        {
//            dict[i, j] = new CompressDictionary();
//            dict[i, j].CodeValue = UNUSED;
//        }
//    }
//}
//
//-(void)ReleaseStorage
//{
//    
//}
//
//@end
