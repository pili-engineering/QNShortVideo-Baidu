//
//  UIDevice+BAR.h
//  ARSDK
//
//  Created by LiuQi on 15/6/16.
//  Copyright (c) 2015年 Baidu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define IFPGA_NAMESTRING                @"iFPGA"

#define IPHONE1						@"iPhone1"
#define IPHONE3  					@"iPhone3"
#define IPAD1							@"iPad1"
#define IPAD3							@"iPad3"

#define PLATFORM_FORMAT             @"%@,%@"
#define DEVICEINFO_FORMAT           @"%@_%@"

#define IPHONE_1G_NAMESTRING            @"iPhone 1G"
#define IPHONE_3G_NAMESTRING            @"iPhone 3G"
#define IPHONE_3GS_NAMESTRING           @"iPhone 3GS"
#define IPHONE_4_NAMESTRING             @"iPhone 4"
#define IPHONE_4S_NAMESTRING            @"iPhone 4S"
#define IPHONE_5_NAMESTRING             @"iPhone 5"
#define IPHONE_5C_NAMESTRING            @"iPhone 5c"
#define IPHONE_5S_NAMESTRING            @"iPhone 5s"
#define IPHONE_6_NAMESTRING             @"iPhone 6"
#define IPHONE_6_PLUS_NAMESTRING        @"iPhone 6plus"
#define IPHONE_6S_NAMESTRING            @"iPhone 6s"
#define IPHONE_6S_PLUS_NAMESTRING       @"iPhone 6splus"
#define IPHONE_SE_NAMESTRING            @"iPhone SE"
#define IPHONE_7_NAMESTRING             @"iPhone 7"
#define IPHONE_7_PLUS_NAMESTRING        @"iPhone 7plus"
#define IPHONE_8_NAMESTRING             @"iPhone 8"
#define IPHONE_8_PLUS_NAMESTRING        @"iPhone 8plus"
#define IPHONE_X_NAMESTRING             @"iPhone X"
#define IPHONE_XR_NAMESTRING            @"iPhone XR"
#define IPHONE_XS_NAMESTRING            @"iPhone XS"
#define IPHONE_XS_MAX_NAMESTRING        @"iPhone XSMax"

#define IPHONE_UNKNOWN_NAMESTRING       @"Unknown iPhone"

#define IPOD_1G_NAMESTRING              @"iPod touch 1G"
#define IPOD_2G_NAMESTRING              @"iPod touch 2G"
#define IPOD_3G_NAMESTRING              @"iPod touch 3G"
#define IPOD_4G_NAMESTRING              @"iPod touch 4G"
#define IPOD_UNKNOWN_NAMESTRING         @"Unknown iPod"

#define IPAD_1G_NAMESTRING              @"iPad 1G"
#define IPAD_2G_NAMESTRING              @"iPad 2G"
#define IPAD_3G_NAMESTRING              @"iPad 3G"
#define IPAD_4G_NAMESTRING              @"iPad 4G"
#define IPAD_UNKNOWN_NAMESTRING         @"Unknown iPad"

#define APPLETV_2G_NAMESTRING           @"Apple TV 2G"
#define APPLETV_3G_NAMESTRING           @"Apple TV 3G"
#define APPLETV_4G_NAMESTRING           @"Apple TV 4G"
#define APPLETV_UNKNOWN_NAMESTRING      @"Unknown Apple TV"

#define IOS_FAMILY_UNKNOWN_DEVICE       @"0"

#define SIMULATOR_NAMESTRING            @"iPhone Simulator"
#define SIMULATOR_IPHONE_NAMESTRING     @"iPhone Simulator"
#define SIMULATOR_IPAD_NAMESTRING       @"iPad Simulator"
#define SIMULATOR_APPLETV_NAMESTRING    @"Apple TV Simulator" // :)

typedef enum {
    BARUIDeviceUnknown,
    
    BARUIDeviceSimulator,
    BARUIDeviceSimulatoriPhone,
    BARUIDeviceSimulatoriPad,
    BARUIDeviceSimulatorAppleTV,
    
    BARUIDevice1GiPhone,
    BARUIDevice3GiPhone,
    BARUIDevice3GSiPhone,
    BARUIDevice4iPhone,
    BARUIDevice4SiPhone,
    BARUIDevice5iPhone,
    BARUIDevice5CiPhone,
    BARUIDevice5SiPhone,
    BARUIDevice6iPhone,
    BARUIDevice6PLUSiPhone,
    BARUIDevice6SiPhone,
    BARUIDevice6SPLUSiPhone,
    BARUIDeviceiPhoneSE,
    BARUIDevice7iPhone,
    BARUIDevice7PLUSiPhone,
    BARUIDevice8iPhone,
    BARUIDevice8PLUSiPhone,
    BARUIDeviceXiPhone,
    BARUIDeviceXRiPhone,
    BARUIDeviceXSiPhone,
    BARUIDeviceXSMaxiPhone,

    BARUIDevice1GiPod,
    BARUIDevice2GiPod,
    BARUIDevice3GiPod,
    BARUIDevice4GiPod,
    
    BARUIDevice1GiPad,
    BARUIDevice2GiPad,
    BARUIDevice3GiPad,
    BARUIDevice4GiPad,
    
    BARUIDeviceAppleTV2,
    BARUIDeviceAppleTV3,
    BARUIDeviceAppleTV4,
    
    BARUIDeviceUnknowniPhone,
    BARUIDeviceUnknowniPod,
    BARUIDeviceUnknowniPad,
    BARUIDeviceUnknownAppleTV,
    BARUIDeviceIFPGA,
    
} BARUIDevicePlatform;

typedef enum {
    BARUIDeviceFamilyiPhone,
    BARUIDeviceFamilyiPod,
    BARUIDeviceFamilyiPad,
    BARUIDeviceFamilyAppleTV,
    BARUIDeviceFamilyUnknown,
    
} BARUIDeviceFamily;

// @class - UIDevice
// @brief - 扩展UIDevice，获得更多的设备相关信息
@interface BARUIDevice : UIDevice

+ (NSString *)barGetSysInfoByName:(const char *)aTypeSpecifier;
//+ (NSString *)barGetDeviceInfo;            // 没有经过ULREncode的原始信息
//+ (NSString *)barGetCellularProviderName;  // 获取运营商信息
//+ (NSString *)barGetMNC;           //获取移动网络码
//+ (NSString *)barGetMCC;           //获取国家码
//+ (NSString *)barGetMACAddress;     // 获取MAC地址
//+ (NSString *)barCachedSystemVersion; // 获取系统版本，并缓存

+ (BOOL)barIsRetina;           // 判断是否是高清屏幕

+ (NSString *) barPlatform;
+ (NSUInteger) barPlatformType;
+ (NSString *) barPlatformString;
//+ (NSString* ) barMachineName;

+ (float)systemVersion;
+ (BOOL)isIOS10;
+ (BOOL)iOS10orNew;
//+ (BOOL)isIOS9;
+ (BOOL)isIOS8;
+ (BOOL)iOS8orNew;
//+ (BOOL)isIPHONE5S;
+ (BOOL)isIPhoneX;
@end
