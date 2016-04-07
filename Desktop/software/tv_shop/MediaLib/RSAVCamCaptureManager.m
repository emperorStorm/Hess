//
//  RSAVCamCaptureManager.m
//  myFoundation
//
//  Created by czsm on 12-10-8.
//  Copyright (c) 2012年 czsm. All rights reserved.
//

#import "RSCodecInterface.h"
#import "RSAVCamCaptureManager.h"

int DEFAULT_FPS = 20;

#pragma mark -
@interface RSMyAVCamCaptureManager (InternalUtilityMethods)
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position;

@end

@implementation RSMyAVCamCaptureManager

@synthesize session;
@synthesize videoInput;
@synthesize videoOutput;
@synthesize audioInput;
@synthesize audioOutput;
@synthesize deviceConnectedObserver;
@synthesize deviceDisconnectedObserver;
@synthesize torchMode;
@synthesize delegate;
@synthesize captureVideoPreviewLayer;
@synthesize audioClosed;

- (id) init;
{	
    self = [super init];
    if (self != nil) {
		__block id weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
            
			//为session中添加视频输入管道  sjb
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
			if (deviceMediaType != nil) {
                
				for (AVCaptureDeviceInput *input in [session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
                
                if( [session canSetSessionPreset:AVCaptureSessionPreset640x480])
                {
                    session.sessionPreset = AVCaptureSessionPreset640x480;
                }
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
                    
					if ([session canAddInput:input])
						[session addInput:input];
				}
			}
        };
        
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
            // 为 session 移除输入管道 sjb
			AVCaptureDevice *device = [notification object];
			if ([device hasMediaType:AVMediaTypeVideo]) {
				[session removeInput:[weakSelf videoInput]];
				[weakSelf setVideoInput:nil];
			}
        };
        
        //媒体信号采集设备准备就绪后呼出 sjb
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        //媒体信号采集设备断开就绪后呼出 sjb
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
    }
    
    captureFps = DEFAULT_FPS;
    pYSize = 0;
    pUVSize = 0;
    bFirstAudioSampleBuf = FALSE;
    bFirstVideoSampleBuf = FALSE;
    
    
    audioClosed = FALSE;

	return self;
}

- (void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
	[notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
    
    [self stopRunning];

    [session removeOutput:audioOutput];
    [session removeInput:audioInput];
    [session removeOutput:videoOutput];
	[session removeInput:videoInput];
    delegate = nil;
    
//    [super dealloc];
}

- (BOOL) setupSessionWithPreviewView:(UIView*)view backCamera:(bool)isBackCamara
{
    BOOL success = NO;
	// Set torch and flash mode to auto 闪光灯
	[self setTorchMode:AVCaptureTorchModeOff];
    
    // Init the device inputs
    AVCaptureDeviceInput *newVideoInput;
    
    if (isBackCamara)
    {
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:nil];
        
        
        if ([self backFacingCamera].isFocusPointOfInterestSupported && [[self backFacingCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            NSError *error = nil;
            [[self backFacingCamera] lockForConfiguration:&error];
            [[self backFacingCamera] setFocusMode:AVCaptureFocusModeAutoFocus];
            [[self backFacingCamera] unlockForConfiguration];
        }
    }
    else
    {
        newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:nil];
        
        if ([self frontFacingCamera].isFocusPointOfInterestSupported && [[self frontFacingCamera] isFocusModeSupported:AVCaptureFocusModeAutoFocus])
        {
            NSError *error = nil;
            [[self frontFacingCamera] lockForConfiguration:&error];
            [[self frontFacingCamera] setFocusMode:AVCaptureFocusModeAutoFocus];
            [[self frontFacingCamera] unlockForConfiguration];
        }
    }
    
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    AVCaptureDeviceInput *newAudioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    // Create session
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
	
	// Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput])
    {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddInput:newAudioInput])
    {
        [newCaptureSession addInput:newAudioInput];
    }
    self.videoInput = newVideoInput;
    self.audioInput = newAudioInput;
    

    AVCaptureVideoDataOutput *_videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    NSDictionary *settings = [[NSDictionary alloc] initWithObjectsAndKeys:
                              [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey, nil];
    [_videoOutput setVideoSettings:settings];
    [_videoOutput setAlwaysDiscardsLateVideoFrames:YES];
    dispatch_queue_t videoQueue = dispatch_queue_create("myvideoqueue", NULL);
    [_videoOutput setSampleBufferDelegate:self queue:videoQueue];
    if ([newCaptureSession canAddOutput:_videoOutput])
    {
        [newCaptureSession addOutput:_videoOutput];
    }
    self.videoOutput = _videoOutput;
    
    AVCaptureAudioDataOutput *_audioOutput = [[AVCaptureAudioDataOutput alloc] init];
    dispatch_queue_t _audioQueue = dispatch_queue_create("myaudioqueue", NULL);
    [_audioOutput setSampleBufferDelegate:self queue:_audioQueue];
    if ([newCaptureSession canAddOutput:_audioOutput]) {
        [newCaptureSession addOutput:_audioOutput];
    }
    self.audioOutput = _audioOutput;
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 5.0)
    {
        newCaptureSession.sessionPreset = AVCaptureSessionPreset640x480;//sjb
    }
    else
    {
        newCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
    }
#else
    newCaptureSession.sessionPreset = AVCaptureSessionPresetLow;
#endif
    
    [self setFPS:DEFAULT_FPS];
    //修改
    if( [newCaptureSession canSetSessionPreset:AVCaptureSessionPresetiFrame960x540])
    {
        newCaptureSession.sessionPreset = AVCaptureSessionPresetiFrame960x540;
    }
    else
    {
        return NO;
    }
    
    
    bBackCamera = isBackCamara;
    
    self.session = newCaptureSession;
    
    //设置预览视图
    [self setPreviewUI:view];
    
    success = YES;

    return success;
}

- (void) startRunning
{
    if (![session isRunning])
    {
        [session startRunning];
    }
}

- (void) stopRunning
{
    if ([session isRunning])
    {
        [session stopRunning];
    }
}

// Toggle between the front and back camera, if both are present.
- (AVCaptureDevicePosition) toggleCamera
{   
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInput device] position];
        
        if (position == AVCaptureDevicePositionBack)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        else if (position == AVCaptureDevicePositionFront)
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        else
            return AVCaptureDevicePositionUnspecified;
        
        if (newVideoInput != nil) {
            [[self session] beginConfiguration];
            [[self session] removeInput:[self videoInput]];
            if ([[self session] canAddInput:newVideoInput]) {
                [[self session] addInput:newVideoInput];
                [self setVideoInput:newVideoInput];
            } else {
                [[self session] addInput:[self videoInput]];
            }
            [[self session] commitConfiguration];

        } else if (error) {
            NSLog(@"ToggleCamera Error=[%@]", error);
        }
        
        return [[videoInput device] position];
    }
    
    return AVCaptureDevicePositionUnspecified;
}

- (void) closeTorch
{
	[self setTorchMode:AVCaptureTorchModeOff];
}

- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
	for ( AVCaptureConnection *connection in connections ) {
		for ( AVCaptureInputPort *port in [connection inputPorts] ) {
			if ( [[port mediaType] isEqual:mediaType] ) {
				return connection;
			}
		}
	}
	return nil;
}

- (void) setFPS:(int) fps
{
    [session beginConfiguration];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_5_0
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 5.0) {
        for (AVCaptureConnection *connection in videoOutput.connections) {
            BOOL bFound = FALSE;
            for (AVCaptureInputPort *port in [connection inputPorts]) {
                if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                    if(connection.supportsVideoMaxFrameDuration) {
                        [connection setVideoMaxFrameDuration:CMTimeMake(1, fps)];
                        NSLog(@"当前ios版本[%@],setVideoMaxFrameDuration为[%d]", [[UIDevice currentDevice] systemVersion], fps);
                    }
                    if(connection.supportsVideoMinFrameDuration) {
                        [connection setVideoMinFrameDuration:CMTimeMake(1, fps)];
                        NSLog(@"当前ios版本[%@],setVideoMinFrameDuration为[%d]", [[UIDevice currentDevice] systemVersion], fps);
                    }
                    bFound = TRUE;
                    break;
                }
            }
            if (bFound) {
                break;
            }
        }
    } else {
        [videoOutput setMinFrameDuration:CMTimeMake(1, fps)];
        NSLog(@"当前ios版本[%@],设置FPS为[%d]", [[UIDevice currentDevice] systemVersion], fps);
    }
#else
    [videoOutput setMinFrameDuration:CMTimeMake(1, fps)];
    NSLog(@"当前ios版本[%@],设置FPS为[%d]", [[UIDevice currentDevice] systemVersion], fps);
#endif
    
    captureFps = fps;
    [session commitConfiguration];
}

- (AVCaptureTorchMode) toggleTorch
{
    if (torchMode == AVCaptureTorchModeOff) {
	    [self setTorchMode:AVCaptureTorchModeOn];
	} else if (torchMode == AVCaptureTorchModeOn) {
        [self setTorchMode:AVCaptureTorchModeOff];
	}
    return torchMode;
}

- (void) setTorchMode:(AVCaptureTorchMode)tMode
{
	if ([[self backFacingCamera] hasTorch]) {
		if ([[self backFacingCamera] lockForConfiguration:nil]) {
			if ([[self backFacingCamera] isTorchModeSupported:tMode]) {
				[[self backFacingCamera] setTorchMode:tMode];
                torchMode = tMode;
			}
			[[self backFacingCamera] unlockForConfiguration];
		}
	}
}

- (BOOL) hasTorch
{
    return [[self backFacingCamera] hasTorch];
}

- (BOOL) hasFlash
{
    return [[self backFacingCamera] hasFlash];
}

#pragma mark -Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

- (NSUInteger) micCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] count];
}

#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (![delegate captureIsReady]) {
        return;
    }
    
    int before = pYSize;
    
    if (videoOutput == captureOutput) {
        CMTime tm = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        if (CVPixelBufferLockBaseAddress(pixelBuffer, 0) == kCVReturnSuccess) {
            if (!bFirstVideoSampleBuf)
            {
                if (refTime == 0)
                {
                    refTime = CMTimeGetSeconds(tm) * 1000;
                }
                int videoWidth = CVPixelBufferGetWidth(pixelBuffer);
                int videoHeight = CVPixelBufferGetHeight(pixelBuffer);
                
                
                NSLog(@"%d-%d",videoHeight,videoWidth);
                
                pYSize = videoWidth * videoHeight;
                pUVSize = pYSize / 2;
                NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:540], keyRSCodecVideoWidth, [NSNumber numberWithInt:960 ], keyRSCodecVideoHeight, [NSNumber numberWithInt:captureFps], keyRSCodecVideoFps, [NSNumber numberWithInt:30], keyRSVideoQuality, nil];
                NSLog(@"重新设置1");
                [delegate setupVideoEncoder:dic];
                
                NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:480], keyRSCodecVideoWidth, [NSNumber numberWithInt:640 ], keyRSCodecVideoHeight, [NSNumber numberWithInt:captureFps], keyRSCodecVideoFps, [NSNumber numberWithInt:30], keyRSVideoQuality, nil];
                
                [delegate setupVideoEncoderEx:dic1];
                NSLog(@"重新设置2");
                bFirstVideoSampleBuf = TRUE;
            }
            NSUInteger videoTm = CMTimeGetSeconds(tm) * 1000 - refTime;
            int plane = CVPixelBufferGetPlaneCount(pixelBuffer);
            if (plane == 2)
            {
                UInt8 *pY = (UInt8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 0);
                UInt8 *pUV = (UInt8*)CVPixelBufferGetBaseAddressOfPlane(pixelBuffer, 1);
                //修改
                pYSize = 960*540;
                pUVSize = (960*540)/2;
                
                
                if (before != pYSize)//暂时舍弃切换后的第一帧数据
                {
                    return;
                }
                
                //NSLog(@"%d-%d",pYSize,pUVSize);
                
                [delegate captureManagerCapture:pY YBufSize:pYSize UVBuffer:pUV UVBufSize:pUVSize timeStamp:videoTm];
                
            }
            CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
        }
        
    }
    else if (audioOutput == captureOutput)
    {
        if (audioClosed)
        {
            return;
        }
        
        CMTime tm = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        if (!bFirstAudioSampleBuf) {
            if (refTime == 0) {
                refTime = CMTimeGetSeconds(tm) * 1000;
            }
            CMAudioFormatDescriptionRef desc = CMSampleBufferGetFormatDescription(sampleBuffer);
            const AudioStreamBasicDescription *audioDesc = CMAudioFormatDescriptionGetStreamBasicDescription(desc);
            NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:audioDesc->mSampleRate], keyRSCodecAudioSampleRate, [NSNumber numberWithInt:audioDesc->mBitsPerChannel], keyRSCodecAudioBitsPerChannel, [NSNumber numberWithInt:audioDesc->mChannelsPerFrame], keyRSCodecAudioChannelNum, nil];
            [delegate setupAudioEncoder:dic];
            bFirstAudioSampleBuf = TRUE;
        }
        NSUInteger audioTm = CMTimeGetSeconds(tm) * 1000 - refTime;
        CMBlockBufferRef blockRef = CMSampleBufferGetDataBuffer(sampleBuffer);
        size_t len = 0;
        char *dataPtr = 0;
        CMBlockBufferGetDataPointer(blockRef, 0, NULL, &len, &dataPtr);
        [delegate captureManagerCapture:(UInt8*)dataPtr size:len timeStamp:audioTm];
        
    }
}

- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

- (void) setPreviewUI:(UIView*)view
{
    // Create video preview layer and add it to the UI

    
    AVCaptureVideoPreviewLayer *newCaptureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    

    CALayer *viewLayer = [view layer];
    
    [viewLayer setMasksToBounds:YES];
    CGRect bounds = [view bounds];
        
    if(bBackCamera)
    {
        bounds = CGRectMake(0, 0, 414, 736);
    }
    [newCaptureVideoPreviewLayer setFrame:bounds];

    
    //NSLog(@"width:%f height:%f",bounds.size.width ,bounds.size.height);
    
    //bounds.size.width = 320;
    //bounds.size.height = 426;
    
    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 6.0) {
        if ([newCaptureVideoPreviewLayer.connection isVideoOrientationSupported]) {
            [newCaptureVideoPreviewLayer.connection setVideoOrientation:AVCaptureVideoOrientationPortrait];
            
        }
    } else {
        if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
            [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
        }
    }
#else
    if ([newCaptureVideoPreviewLayer isOrientationSupported]) {
        [newCaptureVideoPreviewLayer setOrientation:AVCaptureVideoOrientationPortrait];
    }
#endif
    
    [newCaptureVideoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    
    if (firstCALay == nil)
    {
        firstCALay = [[viewLayer sublayers] objectAtIndex:0];
    }
    
    //[viewLayer insertSublayer:newCaptureVideoPreviewLayer below:[[viewLayer sublayers] objectAtIndex:0]];
    
    [viewLayer insertSublayer:newCaptureVideoPreviewLayer below:firstCALay];
    
    [self setCaptureVideoPreviewLayer:newCaptureVideoPreviewLayer];
    
}

@end


#pragma mark -
@implementation RSMyAVCamCaptureManager (InternalUtilityMethods)
// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position)
        {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found

@end
