//
//  LiveStreamingService.h
//  LiveStreaming
//
//  Created by czsm on 13-11-26.
//  Copyright (c) 2013年 czsm. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "RSAVCamCaptureManager.h"
#import "DelegateDefine.h"

@class RSH264CodecInterface;
@class RSAACCodecInterface;
@class RSAMRCodecInterface;
@class RSCirculBuffer;
@class MyTCPSocket;

@interface LiveStreamingService : NSObject <RSAVCamCaptureManagerDelegate> {
    RSH264CodecInterface *h264En;
    RSAACCodecInterface *aacEn;
    RSCirculBuffer *videoCaptureBuf;
    RSCirculBuffer *audioCaptureBuf;
    
    BOOL isRunning;
    BOOL isCaptureReady;
    NSUInteger audioBlockSize;
    NSUInteger videoBlockSize;
    NSUInteger frameIndex;
    MyTCPSocket *streamSocket;
    
    NSTimeInterval firstTime;
}

@property (nonatomic, retain) NSString* serverIP;
@property (nonatomic, assign) NSInteger serverPort;
@property (nonatomic,retain) NSString * liveChannelID;
- (id) initWithServerIP:(NSString*)ip port:(NSInteger)port channelID:(NSString *) channelID;
- (void) startService;
- (void) stopService;
@end

extern NSString *LSNotification;
extern NSString *LSNotifyKey;

// LiveStream report
enum  {
    LiveStreamAuthError,
	LiveStreamGetChannelError,
    LiveStreamStartConnect,
    LiveStreamConnectServerError,
    LiveStreamConnectServerOK,
	LiveStreamSendPacketError,
	LiveStreamStopError,
	LiveStreamStopOK,
};