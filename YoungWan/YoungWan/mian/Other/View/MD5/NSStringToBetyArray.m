//
//  NSStringToBetyArray.m
//  YoungWan
//
//  Created by 李明丹 on 16/4/21.
//  Copyright © 2016年 李明丹. All rights reserved.
//

#import "NSStringToBetyArray.h"

struct dictionarys
{
     int code_value;
     int parent_code;
    char character;
} * dicts[TABLE_BANKS];

#define DICT(i) dicts[i>>8][i&0xff]

@implementation NSStringToBetyArray

- (NSData *)encryptString:(NSString *)str
{
    
    //新测试
    NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//    char* src_buffer = NULL;
//    NSString *str2=[[NSString alloc]init];
////    str2=[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    NSString* string5 = [str2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
////    NSString* string7 = [string5 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
//    Byte *testByte = (Byte *)[data bytes];
//    NSInteger number=[data length];
//    Byte byte[number];
//    memcpy(&byte, &testByte[0], number);
//    size_t len=[data length];
//    
//    if (len > 0)
//    {
//        src_buffer = (char*)malloc(len + 1);
//        memcpy(src_buffer, testByte, len);
//        src_buffer[len] = 0;
//    }
    
//    self.number=0;
//     NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
//     //const char * src_buffer = [str UTF8String];
//    
   
    //str2=[str stringByAddingPercentEscapesUsingEncoding:gbkEncoding];
    NSStringEncoding enc =  CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSData *aData =[str dataUsingEncoding:enc];
    char *src_buffer=(char*)[aData bytes];
    //char * src_buffer ="<?xml version=\"1.0\" encoding=\"UTF-8\"?><infobus><trans_code>user_login</trans_code><ptime>2016-08-26 11:24:10.933</ptime><from_system>YOUNG网络</from_system><from_client_id>18:DC:56:21:84:07</from_client_id><from_client_os>Android</from_client_os><from_client_version>1.24</from_client_version><from_client_desc>YOUNG网络</from_client_desc><yc_mobile_operator>无法获取运营商</yc_mobile_operator><yc_using_wifi>Y</yc_using_wifi><msisdn>18825111285</msisdn><user_password>ac59075b964b0715</user_password><domain>GZTZY.GZ</domain><imei>864819029605589</imei><imsi>无法获取IMSI</imsi><is_new_terminal>N</is_new_terminal></infobus>";
    
//    NSLog(@"编码前:%@",str);
//    NSLog(@"编码后:%s",src_buffer);
//    printf("第二种编码后%s",src_buffer);
//     NSString *str2=[[NSString alloc]init];
//     str2=[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//解决中文编码
//     NSString* string4 = [str2 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//     char * src_buffer = [str cStringUsingEncoding:NULL];
   
//    char* src_buffer = NULL;
//    NSData *aData = [str dataUsingEncoding: gbkEncoding];
//    Byte *testByte = (Byte *)[aData bytes];
//    int len=[aData length] ;
//
//    if (len > 0)
//    {
//        src_buffer = (char*)malloc(len + 1);
//        memcpy(src_buffer, testByte, len);
//        src_buffer[len] = 0;
//    }
    
    
    //***************************************************************
//    NSData*keyData = [str dataUsingEncoding:gb2312encoding];
//    char *src_buffer = (char *)malloc(2048*2048);
//    bzero(src_buffer, sizeof(src_buffer));
//    [str getCString:src_buffer maxLength:sizeof(src_buffer) encoding:gbkEncoding];
//    keyData = [NSData dataWithBytes:src_buffer length:sizeof(src_buffer)];
//    NSLog(@"%@\n",keyData);
    //const char * src_buffer = [str cStringUsingEncoding:gbkEncoding];
     int compress_len = 0;
     char * compressed_buffer = (char *)calloc(1024*1024,1);
    [self CompressMZBufferpRawBuffer:src_buffer raw_length:strlen(src_buffer) pCompressedBuffer:compressed_buffer nCompressBufferLen:&compress_len];
    NSData *adata = [[NSData alloc] initWithBytes:compressed_buffer length:strlen(src_buffer)];
    return adata;
}

- (void)CompressMZBufferpRawBuffer:(char *)pRawBuffer raw_length:(int)raw_length  pCompressedBuffer:(char *)pCompressedBuffer nCompressBufferLen:(int * )nCompressBufferLen
{
    BIT_FILE *output;
    output = [self OpenOutputBitBufferbuffer:pCompressedBuffer];
    [self CompressBufferpInput:pRawBuffer nInputLength:raw_length outputFile:output];
    //*pCompressedBuffer = output->buffer;
    *nCompressBufferLen =  output->buffer_position;
    memcpy(pCompressedBuffer,output->buffer,output->buffer_position);
    free((char *)output);
}

- (BIT_FILE *)OpenOutputBitBufferbuffer:(char *)buffer
{
    BIT_FILE *bit_file;
    
    bit_file = (BIT_FILE *)calloc(1, sizeof(BIT_FILE));
    if(bit_file == NULL)
        return(bit_file);
    //bit_file->buffer = buffer;
    bit_file->buffer_position = 0;
    bit_file->buffer_length = 1024*1024;
    bit_file->rack = 0;
    bit_file->mask = 0x80;
    bit_file->pacifier_counter = 0;
    return(bit_file);
}

- (void)CompressBufferpInput:(char *)pInput nInputLength:(int)nInputLength outputFile:(BIT_FILE *)outputFile
{
   long  character, string_code;
   long  index;
    
    
   [self InitializeStorage];
   [self InitializeDictionary];
    string_code = pInput[0];
    
    //MZBitFile outputFile = new MZBitFile();
    
    //printf("nInputLength=%d\n",nInputLength);
    for (int i = 1; i < nInputLength; i++)
    {
       
        character = pInput[i];
        index = [self find_child_nodeparent_code:string_code child_character:character];
       // printf("index=%ld\n",index);
        
        if (DICT(index).code_value != -1)
        {
            string_code = DICT(index).code_value;
        }
        else
        {
            DICT(index).code_value = self.next_code++;
            DICT(index).parent_code = string_code;
            DICT(index).character = (char) character;
//            printf("code_value = %d\n",DICT(index).code_value);
//             printf("parent_code = %d\n",DICT(index).parent_code);
//             printf("character = %@\n",DICT(index).character);
            
            [self OutputBitsbit_file:outputFile code:(DWORD) string_code count:_current_code_bits];
            string_code = character;
            if (_next_code > MAX_CODE)
            {
                [self OutputBitsbit_file:outputFile code:(DWORD) FLUSH_CODE count:_current_code_bits];
                [self InitializeDictionary];
            }
            else if (_next_code > _next_bump_code)
            {
                [self OutputBitsbit_file:outputFile code:(DWORD) BUMP_CODE count:_current_code_bits];
                _current_code_bits++;
                _next_bump_code <<= 1;
                _next_bump_code |= 1;
                //// TCMZCompress::Putc('B');
            }
        }
    }
    [self OutputBitsbit_file:outputFile code:(DWORD) string_code count:_current_code_bits];
    [self OutputBitsbit_file:outputFile code:(DWORD) END_OF_STREAM count:_current_code_bits];
   
    //CloseOutputBitFile(outputFile);
    
    
    if (outputFile->mask != 0x80)
    {
       [self AddByte1:outputFile ch:outputFile->rack];
       
        //outputFile.AddByte1((byte) outputFile.Rack);
    }
    
    //output = (byte[]) outputFile.OutputBuffer.ToArray(typeof (Byte));
    //*pCompressedBuffer = (char *)(&outputFile.write_buffer);
}

- (void)InitializeStorage
{
    int i;
    
    for (i=0; i<TABLE_BANKS; i++)
    {
         //printf("dicts = %d\n",dicts[i]);
        dicts[i] = (struct dictionary *)calloc(256,sizeof(struct dictionarys));
        if (dicts[i] == NULL)
        {
            //?? throw "Error allocating dictionary space";
        }
    }
}

- (void)InitializeDictionary
{
    
    WORD i;
    for (i=0; i<TABLE_SIZE; i++)
        DICT(i).code_value = UNUSED;
    self.next_code = FIRST_CODE;
    //TCMZCompress::Putc('F');
    self.current_code_bits = 9;
    self.next_bump_code = 511;
}

-(WORD)find_child_nodeparent_code:(int )parent_code child_character:(int) child_character
{
#pragma warn -8071
    
    int index=0;
    long offset;
    index = (child_character<<(BITS-8))^parent_code;
    if (index == 0)
        offset = 1;
    else
        offset = TABLE_SIZE - index;
    
    if (index < 0)
    {
        index = index * -1;
    }
    
//    printf("offset = %ld\n",offset);
//    printf("index = %d\n",index);
    
    for (;;)
      {
        //self.number++;
          if (DICT(index).code_value  == UNUSED){
           // printf("number = %d\n",self.number);
              return (WORD)index;
          }
        if (DICT(index).parent_code == parent_code && DICT(index).character == (char)child_character)
            return (index);
        if (index >= offset)
            index -= offset;
        else
            index += TABLE_SIZE-offset;
      }
#pragma warn +8071 
}

- (void)OutputBitsbit_file:(BIT_FILE *)bit_file code:(unsigned long)code count:(int)count
{
    unsigned long mask;
    
    mask = 1L<<(count - 1);
    while(mask != 0)
    {
        if(mask&code)
        {
            bit_file->rack |= bit_file->mask;
        }
        bit_file->mask >>= 1;
        if(bit_file->mask == 0)
        {
            bit_file->buffer[bit_file->buffer_position] = bit_file->rack;
            bit_file->buffer_position ++;
            
            bit_file->rack = 0;
            bit_file->mask = 0x80;
        }
        mask>>=1;
    }
}

- (void)AddByte1:(BIT_FILE * )outputFile ch:(char)ch
{
    outputFile->buffer[outputFile->buffer_position] = ch;
    outputFile->buffer_position ++;
}
@end
