////
////  NSString+MD5.m
////  YoungWan
////
////  Created by 李明丹 on 16/4/20.
////  Copyright © 2016年 李明丹. All rights reserved.
////
//
//#import "NSString+MD5.h"
//#include <stdio.h>
//#include <string.h>
//#include <unistd.h>
//#include <sys/types.h>
//#include <arpa/inet.h>
//#include <netinet/in.h>
//#include <sys/socket.h>
//#include <ctype.h>
//#include <sys/stat.h>
//#include <fcntl.h>
//#include <stdlib.h>
//#include <pthread.h>
//
//#import <CommonCrypto/CommonDigest.h>
//
//#define	SERVER_INFO_IP		"client_server"
//#define  CLIENT_VERSION		"8.0.0"
//struct info_drv  infoDrv;
//char g_username[128]="";
//int SendLogin(struct info_drv * drv);
//int Send_Keep_Alive(struct info_drv* drv );
//@implementation NSString (MD5)
//
//int  SendLogin(struct info_drv * drv )
//{
//    char buf[1500];
//    char * ptr;
//    int total_len =0;
//    char mydate[1024];
//    char md5sum[64];
//    
//    memset(&drv->ctrl, 0, sizeof(drv->ctrl));
//    NSDate *currentTime=[NSDate date];
//    //创建一个 格式 对象
//    NSDateFormatter *formater=[[NSDateFormatter alloc]init];
//    //设置具体格式
//    [formater setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString *timeStr=[formater stringFromDate:currentTime];
//    NSString *ptime=[timeStr stringByAppendingString:@".096"];
//    const char *StrLogin_Time=[ptime UTF8String];
//    strcpy(mydate,StrLogin_Time);
//    
//    memset(buf,0,sizeof(buf));
//    ptr = buf;
//    //
//    ptr += HEAD_PACK_LEN;
//    total_len+=HEAD_PACK_LEN;
//    //
//    //
//    MakeAttPack(&ptr,1,strlen(g_username),g_username,&total_len);
//    
//    
//    //att 3 version
//    MakeAttPack(&ptr,3,strlen(CLIENT_VERSION),CLIENT_VERSION,&total_len);
//    
//    //att 8 random
//    MakeAttPack(&ptr,8,strlen(mydate),mydate,&total_len);
//    
//    // att66 exeMD5
//   //  get_apple_md5(md5sum);
//    MakeAttPack(&ptr,66,strlen(md5sum),md5sum,&total_len);
//    
//    //
//    MakeHeadPack_info(buf,97,total_len);
//    //
//    amt_cry((unsigned char  *)buf,total_len);
//    //
//    SendAuthData(drv->sock,buf,total_len,drv->cfg.g_Auth_AuthIp, AUTH_PORT);
//    
//    
//    return 1;
//}
//
//int Send_Keep_Alive(struct info_drv * drv )
//{
//    char buf[1500];
//    char * ptr;
//    int total_len =0;
//    
//    //≥ı ºªØ
//    memset(buf,0,sizeof(buf));
//    ptr = buf;
//    //Ã¯π˝∞¸Õ∑
//    ptr += HEAD_PACK_LEN;
//    total_len+=HEAD_PACK_LEN;
//    //∫œ≥…∞¸ƒ⁄»›
//    
//    //”√ªß√˚-----∏˘æ›»œ÷§¿‡–Õ£¨»∑∂®”√ ≤√¥’À∫≈∑¢«Î«Û
//    MakeAttPack(&ptr,1,strlen(g_username),g_username,&total_len);
//    
//    
//    //att 8 random
//    MakeAttPack(&ptr,8,strlen(drv->RamdomBuf),drv->RamdomBuf,&total_len);
//    
//    
//    //att 3 version
//    MakeAttPack(&ptr,3,strlen(CLIENT_VERSION),CLIENT_VERSION,&total_len);
//    
//    //…˙≥…∞¸Õ∑
//    MakeHeadPack_info(buf,99,total_len);
//    //º”√‹
//    amt_cry((unsigned char  *)buf,total_len);
//    //∑¢ÀÕ
//    SendAuthData(drv->sock,buf,total_len,drv->cfg.g_Auth_AuthIp,AUTH_PORT);
//    
//    return 1;
//}
//
//void
//MakeAttPack(char **ptr,int packtype,int len,void *att,int * totallen)
//{
//    char * buf;
//    buf = *ptr;
//    
//    *buf = packtype;
//    buf ++;
//    *buf = len+2;
//    buf ++;
//    memcpy(buf,att,len);
//    
//    *ptr += len+2;
//    *totallen += len+2;
//    
//}
//
//+(int)md5HexDigest:(char  * )out1{
//    
//    u_char buf[128];
//    u_char v[32];
//    int i;
//    
//    out1[0] = '\0';
//    strcpy(buf, g_username);
//    strcat(buf, "amnoon copyright spec apple ver");
//    
//    [self md5_calcOutput:v input:buf inlen:strlen(buf) chg:1];
//    
//    for( i = 0; i < 16; i++)
//        sprintf(out1+strlen(out1), "%02x", v[i]);
//        memcpy(out1, "apple", 5);
//   
//    
//    return 0;
//}
//
//void MakeHeadPack_info(char *ptr,int headtype,int total_len)
//{
//    unsigned char md5Out[16];
//    unsigned char * buf;
//    buf = (unsigned char *)ptr;
//    
//    *ptr = headtype;
//    ptr ++;
//    *ptr = total_len;
//    ptr ++;
//    
//    //md5_calc(md5Out, buf, total_len, 1);
//    memcpy(ptr,md5Out,16);
//    
//}
//
//int  amt_cry(unsigned char *sendchar,int charlen)
//{
//    
//    int	i;
//    unsigned char	ch;
//    if (charlen <= 0) return 0;
//    if (sendchar == NULL) return 0;
//    for (i = 0; i < charlen ; i++)
//    {
//        ch = ((sendchar[i] & 0x01) << 7) |
//        ((sendchar[i] & 0x02) >> 1) |
//        ((sendchar[i] & 0x04) << 2) |
//        ((sendchar[i] & 0x08) << 2) |
//        ((sendchar[i] & 0x10) << 2) |
//        ((sendchar[i] & 0x20) >> 2) |
//        ((sendchar[i] & 0x40) >> 4) |
//        ((sendchar[i] & 0x80) >> 6);
//        sendchar[i] = ch;
//    }
//    
//    return 1;
//}
//
//int SendAuthData(int socket,char * buf,int buf_len,char * ip,int port)
//{
//    struct	sockaddr_in ser;
//    int serlen = sizeof(struct sockaddr_in);
//    
//    ser.sin_family  = AF_INET;
//    ser.sin_addr.s_addr = inet_addr(ip);
//    ser.sin_port    = htons(port);
//    
//    return sendto(socket,buf,buf_len,0,(struct sockaddr *)&ser,serlen);
//}
//
//+ (int)md5_calcOutput:(u_char *)output input:(u_char *)input inlen:(u_int)inlen chg:(int)chg
//{
//    //const char* str = [input UTF8String];
//    CC_MD5_CTX	context;
//    CC_MD5_Init(&context);
//    CC_MD5_Update(&context, output, inlen);
//    unsigned char result[CC_MD5_DIGEST_LENGTH];
//    CC_MD5_Final(result, &context);
//    return 0;
//}
//
//@end
