//
//  ViewController.m
//  testMemory
//
//  Created by test on 14-2-21.
//  Copyright (c) 2014年 test. All rights reserved.
//

// 获取当前设备可用内存及所占内存的头文件
#import <sys/sysctl.h>
#import <mach/mach.h>
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize memoryTF = _memoryTF;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self refreshMemoryStatus];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(refreshMemoryStatus) userInfo:nil repeats:YES];
}

- (void)refreshMemoryStatus
{
    double availableMemoryDouble = [self availableMemory];
    double usedMemoryDouble = [self usedMemory];
    double totalMemory = availableMemoryDouble + usedMemoryDouble;
    NSLog(@"%f", totalMemory);
    NSMutableString *_aMemory = [NSMutableString stringWithFormat:@"%.2f",  availableMemoryDouble];
    NSMutableString *_usedMemory = [NSMutableString stringWithFormat:@"%.2f", usedMemoryDouble];
//    [_usedMemory appendString: @"/"];
//    [_usedMemory appendString: _aMemory];
//    [[_usedMemory appendString: @"/"] appendString: _aMemory];
    [_memoryTF setText: _usedMemory];
    [self showTime];
}

- (void)caculate
{
    for (int i = 0; i < 10; i++) {
        NSLog(@"%d", i*i);
    }
}

-(void)showTime{
    
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSLog(@"当前时间是:%@",[dateFormatter stringFromDate:[NSDate date]]);
    
}

// 获取当前设备可用内存(单位：MB）
- (double)availableMemory
{
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

// 获取当前任务所占用的内存（单位：MB）
- (double)usedMemory
{
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

- (void)didReceiveMemoryWarning
{
    // Remember to call super
    [super didReceiveMemoryWarning];
    
    // If we are using more than 45% of the memory, free even important resources,
    // because the app might be killed by the OS if we don't
    if ([self __getMemoryUsedPer1] > 0.45)
    {
        // Free important resources here
    }
    
    // Free regular unimportant resources always here
}

- (float)__getMemoryUsedPer1
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)&info, &size);
    if (kerr == KERN_SUCCESS)
    {
        float used_bytes = info.resident_size;
        float total_bytes = [NSProcessInfo processInfo].physicalMemory;
        //NSLog(@"Used: %f MB out of %f MB (%f%%)", used_bytes / 1024.0f / 1024.0f, total_bytes / 1024.0f / 1024.0f, used_bytes * 100.0f / total_bytes);
        return used_bytes / total_bytes;
    }
    return 1;
}

@end
