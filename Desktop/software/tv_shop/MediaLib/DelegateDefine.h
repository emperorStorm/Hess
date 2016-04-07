//
//  DelegateDefine.h
//  MediaLive
//
//  Created by 刘佳宾 on 15/10/14.
//  Copyright © 2015年 powerise. All rights reserved.
//

#ifndef DelegateDefine_h
#define DelegateDefine_h

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

@protocol RSAVCamCaptureManagerDelegate <NSObject>
@optional
- (BOOL) captureIsReady;
- (void) setupVideoEncoder:(NSDictionary*)dic;
- (void) setupVideoEncoderEx:(NSDictionary*)dic;
- (void) setupAudioEncoder:(NSDictionary*)dic;
- (void) captureManagerCapture:(UInt8*)data1 YBufSize:(int)size1 UVBuffer:(UInt8*)data2 UVBufSize:(int)size2 timeStamp:(NSUInteger)pt;
- (void) captureManagerCapture:(UInt8*)buf size:(int)size timeStamp:(NSUInteger)pt;

@end


#endif /* DelegateDefine_h */
