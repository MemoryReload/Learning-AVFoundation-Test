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

#import "THMetadata.h"
#import "THMetadataConverterFactory.h"
#import "THMetadataKeys.h"

@interface THMetadata ()
@property (strong) NSDictionary *keyMapping;
@property (strong) NSMutableDictionary *metadata;
@property (strong) THMetadataConverterFactory *converterFactory;
@end

@implementation THMetadata

- (id)init {
    self = [super init];
    if (self) {
        // Listing 3.6
        _keyMapping = [self buildKeyMapping];
        _metadata = [[NSMutableDictionary alloc]init];
        _converterFactory = [[THMetadataConverterFactory alloc]init];
    }
    return self;
}

- (NSDictionary *)buildKeyMapping {

    return @{
        // Name Mapping
        AVMetadataCommonKeyTitle : THMetadataKeyName,

        // Artist Mapping
        AVMetadataCommonKeyArtist : THMetadataKeyArtist,
        AVMetadataQuickTimeMetadataKeyProducer : THMetadataKeyArtist,

        // Album Artist Mapping
        AVMetadataID3MetadataKeyBand : THMetadataKeyAlbumArtist,
        AVMetadataiTunesMetadataKeyAlbumArtist : THMetadataKeyAlbumArtist,
        @"TP2" : THMetadataKeyAlbumArtist,

        // Album Mapping
        AVMetadataCommonKeyAlbumName : THMetadataKeyAlbum,

        // Artwork Mapping
        AVMetadataCommonKeyArtwork : THMetadataKeyArtwork,

        // Year Mapping
        AVMetadataCommonKeyCreationDate : THMetadataKeyYear,
        AVMetadataID3MetadataKeyYear : THMetadataKeyYear,
        @"TYE" : THMetadataKeyYear,
        AVMetadataQuickTimeMetadataKeyYear : THMetadataKeyYear,
        AVMetadataID3MetadataKeyRecordingTime : THMetadataKeyYear,

        // BPM Mapping
        AVMetadataiTunesMetadataKeyBeatsPerMin : THMetadataKeyBPM,
        AVMetadataID3MetadataKeyBeatsPerMinute : THMetadataKeyBPM,
        @"TBP" : THMetadataKeyBPM,

        // Grouping Mapping
        AVMetadataiTunesMetadataKeyGrouping : THMetadataKeyGrouping,
        @"@grp" : THMetadataKeyGrouping,
        AVMetadataCommonKeySubject : THMetadataKeyGrouping,

        // Track Number Mapping
        AVMetadataiTunesMetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        AVMetadataID3MetadataKeyTrackNumber : THMetadataKeyTrackNumber,
        @"TRK" : THMetadataKeyTrackNumber,

        // Composer Mapping
        AVMetadataQuickTimeMetadataKeyDirector : THMetadataKeyComposer,
        AVMetadataiTunesMetadataKeyComposer : THMetadataKeyComposer,
        AVMetadataCommonKeyCreator : THMetadataKeyComposer,

        // Disc Number Mapping
        AVMetadataiTunesMetadataKeyDiscNumber : THMetadataKeyDiscNumber,
        AVMetadataID3MetadataKeyPartOfASet : THMetadataKeyDiscNumber,
        @"TPA" : THMetadataKeyDiscNumber,

        // Comments Mapping
        @"ldes" : THMetadataKeyComments,
        AVMetadataCommonKeyDescription : THMetadataKeyComments,
        AVMetadataiTunesMetadataKeyUserComment : THMetadataKeyComments,
        AVMetadataID3MetadataKeyComments : THMetadataKeyComments,
        @"COM" : THMetadataKeyComments,

        // Genre Mapping
        AVMetadataQuickTimeMetadataKeyGenre : THMetadataKeyGenre,
        AVMetadataiTunesMetadataKeyUserGenre : THMetadataKeyGenre,
        AVMetadataCommonKeyType : THMetadataKeyGenre
    };
}


- (void)addMetadataItem:(AVMetadataItem *)item withKey:(id)key {

    // Listing 3.7
    [_metadata setObject:item forKey:key];
    
    NSString* mappedKey = [_keyMapping valueForKey:key]?:key;
    id<THMetadataConverter> converter = [_converterFactory converterForKey:mappedKey];
    
    if([mappedKey isEqualToString:THMetadataKeyName]) {
        _name = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyArtist]){
        _artist = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyAlbumArtist]){
        _albumArtist = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyAlbum]){
        _album = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyArtwork]){
        _artwork = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyYear]){
        _year = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyBPM]){
        _bpm = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyGrouping]){
        _grouping = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyTrackNumber]){
        _trackNumber = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyComposer]){
        _composer = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyDiscNumber]){
        _discNumber = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyComments]){
        _comments = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyGenre]){
        _genre = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyTrackCount]){
        _trackCount = [converter displayValueFromMetadataItem:item];
    }else if ([mappedKey isEqualToString:THMetadataKeyDiscCount]){
        _discCount = [converter displayValueFromMetadataItem:item];
    }
}

- (NSArray *)metadataItems {

    // Listing 3.16
    NSArray* allKeys = [_metadata allKeys];
    NSMutableArray* items = [[NSMutableArray alloc]initWithCapacity:allKeys.count];
    for (NSString* key in allKeys) {
        AVMetadataItem* item = [_metadata valueForKey:key];
        
        NSString* mappedKey = [_keyMapping valueForKey:key]?:key;
        id<THMetadataConverter> converter = [_converterFactory converterForKey:mappedKey];
        
        if([mappedKey isEqualToString:THMetadataKeyName]) {
            item = [converter metadataItemFromDisplayValue:_name withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyArtist]){
            item = [converter metadataItemFromDisplayValue:_artist withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyAlbumArtist]){
            item = [converter metadataItemFromDisplayValue:_albumArtist withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyAlbum]){
            item = [converter metadataItemFromDisplayValue:_album withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyArtwork]){
            item = [converter metadataItemFromDisplayValue:_artwork withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyYear]){
            item = [converter metadataItemFromDisplayValue:_year withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyBPM]){
            item = [converter metadataItemFromDisplayValue:_bpm withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyGrouping]){
            item = [converter metadataItemFromDisplayValue:_grouping withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyTrackNumber]){
            item = [converter metadataItemFromDisplayValue:_trackNumber withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyComposer]){
            item = [converter metadataItemFromDisplayValue:_composer withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyDiscNumber]){
            item = [converter metadataItemFromDisplayValue:_discNumber withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyComments]){
            item = [converter metadataItemFromDisplayValue:_comments withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyGenre]){
            item = [converter metadataItemFromDisplayValue:_genre withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyTrackCount]){
            item = [converter metadataItemFromDisplayValue:_trackCount withMetadataItem:item];
        }else if ([mappedKey isEqualToString:THMetadataKeyDiscCount]){
            item = [converter metadataItemFromDisplayValue:_discCount withMetadataItem:item];
        }
        [items addObject:item];
    }
    return [items copy];
}

@end
