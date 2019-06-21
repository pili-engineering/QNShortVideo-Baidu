//
//  BARApplicationMemory.m
//  ARSDKBasic-OpenSDK
//
//  Created by Zhao,Xiangkai on 2018/5/14.
//  Copyright © 2018年 Baidu. All rights reserved.
//

#import "BARApplicationMemory.h"
#import <mach/mach.h>
#import <mach/task_info.h>


#ifndef NBYTE_PER_MB
#define NBYTE_PER_MB (1024 * 1024)
#endif

@implementation BARApplicationMemory

- (BARApplicationMemoryUsage)currentUsage {
    
    task_vm_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_VM_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO_PURGEABLE, (task_info_t)&taskInfo, &infoCount);
    if (kernReturn != KERN_SUCCESS) {
        return (BARApplicationMemoryUsage){ 0 };
    }
    double memory = (taskInfo.internal + taskInfo.compressed - taskInfo.purgeable_volatile_pmap) / (1024.0 * 1024.0);
    return (BARApplicationMemoryUsage){
        .usage = memory,
        .total = 1,
        .ratio = 1,
    };

//下面是1期代码，和xcode跑的数据有较大差距
//    struct mach_task_basic_info info;
//    mach_msg_type_number_t count = sizeof(info) / sizeof(integer_t);
//    if (task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &count) == KERN_SUCCESS) {
//        return (BARApplicationMemoryUsage){
//            .usage = info.resident_size / NBYTE_PER_MB,
//            .total = [NSProcessInfo processInfo].physicalMemory / NBYTE_PER_MB,
//            .ratio = info.virtual_size / [NSProcessInfo processInfo].physicalMemory,
//        };
//    }
//    return (BARApplicationMemoryUsage){ 0 };
}



void report_memory(void) {
    
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t result = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    NSLog(@"mememem %f",(vmInfo.phys_footprint) / (1024.0 * 1024.0));
    
//    return;
//    task_vm_info_data_t taskInfo;
//    mach_msg_type_number_t infoCount = TASK_VM_INFO_COUNT;
//    kern_return_t kernReturn = task_info(mach_task_self(), TASK_VM_INFO_PURGEABLE, (task_info_t)&taskInfo, &infoCount);
//    if (kernReturn != KERN_SUCCESS) {
//        return;
//    }
//    NSLog(@"mememem %f",(taskInfo.internal + taskInfo.compressed - taskInfo.purgeable_volatile_pmap) / (1024.0 * 1024.0));
//   // return ((taskInfo.internal + taskInfo.compressed - taskInfo.purgeable_volatile_pmap) / (1024.0 * 1024.0));
//
//    return;
//    struct task_basic_info info;
//    mach_msg_type_number_t size = sizeof(info);
//    kern_return_t kerr = task_info(mach_task_self(),
//                                   TASK_BASIC_INFO,
//                                   (task_info_t)&info,
//                                   &size);
//    if( kerr == KERN_SUCCESS ) {
//        NSLog(@"Memory in use (in bytes): %lu", info.resident_size);
//        NSLog(@"Memory in use (in MB): %lu", (info.resident_size / 1048576));
//    } else {
//        NSLog(@"Error with task_info(): %s", mach_error_string(kerr));
//    }
//
//    task_vm_info_data_t vmInfo;
//    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
//    kern_return_t result1 = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
//
//    if( result1 == KERN_SUCCESS ) {
//        NSLog(@"22222 Memory in use (in bytes): %lu", (vm_size_t)vmInfo.phys_footprint/ 1048576);
//
//        NSLog(@"111Memory in use (in bytes): %lu", vmInfo.resident_size);
//        NSLog(@"111Memory in use (in MB): %lu", (vmInfo.resident_size / 1048576));
//    } else {
//        NSLog(@"1111Error with task_info(): %s", mach_error_string(result1));
//    }
    
    
}

@end
