//-------------------------------------------------------------------------------------------------
//
// Copyright (c) 2008-2016 AlazarTech, Inc.
//
// AlazarTech, Inc. licenses this software under specific terms and conditions. Use of any of the
// software or derivatives thereof in any product without an AlazarTech digitizer board is strictly
// prohibited.
//
// AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY, EXPRESS OR IMPLIED,
// INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR
// PURPOSE. AlazarTech makes no guarantee or representations regarding the use of, or the results of
// the use of, the software and documentation in terms of correctness, accuracy, reliability,
// currentness, or otherwise; and you rely on the software, documentation and results solely at your
// own risk.
//
// IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF BUSINESS, LOSS OF PROFITS,
// INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL DAMAGES OF ANY KIND. IN NO EVENT SHALL
// ALAZARTECH'S TOTAL LIABILITY EXCEED THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED
// HEREUNDER.
//
//-------------------------------------------------------------------------------------------------

// AcqToDisk.cpp :
//
// This program demonstrates how to configure a ATS9462 to make a volts
// TR acquisition.
//

#include <stdio.h>
#include <string.h>

#include "AlazarError.h"
#include "AlazarApi.h"
#include "AlazarCmd.h"

#ifdef _WIN32
#include <conio.h>
#else // ifndef _WIN32
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

#define TRUE  1
#define FALSE 0

#define _snprintf snprintf

inline U32 GetTickCount(void);
inline void Sleep(U32 dwTime_ms);
inline int _kbhit (void);
inline int GetLastError();
#endif // ifndef _WIN32

// TODO: Select the number of DMA buffers to allocate.

#define BUFFER_COUNT 4

// Globals variables
U16 *BufferArray[BUFFER_COUNT] = { NULL };
double samplesPerSec = 0.0;
U32 InputRangeIds[2] = { 0 }; 


// Forward declarations

BOOL ConfigureBoard(HANDLE boardHandle);
BOOL AcquireData(HANDLE boardHandle);
double InputRangeIdToVolts(U32 inputRangeId);

//-------------------------------------------------------------------------------------------------
//
// Function    :  main
//
// Description :  Program entry point
//
//-------------------------------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    // TODO: Select a board

    U32 systemId = 1;
    U32 boardId = 1;

    // Get a handle to the board

    HANDLE boardHandle = AlazarGetBoardBySystemID(systemId, boardId);
    if (boardHandle == NULL)
    {
        printf("Error: Unable to open board system Id %u board Id %u\n", systemId, boardId);
        return 1;
    }

    // Configure the board's sample rate, input, and trigger settings

    if (!ConfigureBoard(boardHandle))
    {
        printf("Error: Configure board failed\n");
        return 1;
    }

    // Make an acquisition, optionally saving sample data to a file

    if (!AcquireData(boardHandle))
    {
        printf("Error: Acquisition failed\n");
        return 1;
    }

    return 0;
}

//-------------------------------------------------------------------------------------------------
//
// Function    :  ConfigureBoard
//
// Description :  Configure sample rate, input, and trigger settings
//
//-------------------------------------------------------------------------------------------------

BOOL ConfigureBoard(HANDLE boardHandle)
{
    RETURN_CODE retCode;

    // TODO: Specify the sample rate (see sample rate id below)

    samplesPerSec = 180000000.0;

    // TODO: Select clock parameters as required to generate this sample rate.
    //
    // For example: if samplesPerSec is 100.e6 (100 MS/s), then:
    // - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
    // - select clock source FAST_EXTERNAL_CLOCK, sample rate SAMPLE_RATE_USER_DEF, and connect a
    //   100 MHz signal to the EXT CLK BNC connector.

    retCode = AlazarSetCaptureClock(boardHandle,
                                    INTERNAL_CLOCK,
                                    SAMPLE_RATE_180MSPS,
                                    CLOCK_EDGE_RISING,
                                    0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetCaptureClock failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    
    InputRangeIds['A' - 'A'] = INPUT_RANGE_PM_400_MV;

    // TODO: Select channel A input parameters as required

    retCode =
        AlazarInputControlEx(boardHandle,
                             CHANNEL_A,
                             DC_COUPLING, 
                             InputRangeIds['A' - 'A'],
                             IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel A bandwidth limit as required

    retCode = AlazarSetBWLimit(boardHandle,
                               CHANNEL_A,
                               0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetBWLimit failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    InputRangeIds['B' - 'A'] = INPUT_RANGE_PM_400_MV;

    // TODO: Select channel B input parameters as required

    retCode =
        AlazarInputControlEx(boardHandle,
                             CHANNEL_B,
                             DC_COUPLING, 
                             InputRangeIds['B' - 'A'],
                             IMPEDANCE_50_OHM);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarInputControlEx failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    // TODO: Select channel B bandwidth limit as required

    retCode = AlazarSetBWLimit(boardHandle,
                               CHANNEL_B,
                               0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetBWLimit failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
     
    // TODO: Select trigger inputs and levels as required

    retCode = AlazarSetTriggerOperation(boardHandle,
                                        TRIG_ENGINE_OP_J,
                                        TRIG_ENGINE_J,
                                        TRIG_CHAN_A,
                                        TRIGGER_SLOPE_POSITIVE,
                                        150,
                                        TRIG_ENGINE_K,
                                        TRIG_DISABLE,
                                        TRIGGER_SLOPE_POSITIVE,
                                        128);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerOperation failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Select external trigger parameters as required

    retCode = AlazarSetExternalTrigger(boardHandle,
                                       DC_COUPLING,
                                       ETR_5V);

    // TODO: Set trigger delay as required.

    double triggerDelay_sec = 0;
    U32 triggerDelay_samples = (U32)(triggerDelay_sec * samplesPerSec + 0.5);
    retCode = AlazarSetTriggerDelay(boardHandle, triggerDelay_samples);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerDelay failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Set trigger timeout as required.

    // NOTE:
    // The board will wait for a for this amount of time for a trigger event.  If a trigger event
    // does not arrive, then
    // the board will automatically trigger. Set the trigger timeout value to 0 to force the board
    // to wait forever for a
    // trigger event.
    //
    // IMPORTANT:
    // The trigger timeout value should be set to zero after appropriate trigger parameters have
    // been determined,
    // otherwise the board may trigger if the timeout interval expires before a hardware trigger
    // event arrives.

    double triggerTimeout_sec = 0;
    U32 triggerTimeout_clocks = (U32)(triggerTimeout_sec / 10.e-6 + 0.5);

    retCode = AlazarSetTriggerTimeOut(boardHandle, triggerTimeout_clocks);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerTimeOut failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Configure AUX I/O connector as required

    retCode = AlazarConfigureAuxIO(boardHandle, AUX_OUT_TRIGGER, 0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarConfigureAuxIO failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }
    
    return TRUE;
}

//-------------------------------------------------------------------------------------------------
//
// Function    :  AcquireData
//
// Description :  Perform an acquisition, optionally saving data to file.
//
//-------------------------------------------------------------------------------------------------

BOOL AcquireData(HANDLE boardHandle)
{
    // TODO: Select the number of pre-trigger samples
    U32 preTriggerSamples = 1024;

    // TODO: Select the number of post-trigger samples per record
    U32 postTriggerSamples = 1024;

    // TODO: Specify the number of records per DMA buffer
    U32 recordsPerBuffer = 10;
    

    // TODO: Specify the total number of buffers to capture
    U32 buffersPerAcquisition = 1;
    
    // TODO: Select which channels to capture (A, B, or both)
    U32 channelMask = CHANNEL_A | CHANNEL_B;

    // TODO: Select if you wish to save the sample data to a file
    BOOL saveData = false;

    // Calculate the number of enabled channels from the channel mask
    int channelCount = 0;
    int channelsPerBoard = 2;
    for (int channel = 0; channel < channelsPerBoard; channel++)
    {
        U32 channelId = 1U << channel;
        if (channelMask & channelId)
            channelCount++;
    }

    // Get the sample size in bits, and the on-board memory size in samples per channel
    U8 bitsPerSample;
    U32 maxSamplesPerChannel;
    RETURN_CODE retCode = AlazarGetChannelInfo(boardHandle, &maxSamplesPerChannel, &bitsPerSample);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarGetChannelInfo failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // Calculate the size of each DMA buffer in bytes
    float bytesPerSample = (float) ((bitsPerSample + 7) / 8);
    U32 samplesPerRecord = preTriggerSamples + postTriggerSamples;
    U32 bytesPerRecord = (U32)(bytesPerSample * samplesPerRecord +
                               0.5); // 0.5 compensates for double to integer conversion 
    U32 bytesPerBuffer = bytesPerRecord * recordsPerBuffer * channelCount;
    
    // Create a data file if required
    FILE *fpData = NULL;

    if (saveData)
    {
        fpData = fopen("data.bin", "wb");
        if (fpData == NULL)
        {
            printf("Error: Unable to create data file -- %u\n", GetLastError());
            return FALSE;
        }
    }
    

    // Allocate memory for DMA buffers
    BOOL success = TRUE;

    U32 bufferIndex;
    for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success; bufferIndex++)
    {
        // Allocate page aligned memory
        BufferArray[bufferIndex] =
            (U16 *)AlazarAllocBufferU16(boardHandle, bytesPerBuffer);
        if (BufferArray[bufferIndex] == NULL)
        {
            printf("Error: Alloc %u bytes failed\n", bytesPerBuffer);
            success = FALSE;
        }
    } 

    
    // Configure the record size
    if (success)
    {
        retCode = AlazarSetRecordSize(boardHandle, preTriggerSamples, postTriggerSamples);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarSetRecordSize failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }

    // Configure the board to make an NPT AutoDMA acquisition
    if (success)
    {
        U32 recordsPerAcquisition = recordsPerBuffer * buffersPerAcquisition;

        U32 admaFlags = ADMA_EXTERNAL_STARTCAPTURE | ADMA_TRADITIONAL_MODE;

        retCode = AlazarBeforeAsyncRead(boardHandle, channelMask, -(long)preTriggerSamples,
                                        samplesPerRecord, recordsPerBuffer, recordsPerAcquisition,
                                        admaFlags);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarBeforeAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }
    
    // Add the buffers to a list of buffers available to be filled by the board
    
    for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success; bufferIndex++)
    {
        U16 *pBuffer = BufferArray[bufferIndex];
        retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarPostAsyncBuffer %u failed -- %s\n", bufferIndex,
                   AlazarErrorToText(retCode));
            success = FALSE;
        }
    }
    

    // Arm the board system to wait for a trigger event to begin the acquisition
    if (success)
    {
        retCode = AlazarStartCapture(boardHandle);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarStartCapture failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }
    }

    // Wait for each buffer to be filled, process the buffer, and re-post it to
    // the board.
    if (success)
    {
        printf("Capturing %d buffers ... press any key to abort\n", buffersPerAcquisition);

        U32 startTickCount = GetTickCount();
        U32 buffersCompleted = 0;
        INT64 bytesTransferred = 0;
        while (buffersCompleted < buffersPerAcquisition)
        {
            // TODO: Set a buffer timeout that is longer than the time
            //       required to capture all the records in one buffer.
            U32 timeout_ms = 5000;

            // Wait for the buffer at the head of the list of available buffers
            // to be filled by the board.
            bufferIndex = buffersCompleted % BUFFER_COUNT; 
            U16 *pBuffer = BufferArray[bufferIndex];
             
            retCode = AlazarWaitAsyncBufferComplete(boardHandle, pBuffer, timeout_ms);
            if (retCode != ApiSuccess)
            {
                printf("Error: AlazarWaitAsyncBufferComplete failed -- %s\n",
                       AlazarErrorToText(retCode));
                success = FALSE;
            }  

            if (success)
            {
                // The buffer is full and has been removed from the list
                // of buffers available for the board

                buffersCompleted++;
                bytesTransferred += bytesPerBuffer;

                // TODO: Process sample data in this buffer.

                // NOTE:
                //
                // While you are processing this buffer, the board is already filling the next
                // available buffer(s).
                //
                // You MUST finish processing this buffer and post it back to the board before
                // the board fills all of its available DMA buffers and on-board memory.
                //
                // Records are arranged in the buffer as follows: R0A, R0B, ..., R1A, R1B, ...
                // with RXY the record number X of channel Y.
                // 
                // Sample codes are unsigned by default. As a result:
                // - a sample code of 0x0000 represents a negative full scale input signal.
                // - a sample code of 0x8000 represents a ~0V signal.
                // - a sample code of 0xFFFF represents a positive full scale input signal. 
                void *pvBuffer = (void*) pBuffer;

                for (int channel = 0; (channel < channelCount) && (success == TRUE); channel++)
                {
                    for (U32 record = 0; (record < recordsPerBuffer) && (success == TRUE);
                         record++)
                    {
                        if (saveData)
                        {
                            // Get name of current channel
                            char tempLetter = 'A' - 1;
                            int tempCount = 0;
                            while (tempCount <= channel)
                            {
                                tempLetter += 1;
                                U32 tempId = CHANNEL_A << (tempLetter - 'A');
                                if (channelMask & tempId)
                                {
                                    tempCount += 1;
                                }
                            }
                            char channelLetter = tempLetter;

                            // Get input range from ID
                            double inputRange_volts =
                                InputRangeIdToVolts(InputRangeIds[channelLetter - 'A']);

                            // AlazarTech boards are calibrated as follows
                            double codeZero = (1 << (bitsPerSample - 1)) - 0.5;
                            double codeRange = (1 << (bitsPerSample - 1)) - 0.5;

                            // Convert sample values to volts and write to file
                            for (U32 sample = 0;
                                 (sample < samplesPerRecord) && (success == TRUE); sample++)
                            {
                                // Convert code to volts
                                double volts = 0.;
                                int sampleBitShift =
                                    (int) (8 * bytesPerSample - bitsPerSample + 0.5);
                                U16 sampleValue = ((U16*)pvBuffer)[channel * recordsPerBuffer * samplesPerRecord
                                                                   + record * samplesPerRecord
                                                                   + sample];
                                U16 sampleCode = sampleValue >> sampleBitShift;
                                volts = inputRange_volts *
                                    ((double)(sampleCode - codeZero) / codeRange);

                                // write value in volts to file
                                size_t samplesWritten = fwrite(&volts, sizeof(double), 1, fpData);

                                if (samplesWritten != 1)
                                {
                                    printf("Error: Write sample failed -- %u\n",
                                           GetLastError());
                                    success = FALSE;
                                }
                            }
                        }
                    }
                } 
            }

            // Add the buffer to the end of the list of available buffers.
            if (success)
            {
                retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
                if (retCode != ApiSuccess)
                {
                    printf("Error: AlazarPostAsyncBuffer failed -- %s\n",
                           AlazarErrorToText(retCode));
                    success = FALSE;
                }
            }

            // If the acquisition failed, exit the acquisition loop
            if (!success)
                break;

            // If a key was pressed, exit the acquisition loop
            if (_kbhit())
            {
                printf("Aborted...\n");
                break;
            }

            // Display progress
            printf("Completed %u buffers\r", buffersCompleted);
        }

        // Display results
        double transferTime_sec = (GetTickCount() - startTickCount) / 1000.;
        printf("Capture completed in %.2lf sec\n", transferTime_sec);

        double buffersPerSec;
        double bytesPerSec;
        double recordsPerSec;
        U32 recordsTransferred = recordsPerBuffer * buffersCompleted;

        if (transferTime_sec > 0.)
        {
            buffersPerSec = buffersCompleted / transferTime_sec;
            bytesPerSec = bytesTransferred / transferTime_sec;
            recordsPerSec = recordsTransferred / transferTime_sec;
        }
        else
        {
            buffersPerSec = 0.;
            bytesPerSec = 0.;
            recordsPerSec = 0.;
        }

        printf("Captured %u buffers (%.4g buffers per sec)\n", buffersCompleted, buffersPerSec);
        printf("Captured %u records (%.4g records per sec)\n", recordsTransferred, recordsPerSec);
        printf("Transferred %I64d bytes (%.4g bytes per sec)\n", bytesTransferred, bytesPerSec);
    }

    // Abort the acquisition
    retCode = AlazarAbortAsyncRead(boardHandle);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarAbortAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
        success = FALSE;
    }

    // Free all memory allocated
    for (bufferIndex = 0; bufferIndex < BUFFER_COUNT; bufferIndex++)
    {
        if (BufferArray[bufferIndex] != NULL)
        {
			AlazarFreeBufferU16(boardHandle, BufferArray[bufferIndex]);
			
        }
    }

    // Close the data file
    
    if (fpData != NULL)
        fclose(fpData);
    

    return success;
}
//-------------------------------------------------------------------------------------------------
//
// Function    :  InputRangeIdToVolts
//
// Description :  Convert input range identifier to volts
//
//-------------------------------------------------------------------------------------------------

double InputRangeIdToVolts(U32 inputRangeId)
{
    double inputRange_volts;

    switch (inputRangeId)
    {
    case INPUT_RANGE_PM_20_MV:
        inputRange_volts = 20.e-3;
        break;
    case INPUT_RANGE_PM_40_MV:
        inputRange_volts = 40.e-3;
        break;
    case INPUT_RANGE_PM_50_MV:
        inputRange_volts = 50.e-3;
        break;
    case INPUT_RANGE_PM_80_MV:
        inputRange_volts = 80.e-3;
        break;
    case INPUT_RANGE_PM_100_MV:
        inputRange_volts = 100.e-3;
        break;
    case INPUT_RANGE_PM_200_MV:
        inputRange_volts = 200.e-3;
        break;
    case INPUT_RANGE_PM_400_MV:
        inputRange_volts = 400.e-3;
        break;
    case INPUT_RANGE_PM_500_MV:
        inputRange_volts = 500.e-3;
        break;
    case INPUT_RANGE_PM_800_MV:
        inputRange_volts = 800.e-3;
        break;
    case INPUT_RANGE_PM_1_V:
        inputRange_volts = 1.;
        break;
    case INPUT_RANGE_PM_2_V:
        inputRange_volts = 2.;
        break;
    case INPUT_RANGE_PM_4_V:
        inputRange_volts = 4.;
        break;
    case INPUT_RANGE_PM_5_V:
        inputRange_volts = 5.;
        break;
    case INPUT_RANGE_PM_8_V:
        inputRange_volts = 8.;
        break;
    case INPUT_RANGE_PM_10_V:
        inputRange_volts = 10.;
        break;
    case INPUT_RANGE_PM_20_V:
        inputRange_volts = 20.;
        break;
    case INPUT_RANGE_PM_40_V:
        inputRange_volts = 40.;
        break;
    case INPUT_RANGE_PM_16_V:
        inputRange_volts = 16.;
        break;
    case INPUT_RANGE_HIFI:
        inputRange_volts = 0.525;
        break;
    default:
        printf("Error: Invalid input range %u\n", inputRangeId);
        inputRange_volts = -1.;
        break;
    }

    return inputRange_volts;
} 


#ifndef WIN32
inline U32 GetTickCount(void)
{
	struct timeval tv;
	if (gettimeofday(&tv, NULL) != 0)
		return 0;
	return (tv.tv_sec * 1000) + (tv.tv_usec / 1000);
}

inline void Sleep(U32 dwTime_ms)
{
	usleep(dwTime_ms * 1000);
}

inline int _kbhit (void)
{
  struct timeval tv;
  fd_set rdfs;

  tv.tv_sec = 0;
  tv.tv_usec = 0;

  FD_ZERO(&rdfs);
  FD_SET (STDIN_FILENO, &rdfs);

  select(STDIN_FILENO+1, &rdfs, NULL, NULL, &tv);
  return FD_ISSET(STDIN_FILENO, &rdfs);
}

inline int GetLastError()
{
	return errno;
}
#endif