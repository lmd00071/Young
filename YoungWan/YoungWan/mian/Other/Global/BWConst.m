
#import <UIKit/UIKit.h>
//http://219.136.125.147/dns/service/dns_service/dns_service.aspx
//http://219.136.125.147/enet/service/enet_service/enet_service_v00_68_766.aspx
//通用网络请求地址http://112.74.75.214/ZXDNS/service/dns_service/dns_service.aspx
//http://219.136.125.147/dns/service/dns_service/dns_service.aspx
//测试服务器:http://219.136.125.150/dns/service/dns_service/dns_service.aspx
//正式服务器:http://219.136.125.147/dns/service/dns_service/dns_service.aspx
NSString *const BWBaseUrlString = @"http://219.136.125.147/dns/service/dns_service/dns_service.aspx";

NSString *const FromSystem = @"YOUNG";

//学校id
NSString *const BWSchoolBaseString = @"&amp;school_id=";
NSString *BWSchoolId = nil;

//tabBar的高度
CGFloat const BWTabBarHeight = 49;

//导航条的最大y值
CGFloat const BWNavigationMaxY = 64;

//默认间距
CGFloat const BWMargin = 10;

//默认小间距
CGFloat const BWSmallMargin = 5;

//缓存时间csv的key
NSString *const BWGeneralCsvKey = @"general_csv";

//内容csv的key
NSString *const BWAttrCsvKey = @"template_attr_csv";

//数据csv的key
NSString *const BWDataCsvKey = @"template_data_csv";

//试题csv的key
NSString *const BWPaperCsvKey = @"paper_csv_url";

//通讯录人数
NSInteger BWStudentNumber = 0;

int const UNUSED = -1;
int const FIRST_CODE = 259;
int const BITS = 15;
int const MAX_CODE = ((1 << BITS) - 1);
int const END_OF_STREAM = 256;
int const BUMP_CODE = 257;
int const FLUSH_CODE = 258;



