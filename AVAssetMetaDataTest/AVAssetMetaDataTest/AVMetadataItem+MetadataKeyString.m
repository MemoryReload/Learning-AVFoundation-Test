//
//  AVMetadataItem+MetadataKeyString.m
//  AVAssetMetaDataTest
//
//  Created by HePing on 2019/7/21.
//  Copyright © 2019 何平. All rights reserved.
//

#import "AVMetadataItem+MetadataKeyString.h"

@implementation AVMetadataItem (MetadataKeyString)
-(NSString*)keyString
{
    if ([self.key isKindOfClass:[NSString class]]) {
        return (NSString*)self.key;
    }
    else if ([self.key isKindOfClass:[NSNumber class]]){
        //作为一个32位无符号数读取(4字节)
        UInt32 keyValue = [(NSNumber*)self.key unsignedIntValue];
        
        /*
         BigEndian 高位低地址，如果不足4字节，高位存储低地址的数据，字符串
         从低位开始存储，所以，需要去掉可能出现的字符串头部的\0空字符，得到
         字符串的真实长度
         例如：
         从高向低 \0abc
         */
        size_t length = sizeof(UInt32);
        
        if (keyValue >> 24 ==0) --length;
        if (keyValue >> 16 ==0) --length;
        if (keyValue >> 8 ==0)  --length;
        if (keyValue >> 0 ==0)  --length;
        
        /*
         转换为 LittleEndian之后，起始地址会正确的回到低位，但是，字符串起始位置
         的\0空字符会导致拷贝问题，所以，将字符串指针向高位移动sizeof(UInt32) - length
         的偏移量(即空白字符的长度)，
         例如：
         从高向低 cba\0
         */
        long address = (unsigned long)&keyValue;
        address += sizeof(UInt32) - length;
        
//        char* p = (char*)address;
//        for (int i=0; i< sizeof(UInt32); i++) {
//            printf("%p %c\n",p+i,*(p+i));
//        }
        //转换为小端
        keyValue = CFSwapInt32(keyValue);
//        for (int i=0; i< sizeof(UInt32); i++) {
//            printf("%p %c\n",p+i,*(p+i));
//        }
        
        //拷贝
        char cstring[length];
        strncpy(cstring, (char*)address, length);
        cstring[length] = '\0';
        
        //替换
        if (cstring[0]== '\xA9') {
            cstring[0] = '@';
        }
        
        return [NSString stringWithCString:cstring encoding:NSUTF8StringEncoding];
    }else{
        return @"<<unkown>>";
    }
}
@end
