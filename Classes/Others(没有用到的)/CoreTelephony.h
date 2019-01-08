//
//  CoreTelephony.h
//  voiceexpress
//
//  Created by Yaning Fan on 13-9-13.
//  Copyright (c) 2013年 CYYUN. All rights reserved.
//

#ifndef voiceexpress_CoreTelephony_h
#define voiceexpress_CoreTelephony_h

// 需要导入CoreTelephony.framework
struct CTServerConnection
{
    int a;
    int b;
    CFMachPortRef myport;
    int c;
    int d;
    int e;
    int f;
    int g;
    int h;
    int i;
};

struct CTResult
{
    int flag;
    int a;
};

struct CTServerConnection* _CTServerConnectionCreate(CFAllocatorRef, void *, int *);
void _CTServerConnectionCopyMobileEquipmentInfo(struct CTResult *, struct CTServerConnection *, NSDictionary **);
extern CFStringRef kCTMobileEquipmentInfoIMEI;

void callback() { }

#endif
