//
//  RSAVCamCaptureManager.h
//  myFoundation
//
//  Created by czsm on 12-10-8.
//  Copyright (c) 2012年 czsm. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "DelegateDefine.h"

@interface RSMyAVCamCaptureManager : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>
{
    int captureFps;
    int pYSize;
    int pUVSize;
    BOOL bFirstAudioSampleBuf;
    BOOL bFirstVideoSampleBuf;
    
    bool bBackCamera;
    NSUInteger refTime;
    
    CALayer*    firstCALay;
}

@property (nonatomic, assign) BOOL audioClosed;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureDeviceInput *videoInput;
@property (nonatomic, retain) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, retain) AVCaptureDeviceInput *audioInput;
@property (nonatomic, retain) AVCaptureAudioDataOutput *audioOutput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;
@property (nonatomic, assign) id deviceConnectedObserver;
@property (nonatomic, assign) id deviceDisconnectedObserver;
@property (nonatomic, assign) AVCaptureTorchMode torchMode;
@property (nonatomic, assign) id <RSAVCamCaptureManagerDelegate> delegate;

- (id) init;
- (BOOL) setupSessionWithPreviewView:(UIView*)view backCamera:(bool)isBackCamara;
- (void) startRunning;
- (void) stopRunning;
- (BOOL) hasTorch;
- (BOOL) hasFlash;
- (AVCaptureTorchMode) toggleTorch;
- (AVCaptureDevicePosition) toggleCamera;
- (void) closeTorch;
- (NSUInteger) cameraCount;
- (NSUInteger) micCount;
- (void) setFPS:(int) fps;
- (void) setTorchMode:(AVCaptureTorchMode)tMode;

- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;

- (void) setPreviewUI:(UIView*)view;
@end
