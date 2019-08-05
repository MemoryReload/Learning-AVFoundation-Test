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

#import "THMetadataConverterFactory.h"
#import "THArtworkMetadataConverter.h"
#import "THCommentMetadataConverter.h"
#import "THDiscMetadataConverter.h"
#import "THGenreMetadataConverter.h"
#import "THTrackMetadataConverter.h"
#import "THYearMetadataConverter.h"
#import "THMetadataKeys.h"

@implementation THMetadataConverterFactory

- (id <THMetadataConverter>)converterForKey:(NSString *)key {

    id <THMetadataConverter> converter = nil;

    if ([key isEqualToString:THMetadataKeyArtwork]) {
        converter = [[THArtworkMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyTrackNumber]) {
        converter = [[THTrackMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyDiscNumber]) {
        converter = [[THDiscMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyComments]) {
        converter = [[THCommentMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyGenre]) {
        converter = [[THGenreMetadataConverter alloc] init];
    }
    else if ([key isEqualToString:THMetadataKeyYear]){
        converter = [[THYearMetadataConverter alloc]init];
    }
    else {
        converter = [[THDefaultMetadataConverter alloc] init];
    }

    return converter;
}
@end
