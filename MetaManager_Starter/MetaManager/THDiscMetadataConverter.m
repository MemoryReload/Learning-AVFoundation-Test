//
//  MIT License
//
//  Copyright (c) 2014 Bob McCune http://bobmccune.com/
//  Copyright (c) 2014 TapHarmonic, LLC http://tapharmonic.com/
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "THDiscMetadataConverter.h"
#import "THMetadataKeys.h"

@implementation THDiscMetadataConverter

- (id)displayValueFromMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.14
    NSNumber *discNumber, *discCount;
    if ([item.value isKindOfClass:[NSString class]]) {
        NSArray* components = [(NSString*)item.value componentsSeparatedByString:@"/"];
        discNumber = @([components[0] integerValue]);
        discCount = @([components[1] integerValue]);
    }else if ([item.value isKindOfClass:[NSData class]]){
        NSData* data = (NSData*)item.value;
        if (data.length == 6) {
            uint16_t *values = (uint16_t *)[data bytes];
            if (values[1]>0) {
                discNumber = @(CFSwapInt16HostToBig(values[1]));
            }
            if (values[2]>0) {
                discCount = @(CFSwapInt16BigToHost(values[2]));
            }
        }
    }
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setObject:discNumber?:[NSNull null] forKey:THMetadataKeyDiscNumber];
    [mutableDict setObject:discCount?:[NSNull null] forKey:THMetadataKeyDiscCount];
    return [mutableDict copy];
}

- (AVMetadataItem *)metadataItemFromDisplayValue:(id)value
                                withMetadataItem:(AVMetadataItem *)item {
    
    // Listing 3.14
    uint16_t  values[3] = {0};
    
    NSNumber* discNumber = [value objectForKey:THMetadataKeyDiscNumber];
    NSNumber* discCount = [value objectForKey:THMetadataKeyDiscCount];
    
    if (discNumber && ![discNumber isKindOfClass:[NSNull class]]) {
        values[1] = CFSwapInt16HostToBig([discNumber unsignedShortValue]);
    }
    if (discCount && ![discCount isKindOfClass:[NSNull class]]) {
        values[2] = CFSwapInt16HostToBig([discCount unsignedShortValue]);
    }
    
    size_t len = sizeof(values);
    NSData* data = [NSData dataWithBytes:values length:len];
    AVMutableMetadataItem* mutableItem = [item mutableCopy];
    mutableItem.value = data;
//    NSAssert(mutableItem != nil, @"catcha in Disc Converter!");
    return [mutableItem copy];
}

@end
