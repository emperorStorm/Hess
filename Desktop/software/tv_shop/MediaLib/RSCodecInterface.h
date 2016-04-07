//
//  RSCodecInterface.h
//  myFoundation
//
//  Created by czsm on 12-10-9.
//  Copyright (c) 2012年 czsm. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum _RSCodecType
{
    AAC_Encoder = 1,
    AAC_Decoder = 1 << 1,
    H264_Encoder = 1 << 2,
    H264_Decoder = 1 << 3,
    AMR_Encoder = 1 << 4,
    AMR_Decoder = 1 << 5,
}RSCodecType;

//video param
extern NSString *keyRSCodecVideoWidth;
extern NSString *keyRSCodecVideoHeight;
extern NSString *keyRSCodecVideoFps;
extern NSString *keyRSVideoQuality;

//audio param
extern NSString *keyRSCodecAudioSampleRate;
extern NSString *keyRSCodecAudioBitsPerChannel;
extern NSString *keyRSCodecAudioChannelNum;

@interface RSCodecInterface : NSObject

@property (nonatomic, assign) int codecType;
@property (nonatomic, retain) NSDictionary *encodecParam;
@property (nonatomic, retain) NSDictionary *decodecParam;

- (id) initCodec:(int) codec encodecParam:(NSDictionary*) encParam decodecParam:(NSDictionary*) decParam;
- (int) encodeBuf:(UInt8*) inBuf inBufSize:(int) ins outBuf:(UInt8*) outBuf outBufSize:(int) outs;
- (void) uninitCodec;
@end
