//
//  BWHttpRequestManager.m
//  WidomStudy
//
//  Created by Sigbit on 16/3/4.
//  Copyright © 2016年 Sigbit. All rights reserved.
//

#import "BWHttpRequestManager.h"

#import <FCUUID/UIDevice+FCUUID.h>
#import "NSStringToBetyArray.h"
@implementation BWHttpRequestManager


//判断数据是否过期,过期则网络请求,未过期则直接显示
- (BWHttpRequestDataStatus)isNeedHttpRequestWithAction:(NSString *)action action_parameter:(NSString *)action_parameter
{
    NSString *selectString = [NSString stringWithFormat:@"SELECT * FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, action_parameter];
    NSArray *csvModelArray = [BWCSVDatabase queryData:selectString];
    
    if (csvModelArray.count > 0) {
        BWCSVModel *model = csvModelArray.firstObject;
        if ([NSDate isLaterTimeThanNowWithDateString:model.overdueTime]) {    //未超时,直接赋值
            return BWHttpRequestDataStatusNoOverdue;
        } else {    //超过存储时间,进行请求
            return BWHttpRequestDataStatusOverdue;
        }
    } else {    //没有数据
        return BWHttpRequestDataStatusNoData;
    }
}

//进行数据获取
- (NSArray<NSDictionary *> *)httpRequestManagerGetDataWithAction:(NSString *)action action_parameter:(NSString *)action_parameter csvKey:(NSString *)csvKey
{
    NSString *selectString = [NSString stringWithFormat:@"SELECT * FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, action_parameter];
    NSArray *csvModelArray = [BWCSVDatabase queryData:selectString];
    
    NSArray *dataArray;
    for (BWCSVModel *csvModel in csvModelArray) {
        
        if ([csvModel.csvType isEqualToString:csvKey]) {    //数据csv对应的模型
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
            NSString *dataString = [NSString stringWithContentsOfFile:csvPath encoding:NSUTF8StringEncoding error:nil];
            dataArray = [dataString csvStringTransformToDictionary];
        }
    }
    return dataArray;
}

//自定义请求头的网络请求
- (void)httpRequestManagerWithRequest:(NSMutableURLRequest *)request comdata:(NSData *)comdata dataBlock:(void (^)(NSDictionary *))dataBlock
{
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
//    [SVProgressHUD showWithStatus:@"正在请求数据中..."];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    //拿到dns服务器的请求
    NSURLSessionDataTask *dnsTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error) {
            [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
            return;
        }
        NSDictionary *dnsDict = [NSDictionary dictionaryWithXMLData:data];
       request.URL = [NSURL URLWithString:dnsDict[@"dns.url"]];
        request.HTTPBody=comdata;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //拿到csv文件url的请求
            NSURLSessionDataTask *csvTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"网络请求超时"];
                        return;
                    });
                }
                
                NSDictionary *dataDict = [NSDictionary dictionaryWithXMLData:data];
                NSString *str=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
                NSLog(@"%@",str);
                NSLog(@"%@",dataDict);
                
                if (dataDict) {
                    dataBlock(dataDict);
                    [SVProgressHUD dismiss];
                } else {
                    
                    [SVProgressHUD showErrorWithStatus:@"暂未成功获取数据,请检查网络情况稍后重试!"];
                }
                
                
            }];
            [csvTask resume];
        });
    }];
    [dnsTask resume];
}

//无默认参数的网络请求
- (void)httpRequestManagerNoParameterWithDictionary:(NSMutableDictionary *)parameters dataBlock:(void (^)(NSDictionary *))dataBlock
{
    NSString * xmlString = [parameters newXMLString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:BWBaseUrlString]];
    [request addValue:@"text/xml;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
 
    NSStringToBetyArray *tool=[[NSStringToBetyArray alloc]init];
   // NSString *str=@"<?xml version=\"1.0\" encoding=\"UTF-8\"?><infobus><trans_code>user_login</trans_code><ptime>2016-08-26 16:57:10.933</ptime><from_system>YOUNG</from_system><from_client_id>18:DC:56:21:84:07</from_client_id><from_client_os>Android</from_client_os><from_client_version>1.24</from_client_version><from_client_desc>YOUNG</from_client_desc><yc_mobile_operator>wufahuoquyuyingshang</yc_mobile_operator><yc_using_wifi>Y</yc_using_wifi><msisdn>18825111285</msisdn><user_password>ac59075b964b0715</user_password><domain>GZTZY.GZ</domain><imei>864819029605589</imei><imsi>wufahuoquIMSI</imsi><is_new_terminal>N</is_new_terminal></infobus>";
    NSData *data=[tool encryptString:xmlString];
     NSData *adata =[xmlString dataUsingEncoding:NSUTF8StringEncoding];;
    request.HTTPBody =adata;
    //request.HTTPBody = [xmlString dataUsingEncoding:gbkEncoding];
    request.HTTPMethod = @"POST";
    
    [self httpRequestManagerWithRequest:request comdata:data dataBlock:dataBlock];
}

//带默认参数的网络请求
- (void)httpRequestManagerSetupRequestWithParametersDictionary:(NSMutableDictionary *)parameters action:(NSString *)action actionParameter:(NSString *)actionParameter hasParameter:(BOOL)hasParameter dataBlock:(void (^)(NSDictionary *))dataBlock
{

    [self httpRequestManagerNoParameterWithDictionary:parameters dataBlock:dataBlock];
}

//ui_show类型的界面
- (void)httpRequestManagerUIShowRequestWithAction:(NSString *)action actionParameter:(NSString *)actionParameter hasParameter:(BOOL)hasParameter dataBlock:(void (^)(NSDictionary *))dataBlock
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"trans_code"] = @"ui_show";
    [self httpRequestManagerSetupRequestWithParametersDictionary:dict action:action actionParameter:actionParameter hasParameter:hasParameter dataBlock:dataBlock];
}

//根据请求到的csv地址进行数据处理
- (NSArray<NSDictionary *> *)setupDatabaseWithCsvDict:(NSDictionary *)csvDict action:(NSString *)action actionParameter:(NSString *)actionParameter csvKey:(NSString *)csvKey
{
    //删除之前的csv文件
    NSString *selectString = [NSString stringWithFormat:@"SELECT * FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, actionParameter];
    NSArray *overModelArray = [BWCSVDatabase queryData:selectString];
    NSFileManager *manager = [NSFileManager defaultManager];
    for (BWCSVModel *csvModel in overModelArray) {
        
        NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
        [manager removeItemAtPath:csvPath error:nil];
    }
    
    NSString *deleteData = [NSString stringWithFormat:@"DELETE FROM csv_path WHERE action='%@' AND action_parameter='%@'", action, actionParameter];
    [BWCSVDatabase deleteData:deleteData];
    
    //将新数据写入沙盒
    NSArray *csvModelArray = [BWCSVDatabase writeCsvWithCsvDict:csvDict action:action action_parameter:actionParameter];
    NSArray *dataArray;
    for (BWCSVModel *csvModel in csvModelArray) {
        
        //插入数据
        [BWCSVDatabase insertModal:csvModel];
        
        if ([csvModel.csvType isEqualToString:@"template_data_csv"]) {
            
            NSString *cachePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
            NSString *csvPath = [cachePath stringByAppendingPathComponent:csvModel.csvPath];
            NSString *dataString = [NSString stringWithContentsOfFile:csvPath encoding:NSUTF8StringEncoding error:nil];
            dataArray = [dataString csvStringTransformToDictionary];
        }
    }
    return dataArray;
}

@end
