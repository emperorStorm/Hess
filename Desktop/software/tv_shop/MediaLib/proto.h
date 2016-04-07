/**
*  proto 
*  @author:		
*  @version:  	1.19 
*  @date: 		08/27/2007
*  -------------------------------------------------------------
*  -------------------------------------------------------------
*  Copyright (C) 2007 - All Rights Reserved
*  ***************************************************************
*/
#ifndef _3GPP_PTOTO_
#define _3GPP_PTOTO_

#define DATAPOOL_SIZE 3000
#define CHECKTIME 25
#define LIVE_KBPS 900

#define VIDEO_H264			0x00
#define VIDEO_H263			0x10
#define VIDEO_MP4			0x20
#define VIDEO_AVS			0x30
#define VIDEO_FLV1          0x40
#define VIDEO_NULL			0xF0


#define AUDIO_AMR			0x00
#define AUDIO_AAC			0x01
#define AUDIO_AMRWB			0x02
#define AUDIO_AACPlus		0x03
#define AUDIO_MP3           0X04
#define AUDIO_NULL			0x0F

typedef unsigned short WORD;
typedef unsigned long  DWORD;
typedef unsigned char  BYTE;

typedef struct _service_desc{
	DWORD	serviceID;			
	WORD	bitRate;			
	BYTE	frame;				
	BYTE	codec;				
	WORD	weight;				
	WORD	height;				
}Service_desc;

typedef struct _data_head{
	DWORD	frameSeq;			
	WORD	frameSizeLo;		
	
	BYTE	mediaID		:3	;	

	BYTE    reserved	:3  ;	
	BYTE    frameSizeHi	:2	;	
	BYTE	bIndex;				
	DWORD	timestamp;			
}Data_Head;

typedef struct _data_payload{
	Data_Head head;
	char*	content;
}Data_Payload;

#endif //_3GPP_PTOTO_
