function [methodinfo,structs,enuminfo]=AlazarInclude;
%ALAZARINCLUDE Create structures to define interfaces found in 'AlazarApi'.

%This function was generated by loadlibrary.m parser version 1.1.6.13 on Wed Jan 30 15:22:08 2013
%perl options:'AlazarApi.i -outfile=AlazarInclude.m'
ival={cell(1,0)}; % change 0 to the actual number of functions to preallocate the data.
fcns=struct('name',ival,'calltype',ival,'LHS',ival,'RHS',ival,'alias',ival);
structs=[];enuminfo=[];fcnNum=1;
% unsigned int AlazarGetOEMFPGAName ( int opcodeID , char * FullPath , unsigned long * error ); 
fcns.name{fcnNum}='AlazarGetOEMFPGAName'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'int32', 'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarOEMSetWorkingDirectory ( char * wDir , unsigned long * error ); 
fcns.name{fcnNum}='AlazarOEMSetWorkingDirectory'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarOEMGetWorkingDirectory ( char * wDir , unsigned long * error ); 
fcns.name{fcnNum}='AlazarOEMGetWorkingDirectory'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarParseFPGAName ( const char * FullName , char * Name , unsigned int * Type , unsigned int * MemSize , unsigned int * MajVer , unsigned int * MinVer , unsigned int * MajRev , unsigned int * MinRev , unsigned int * error ); 
fcns.name{fcnNum}='AlazarParseFPGAName'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'cstring', 'cstring', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarOEMDownLoadFPGA ( void * h , char * FileName , unsigned int * RetValue ); 
fcns.name{fcnNum}='AlazarOEMDownLoadFPGA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarDownLoadFPGA ( void * h , char * FileName , unsigned int * RetValue ); 
fcns.name{fcnNum}='AlazarDownLoadFPGA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'cstring', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarReadWriteTest ( void * h , unsigned int * Buffer , unsigned int SizeToWrite , unsigned int SizeToRead ); 
fcns.name{fcnNum}='AlazarReadWriteTest'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32Ptr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarMemoryTest ( void * h , unsigned int * errors ); 
fcns.name{fcnNum}='AlazarMemoryTest'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarBusyFlag ( void * h , int * BusyFlag ); 
fcns.name{fcnNum}='AlazarBusyFlag'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'int32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarTriggeredFlag ( void * h , int * TriggeredFlag ); 
fcns.name{fcnNum}='AlazarTriggeredFlag'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'int32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarBoardsFound (); 
fcns.name{fcnNum}='AlazarBoardsFound'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}=[];fcnNum=fcnNum+1;
% void * AlazarOpen ( char * BoardNameID ); 
fcns.name{fcnNum}='AlazarOpen'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='voidPtr'; fcns.RHS{fcnNum}={'cstring'};fcnNum=fcnNum+1;
% void AlazarClose ( void * h ); 
fcns.name{fcnNum}='AlazarClose'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}=[]; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% MSILS AlazarGetBoardKind ( void * h ); 
fcns.name{fcnNum}='AlazarGetBoardKind'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='MSILS'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetCPLDVersion ( void * h , unsigned char * Major , unsigned char * Minor ); 
fcns.name{fcnNum}='AlazarGetCPLDVersion'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8Ptr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetChannelInfo ( void * h , unsigned int * MemSize , unsigned char * SampleSize ); 
fcns.name{fcnNum}='AlazarGetChannelInfo'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32Ptr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetSDKVersion ( unsigned char * Major , unsigned char * Minor , unsigned char * Revision ); 
fcns.name{fcnNum}='AlazarGetSDKVersion'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'uint8Ptr', 'uint8Ptr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetDriverVersion ( unsigned char * Major , unsigned char * Minor , unsigned char * Revision ); 
fcns.name{fcnNum}='AlazarGetDriverVersion'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'uint8Ptr', 'uint8Ptr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarInputControl ( void * h , unsigned char Channel , unsigned int Coupling , unsigned int InputRange , unsigned int Impedance ); 
fcns.name{fcnNum}='AlazarInputControl'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetPosition ( void * h , unsigned char Channel , int PMPercent , unsigned int InputRange ); 
fcns.name{fcnNum}='AlazarSetPosition'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'int32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetExternalTrigger ( void * h , unsigned int Coupling , unsigned int Range ); 
fcns.name{fcnNum}='AlazarSetExternalTrigger'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetTriggerDelay ( void * h , unsigned int Delay ); 
fcns.name{fcnNum}='AlazarSetTriggerDelay'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetTriggerTimeOut ( void * h , unsigned int to_ns ); 
fcns.name{fcnNum}='AlazarSetTriggerTimeOut'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarTriggerTimedOut ( void * h ); 
fcns.name{fcnNum}='AlazarTriggerTimedOut'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetTriggerAddress ( void * h , unsigned int Record , unsigned int * TriggerAddress , unsigned int * TimeStampHighPart , unsigned int * TimeStampLowPart ); 
fcns.name{fcnNum}='AlazarGetTriggerAddress'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32Ptr', 'uint32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarSetTriggerOperation ( void * h , unsigned int TriggerOperation , unsigned int TriggerEngine1 , unsigned int Source1 , unsigned int Slope1 , unsigned int Level1 , unsigned int TriggerEngine2 , unsigned int Source2 , unsigned int Slope2 , unsigned int Level2 ); 
fcns.name{fcnNum}='AlazarSetTriggerOperation'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarGetTriggerTimestamp ( void * h , unsigned int Record , U64 * Timestamp_samples ); 
fcns.name{fcnNum}='AlazarGetTriggerTimestamp'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarSetTriggerOperationForScanning ( void * h , unsigned int slope , unsigned int level , unsigned int options ); 
fcns.name{fcnNum}='AlazarSetTriggerOperationForScanning'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarAbortCapture ( void * h ); 
fcns.name{fcnNum}='AlazarAbortCapture'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarForceTrigger ( void * h ); 
fcns.name{fcnNum}='AlazarForceTrigger'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarForceTriggerEnable ( void * h ); 
fcns.name{fcnNum}='AlazarForceTriggerEnable'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarStartCapture ( void * h ); 
fcns.name{fcnNum}='AlazarStartCapture'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarCaptureMode ( void * h , unsigned int Mode ); 
fcns.name{fcnNum}='AlazarCaptureMode'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarStreamCapture ( void * h , void * Buffer , unsigned int BufferSize , unsigned int DeviceOption , unsigned int ChannelSelect , unsigned int * error ); 
fcns.name{fcnNum}='AlazarStreamCapture'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 'uint32', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarHyperDisp ( void * h , void * Buffer , unsigned int BufferSize , unsigned char * ViewBuffer , unsigned int ViewBufferSize , unsigned int NumOfPixels , unsigned int Option , unsigned int ChannelSelect , unsigned int Record , long TransferOffset , unsigned int * error ); 
fcns.name{fcnNum}='AlazarHyperDisp'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 'uint8Ptr', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32', 'int32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarFastPRRCapture ( void * h , void * Buffer , unsigned int BufferSize , unsigned int DeviceOption , unsigned int ChannelSelect , unsigned int * error ); 
fcns.name{fcnNum}='AlazarFastPRRCapture'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 'uint32', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarBusy ( void * h ); 
fcns.name{fcnNum}='AlazarBusy'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarTriggered ( void * h ); 
fcns.name{fcnNum}='AlazarTriggered'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetStatus ( void * h ); 
fcns.name{fcnNum}='AlazarGetStatus'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarDetectMultipleRecord ( void * h ); 
fcns.name{fcnNum}='AlazarDetectMultipleRecord'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarSetRecordCount ( void * h , unsigned int Count ); 
fcns.name{fcnNum}='AlazarSetRecordCount'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetRecordSize ( void * h , unsigned int PreSize , unsigned int PostSize ); 
fcns.name{fcnNum}='AlazarSetRecordSize'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetCaptureClock ( void * h , unsigned int Source , unsigned int Rate , unsigned int Edge , unsigned int Decimation ); 
fcns.name{fcnNum}='AlazarSetCaptureClock'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetExternalClockLevel ( void * h , float percent ); 
fcns.name{fcnNum}='AlazarSetExternalClockLevel'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'single'};fcnNum=fcnNum+1;
% unsigned int AlazarSetClockSwitchOver ( void * hBoard , unsigned int uMode , unsigned int uDummyClockOnTime_ns , unsigned int uReserved ); 
fcns.name{fcnNum}='AlazarSetClockSwitchOver'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarRead ( void * h , unsigned int Channel , void * Buffer , int ElementSize , long Record , long TransferOffset , unsigned int TransferLength ); 
fcns.name{fcnNum}='AlazarRead'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'voidPtr', 'int32', 'int32', 'int32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetParameter ( void * h , unsigned char Channel , unsigned int Parameter , long Value ); 
fcns.name{fcnNum}='AlazarSetParameter'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'uint32', 'int32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetParameterUL ( void * h , unsigned char Channel , unsigned int Parameter , unsigned int Value ); 
fcns.name{fcnNum}='AlazarSetParameterUL'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarGetParameter ( void * h , unsigned char Channel , unsigned int Parameter , long * RetValue ); 
fcns.name{fcnNum}='AlazarGetParameter'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'uint32', 'int32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetParameterUL ( void * h , unsigned char Channel , unsigned int Parameter , unsigned int * RetValue ); 
fcns.name{fcnNum}='AlazarGetParameterUL'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% void * AlazarGetSystemHandle ( unsigned int sid ); 
fcns.name{fcnNum}='AlazarGetSystemHandle'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='voidPtr'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarNumOfSystems (); 
fcns.name{fcnNum}='AlazarNumOfSystems'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}=[];fcnNum=fcnNum+1;
% unsigned int AlazarBoardsInSystemBySystemID ( unsigned int sid ); 
fcns.name{fcnNum}='AlazarBoardsInSystemBySystemID'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarBoardsInSystemByHandle ( void * systemHandle ); 
fcns.name{fcnNum}='AlazarBoardsInSystemByHandle'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% void * AlazarGetBoardBySystemID ( unsigned int sid , unsigned int brdNum ); 
fcns.name{fcnNum}='AlazarGetBoardBySystemID'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='voidPtr'; fcns.RHS{fcnNum}={'uint32', 'uint32'};fcnNum=fcnNum+1;
% void * AlazarGetBoardBySystemHandle ( void * systemHandle , unsigned int brdNum ); 
fcns.name{fcnNum}='AlazarGetBoardBySystemHandle'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='voidPtr'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetLED ( void * h , unsigned int state ); 
fcns.name{fcnNum}='AlazarSetLED'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarQueryCapability ( void * h , unsigned int request , unsigned int value , unsigned int * retValue ); 
fcns.name{fcnNum}='AlazarQueryCapability'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarMaxSglTransfer ( ALAZAR_BOARDTYPES bt ); 
fcns.name{fcnNum}='AlazarMaxSglTransfer'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'BoardTypes'};fcnNum=fcnNum+1;
% unsigned int AlazarGetMaxRecordsCapable ( void * h , unsigned int RecordLength , unsigned int * num ); 
fcns.name{fcnNum}='AlazarGetMaxRecordsCapable'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetWhoTriggeredBySystemHandle ( void * systemHandle , unsigned int brdNum , unsigned int recNum ); 
fcns.name{fcnNum}='AlazarGetWhoTriggeredBySystemHandle'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarGetWhoTriggeredBySystemID ( unsigned int sid , unsigned int brdNum , unsigned int recNum ); 
fcns.name{fcnNum}='AlazarGetWhoTriggeredBySystemID'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSetBWLimit ( void * h , unsigned int Channel , unsigned int enable ); 
fcns.name{fcnNum}='AlazarSetBWLimit'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarSleepDevice ( void * h , unsigned int state ); 
fcns.name{fcnNum}='AlazarSleepDevice'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarStartAutoDMA ( void * h , void * Buffer1 , unsigned int UseHeader , unsigned int ChannelSelect , long TransferOffset , unsigned int TransferLength , long RecordsPerBuffer , long RecordCount , int * error , unsigned int r1 , unsigned int r2 , unsigned int * r3 , unsigned int * r4 ); 
fcns.name{fcnNum}='AlazarStartAutoDMA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 'uint32', 'int32', 'uint32', 'int32', 'int32', 'int32Ptr', 'uint32', 'uint32', 'uint32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetNextAutoDMABuffer ( void * h , void * Buffer1 , void * Buffer2 , long * WhichOne , long * RecordsTransfered , int * error , unsigned int r1 , unsigned int r2 , long * TriggersOccurred , unsigned int * r4 ); 
fcns.name{fcnNum}='AlazarGetNextAutoDMABuffer'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'voidPtr', 'int32Ptr', 'int32Ptr', 'int32Ptr', 'uint32', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetNextBuffer ( void * h , void * Buffer1 , void * Buffer2 , long * WhichOne , long * RecordsTransfered , int * error , unsigned int r1 , unsigned int r2 , long * TriggersOccurred , unsigned int * r4 ); 
fcns.name{fcnNum}='AlazarGetNextBuffer'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'voidPtr', 'int32Ptr', 'int32Ptr', 'int32Ptr', 'uint32', 'uint32', 'int32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarCloseAUTODma ( void * h ); 
fcns.name{fcnNum}='AlazarCloseAUTODma'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarAbortAutoDMA ( void * h , void * Buffer , int * error , unsigned int r1 , unsigned int r2 , unsigned int * r3 , unsigned int * r4 ); 
fcns.name{fcnNum}='AlazarAbortAutoDMA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'int32Ptr', 'uint32', 'uint32', 'uint32Ptr', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarGetAutoDMAHeaderValue ( void * h , unsigned int Channel , void * DataBuffer , unsigned int Record , unsigned int Parameter , int * error ); 
fcns.name{fcnNum}='AlazarGetAutoDMAHeaderValue'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'voidPtr', 'uint32', 'uint32', 'int32Ptr'};fcnNum=fcnNum+1;
% float AlazarGetAutoDMAHeaderTimeStamp ( void * h , unsigned int Channel , void * DataBuffer , unsigned int Record , int * error ); 
fcns.name{fcnNum}='AlazarGetAutoDMAHeaderTimeStamp'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='single'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'voidPtr', 'uint32', 'int32Ptr'};fcnNum=fcnNum+1;
% void * AlazarGetAutoDMAPtr ( void * h , unsigned int DataOrHeader , unsigned int Channel , void * DataBuffer , unsigned int Record , int * error ); 
fcns.name{fcnNum}='AlazarGetAutoDMAPtr'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='voidPtr'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'voidPtr', 'uint32', 'int32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarWaitForBufferReady ( void * h , long tms ); 
fcns.name{fcnNum}='AlazarWaitForBufferReady'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'int32'};fcnNum=fcnNum+1;
% unsigned int AlazarEvents ( void * h , unsigned int enable ); 
fcns.name{fcnNum}='AlazarEvents'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarBeforeAsyncRead ( void * hBoard , unsigned int uChannelSelect , long lTransferOffset , unsigned int uSamplesPerRecord , unsigned int uRecordsPerBuffer , unsigned int uRecordsPerAcquisition , unsigned int uFlags ); 
fcns.name{fcnNum}='AlazarBeforeAsyncRead'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'int32', 'uint32', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarAsyncRead ( void * hBoard , void * pBuffer , unsigned int BytesToRead , OVERLAPPED * pOverlapped ); 
fcns.name{fcnNum}='AlazarAsyncRead'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 's_OVERLAPPEDPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarAbortAsyncRead ( void * hBoard ); 
fcns.name{fcnNum}='AlazarAbortAsyncRead'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarPostAsyncBuffer ( void * hDevice , void * pBuffer , unsigned int uBufferLength_bytes ); 
fcns.name{fcnNum}='AlazarPostAsyncBuffer'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarWaitAsyncBufferComplete ( void * hDevice , void * pBuffer , unsigned int uTimeout_ms ); 
fcns.name{fcnNum}='AlazarWaitAsyncBufferComplete'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarWaitNextAsyncBufferComplete ( void * hDevice , void * pBuffer , unsigned int uBufferLength_bytes , unsigned int uTimeout_ms ); 
fcns.name{fcnNum}='AlazarWaitNextAsyncBufferComplete'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarCreateStreamFileA ( void * hDevice , const char * pszFilePath ); 
fcns.name{fcnNum}='AlazarCreateStreamFileA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'cstring'};fcnNum=fcnNum+1;
% unsigned int AlazarCreateStreamFileW ( void * hDevice , const WCHAR * pszFilePath ); 
fcns.name{fcnNum}='AlazarCreateStreamFileW'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint16Ptr'};fcnNum=fcnNum+1;
% long AlazarFlushAutoDMA ( void * h ); 
fcns.name{fcnNum}='AlazarFlushAutoDMA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='int32'; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% void AlazarStopAutoDMA ( void * h ); 
fcns.name{fcnNum}='AlazarStopAutoDMA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}=[]; fcns.RHS{fcnNum}={'voidPtr'};fcnNum=fcnNum+1;
% unsigned int AlazarResetTimeStamp ( void * h , unsigned int resetFlag ); 
fcns.name{fcnNum}='AlazarResetTimeStamp'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarReadRegister ( void * hDevice , unsigned int offset , unsigned int * retVal , unsigned int pswrd ); 
fcns.name{fcnNum}='AlazarReadRegister'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32Ptr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarWriteRegister ( void * hDevice , unsigned int offset , unsigned int Val , unsigned int pswrd ); 
fcns.name{fcnNum}='AlazarWriteRegister'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarDACSetting ( void * h , unsigned int SetGet , unsigned int OriginalOrModified , unsigned char Channel , unsigned int DACNAME , unsigned int Coupling , unsigned int InputRange , unsigned int Impedance , unsigned int * getVal , unsigned int setVal , unsigned int * error ); 
fcns.name{fcnNum}='AlazarDACSetting'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint8', 'uint32', 'uint32', 'uint32', 'uint32', 'uint32Ptr', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarConfigureAuxIO ( void * hDevice , unsigned int uMode , unsigned int uParameter ); 
fcns.name{fcnNum}='AlazarConfigureAuxIO'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% const char * AlazarErrorToText ( unsigned int code ); 
fcns.name{fcnNum}='AlazarErrorToText'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='cstring'; fcns.RHS{fcnNum}={'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarConfigureSampleSkipping ( void * hBoard , unsigned int uMode , unsigned int uSampleClocksPerRecord , unsigned short * pwClockSkipMask ); 
fcns.name{fcnNum}='AlazarConfigureSampleSkipping'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint16Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarCoprocessorRegisterRead ( void * hDevice , unsigned int offset , unsigned int * pValue ); 
fcns.name{fcnNum}='AlazarCoprocessorRegisterRead'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarCoprocessorRegisterWrite ( void * hDevice , unsigned int offset , unsigned int value ); 
fcns.name{fcnNum}='AlazarCoprocessorRegisterWrite'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarCoprocessorDownloadA ( void * hBoard , char * pszFileName , unsigned int uOptions ); 
fcns.name{fcnNum}='AlazarCoprocessorDownloadA'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'cstring', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarCoprocessorDownloadW ( void * hBoard , WCHAR * pszFileName , unsigned int uOptions ); 
fcns.name{fcnNum}='AlazarCoprocessorDownloadW'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint16Ptr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarGetBoardRevision ( void * hBoard , unsigned char * Major , unsigned char * Minor ); 
fcns.name{fcnNum}='AlazarGetBoardRevision'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8Ptr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned int AlazarConfigureRecordAverage ( void * hBoard , unsigned int uMode , unsigned int uSamplesPerRecord , unsigned int uRecordsPerAverage , unsigned int uOptions ); 
fcns.name{fcnNum}='AlazarConfigureRecordAverage'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint32', 'uint32', 'uint32', 'uint32'};fcnNum=fcnNum+1;
% unsigned char * AlazarAllocBufferU8 ( void * hBoard , unsigned int uSampleCount ); 
fcns.name{fcnNum}='AlazarAllocBufferU8'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint8Ptr'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarFreeBufferU8 ( void * hBoard , unsigned char * pBuffer ); 
fcns.name{fcnNum}='AlazarFreeBufferU8'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint8Ptr'};fcnNum=fcnNum+1;
% unsigned short * AlazarAllocBufferU16 ( void * hBoard , unsigned int uSampleCount ); 
fcns.name{fcnNum}='AlazarAllocBufferU16'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint16Ptr'; fcns.RHS{fcnNum}={'voidPtr', 'uint32'};fcnNum=fcnNum+1;
% unsigned int AlazarFreeBufferU16 ( void * hBoard , unsigned short * pBuffer ); 
fcns.name{fcnNum}='AlazarFreeBufferU16'; fcns.calltype{fcnNum}='cdecl'; fcns.LHS{fcnNum}='uint32'; fcns.RHS{fcnNum}={'voidPtr', 'uint16Ptr'};fcnNum=fcnNum+1;
structs.s_BoardDef.packing=8;
structs.s_BoardDef.members=struct('RecordCount', 'uint32', 'RecLength', 'uint32', 'PreDepth', 'uint32', 'ClockSource', 'uint32', 'ClockEdge', 'uint32', 'SampleRate', 'uint32', 'CouplingChanA', 'uint32', 'InputRangeChanA', 'uint32', 'InputImpedChanA', 'uint32', 'CouplingChanB', 'uint32', 'InputRangeChanB', 'uint32', 'InputImpedChanB', 'uint32', 'TriEngOperation', 'uint32', 'TriggerEngine1', 'uint32', 'TrigEngSource1', 'uint32', 'TrigEngSlope1', 'uint32', 'TrigEngLevel1', 'uint32', 'TriggerEngine2', 'uint32', 'TrigEngSource2', 'uint32', 'TrigEngSlope2', 'uint32', 'TrigEngLevel2', 'uint32');
structs.s_HEADER2.packing=8;
structs.s_HEADER2.members=struct('TimeStampLowPart', 'uint32');
structs.s_ALAZAR_HEADER.packing=8;
% structs.s_ALAZAR_HEADER.members=struct('hdr0', 'error', 'hdr1', 'error', 'hdr2', 's_HEADER2', 'hdr3', 'error');
structs.s_OVERLAPPED.packing=8;
structs.s_OVERLAPPED.members=struct('Internal', 'uint32', 'InternalHigh', 'uint32', 'Offset', 'uint32', 'OffsetHigh', 'uint32', 'hEvent', 'voidPtr');
enuminfo.MSILS=struct('KINDEPENDENT',0,'KSLAVE',1,'KMASTER',2,'KLASTSLAVE',3);
enuminfo.BoardTypes=struct('ATS_NONE',0,'ATS850',1,'ATS310',2,'ATS330',3,'ATS855',4,'ATS315',5,'ATS335',6,'ATS460',7,'ATS860',8,'ATS660',9,'ATS665',10,'ATS9462',11,'ATS9434',12,'ATS9870',13,'ATS9350',14,'ATS9325',15,'ATS9440',16,'ATS9410',17,'ATS9351',18,'ATS9310',19,'ATS9461',20,'ATS9850',21,'ATS9625',22,'ATG6500',23,'ATS9626',24,'ATS9360',25,'ATS_LAST',26);
methodinfo=fcns;