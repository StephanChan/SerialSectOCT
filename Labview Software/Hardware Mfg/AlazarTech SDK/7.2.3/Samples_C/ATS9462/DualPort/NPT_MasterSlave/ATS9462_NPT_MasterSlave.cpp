//---------------------------------------------------------------------------
//
// Copyright (c) 2008-2015 AlazarTech, Inc.
//
// AlazarTech, Inc. licenses this software under specific terms and
// conditions. Use of any of the software or derivatives thereof in any
// product without an AlazarTech digitizer board is strictly prohibited.
//
// AlazarTech, Inc. provides this software AS IS, WITHOUT ANY WARRANTY,
// EXPRESS OR IMPLIED, INCLUDING, WITHOUT LIMITATION, ANY WARRANTY OF
// MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. AlazarTech makes no
// guarantee or representations regarding the use of, or the results of the
// use of, the software and documentation in terms of correctness, accuracy,
// reliability, currentness, or otherwise; and you rely on the software,
// documentation and results solely at your own risk.
//
// IN NO EVENT SHALL ALAZARTECH BE LIABLE FOR ANY LOSS OF USE, LOSS OF
// BUSINESS, LOSS OF PROFITS, INDIRECT, INCIDENTAL, SPECIAL OR CONSEQUENTIAL
// DAMAGES OF ANY KIND. IN NO EVENT SHALL ALAZARTECH'S TOTAL LIABILITY EXCEED
// THE SUM PAID TO ALAZARTECH FOR THE PRODUCT LICENSED HEREUNDER.
//
//---------------------------------------------------------------------------

// AcqToDisk.cpp :
//
// This program demonstrates how to configure an ATS9350 to make a
// No-PreTrigger (NPT) AutoDMA acquisition.
//

#include <stdio.h>
#ifdef _WIN32
#include <conio.h>
#else
#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>
#endif
#include "AlazarError.h"
#include "AlazarApi.h"
#include "AlazarCmd.h"

// TODO: Specify the number of DMA buffers to allocate per board.

#define BUFFER_COUNT 4

// TODO: Specify the maximum number of boards supported by this program.

#define MAX_BOARDS 8

// Global variables

HANDLE BoardHandleArray[MAX_BOARDS] = { NULL };
U16 *BufferArray[MAX_BOARDS][BUFFER_COUNT] = { NULL };
double samplesPerSec = 0.;

// Forward declarations

BOOL ConfigureBoard(HANDLE boardHandle);
BOOL AcquireData(U32 boardCount);

#ifndef _WIN32
#define TRUE  1
#define FALSE 0

#define _snprintf snprintf

inline U32 GetTickCount(void);
inline void Sleep(U32 dwTime_ms);
inline int _kbhit (void);
inline int GetLastError();
#endif

//----------------------------------------------------------------------------
//
// Function    :  main
//
// Description :  Program entry point
//
//----------------------------------------------------------------------------

int main(int argc, char *argv[])
{
    // TODO: Select a board system

    U32 systemId = 1;

    // Find the number of boards in the board system

    U32 boardCount = AlazarBoardsInSystemBySystemID(systemId);
    if (boardCount < 1)
    {
        printf("Error: No boards found in system Id %d\n", systemId);
        return 1;
    }

    if (boardCount > MAX_BOARDS)
    {
        printf("Error: Board system has %u boards, but program was compilied to support up to %d boards.\n",
               boardCount,
               MAX_BOARDS);
        return 1;
    }

    // Get a handle to each board in the board system

    U32 boardIndex;
    for (boardIndex = 0; boardIndex < boardCount; boardIndex++)
    {
        U32 boardId = boardIndex + 1;
        BoardHandleArray[boardIndex] = AlazarGetBoardBySystemID(systemId, boardId);
        if (BoardHandleArray[boardIndex] == NULL)
        {
            printf("Error: Unable to open board system Id %u board Id %u\n", systemId, boardId);
            return 1;
        }
    }

    // Configure the sample rate, input, and trigger settings of each board

    for (boardIndex = 0; boardIndex < boardCount; boardIndex++)
    {
        if (!ConfigureBoard(BoardHandleArray[boardIndex]))
        {
            U32 boardId = boardIndex + 1;
            printf("Error: Configure board Id %u failed\n", boardId);
            return 1;
        }
    }

    // Make an acquisition, optionally saving sample data to a file

    if (!AcquireData(boardCount))
    {
        printf("Error: Acquisition failed\n");
        return 1;
    }

    return 0;
}

//----------------------------------------------------------------------------
//
// Function    :  ConfigureBoard
//
// Description :  Configure sample rate, input, and trigger settings
//
//----------------------------------------------------------------------------

BOOL ConfigureBoard(HANDLE boardHandle)
{
    RETURN_CODE retCode;

    // TODO: Specify the sample rate (see sample rate id below)

    samplesPerSec = 180000000.0;

    // TODO: Select clock parameters as required to generate this sample rate.
    //
    // For example: if samplesPerSec is 100.e6 (100 MS/s), then:
    // - select clock source INTERNAL_CLOCK and sample rate SAMPLE_RATE_100MSPS
    // - select clock source FAST_EXTERNAL_CLOCK, sample rate
    //   SAMPLE_RATE_USER_DEF, and connect a 100 MHz signal to the EXT CLK BNC
    //   connector.

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
    
    // TODO: Select channel A input parameters as required

    retCode = AlazarInputControlEx(boardHandle,
                                   CHANNEL_A,
                                   DC_COUPLING,
                                   INPUT_RANGE_PM_400_MV,
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
    
    // TODO: Select channel B input parameters as required

    retCode = AlazarInputControlEx(boardHandle,
                                   CHANNEL_B,
                                   DC_COUPLING,
                                   INPUT_RANGE_PM_400_MV,
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
    //
    // The board will wait for a for this amount of time for a trigger event.  If a trigger event does not arrive, then
    // the board will automatically trigger. Set the trigger timeout value to 0 to force the board to wait forever for a
    // trigger event.
    //
    // IMPORTANT:
    //
    // The trigger timeout value should be set to zero after appropriate trigger parameters have been determined,
    // otherwise the board may trigger if the timeout interval expires before a hardware trigger event arrives.

    double triggerTimeout_sec = 0;
    U32 triggerTimeout_clocks = (U32)(triggerTimeout_sec / 10.e-6 + 0.5);

    retCode = AlazarSetTriggerTimeOut(boardHandle, triggerTimeout_clocks);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarSetTriggerTimeOut failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    // TODO: Configure AUX I/O connector as required

    retCode = AlazarConfigureAuxIO(
        boardHandle, AUX_OUT_TRIGGER, 0);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarConfigureAuxIO failed -- %s\n", AlazarErrorToText(retCode));
        return FALSE;
    }

    return TRUE;
}

//----------------------------------------------------------------------------
//
// Function    :  AcquireData
//
// Description :  Perform an acquisition, optionally saving data to file.
//
//----------------------------------------------------------------------------

BOOL AcquireData(U32 boardCount)
{
    // There are no pre-trigger samples in NPT mode

    U32 preTriggerSamples = 0;

    // TODO: Select the number of post-trigger samples per record

    U32 postTriggerSamples = 2048;

    // TODO: Specify the number of records per DMA buffer

    U32 recordsPerBuffer = 10;

    // TODO: Specifiy the total number of buffers to capture

    U32 buffersPerAcquisition = 10;
    
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

    HANDLE systemHandle = BoardHandleArray[0];

    // Get the sample size in bits, and the on-board memory size in samples per
    // channel

    U8 bitsPerSample;
    U32 maxSamplesPerChannel;
    RETURN_CODE retCode = AlazarGetChannelInfo(
        systemHandle, &maxSamplesPerChannel, &bitsPerSample);
    if (retCode != ApiSuccess)
    {
        printf("Error: AlazarGetChannelInfo failed -- %s\n",
               AlazarErrorToText(retCode));
        return FALSE;
    }

    // Calculate the size of each DMA buffer in bytes

    U32 bytesPerSample = (bitsPerSample + 7) / 8;
    U32 samplesPerRecord = preTriggerSamples + postTriggerSamples;
    U32 bytesPerRecord = bytesPerSample * samplesPerRecord;
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

    U32 boardIndex;
    U32 bufferIndex;

    for (boardIndex = 0; (boardIndex < boardCount) && success; boardIndex++)
    {
        for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success;
             bufferIndex++)
        {
            // Allocate page aligned memory
            BufferArray[boardIndex][bufferIndex] = (U16 *)AlazarAllocBufferU16(BoardHandleArray[boardIndex], bytesPerBuffer);

            if (BufferArray[boardIndex][bufferIndex] == NULL)
            {
                printf("Error: alloc %d bytes failed\n", bytesPerBuffer);
                success = FALSE;
            }
        }
    }

    // Prepare each board for an AutoDMA acquisition

    for (boardIndex = 0; (boardIndex < boardCount) && success; boardIndex++)
    {
        HANDLE boardHandle = BoardHandleArray[boardIndex];
        
        // Set the record size

        retCode = AlazarSetRecordSize(boardHandle, preTriggerSamples, postTriggerSamples);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarSetRecordSize failed -- %s\n", AlazarErrorToText(retCode));
            success = FALSE;
        }

        // Configure the board to make an AutoDMA acquisition

        if (success)
        {
            U32 recordsPerAcquisition =
                recordsPerBuffer * buffersPerAcquisition;

            retCode = AlazarBeforeAsyncRead(boardHandle,
                                            channelMask,
                                            -(long)preTriggerSamples,
                                            samplesPerRecord,
                                            recordsPerBuffer,
                                            recordsPerAcquisition,
                                            ADMA_EXTERNAL_STARTCAPTURE | ADMA_NPT);
            if (retCode != ApiSuccess)
            {
                printf("Error: AlazarBeforeAsyncRead failed -- %s\n", AlazarErrorToText(retCode));
                success = FALSE;
            }
        }
        

        // Add the buffers to a list of buffers available to be filled by this
        // board

        for (bufferIndex = 0; (bufferIndex < BUFFER_COUNT) && success;
             bufferIndex++)
        {
            U16 *pBuffer = BufferArray[boardIndex][bufferIndex];
            retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
            if (retCode != ApiSuccess)
            {
                printf("Error: AlazarPostAsyncBuffer %u failed -- %s\n", boardIndex, AlazarErrorToText(retCode));
                success = FALSE;
            }
        }
    }

    // Arm the board system to begin the acquisition

    if (success)
    {
        retCode = AlazarStartCapture(systemHandle);
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
        U32 buffersPerAcquisitionAllBoards = boardCount * buffersPerAcquisition;
        printf("Capturing %d buffers ... press any key to abort\n", buffersPerAcquisitionAllBoards);

        U32 startTickCount = GetTickCount();

        U32 buffersCompletedPerBoard = 0;
        U32 buffersCompletedAllBoards = 0;
        INT64 bytesTransferredAllBoards = 0;

        while (buffersCompletedPerBoard < buffersPerAcquisition)
        {
            // TODO: Set a buffer timeout that is longer than the time
            //       required to capture all the records in one buffer.

            U32 timeout_ms = 5000;

            // Wait for the buffer at the head of list of availalble buffers
            // to be filled by the board.

            bufferIndex = buffersCompletedPerBoard % BUFFER_COUNT;

            for (boardIndex = 0; (boardIndex < boardCount) && success; boardIndex++)
            {
                HANDLE boardHandle = BoardHandleArray[boardIndex];
                U16 *pBuffer = BufferArray[boardIndex][bufferIndex];
                retCode = AlazarWaitAsyncBufferComplete(boardHandle, pBuffer, timeout_ms);
                if (retCode != ApiSuccess)
                {
                    printf("Error: AlazarWaitAsyncBufferComplete failed -- %s\n", AlazarErrorToText(retCode));
                    success = FALSE;
                }

                if (success)
                {
                    // This buffer is full and has been removed from the list of
                    // buffers available to this board.

                    buffersCompletedAllBoards++;
                    bytesTransferredAllBoards += bytesPerBuffer;

                    // TODO: Process sample data in this buffer.

                    // NOTE:
                    //
                    // While you are processing this buffer, the board is
                    // filling the buffer at the head of the available buffer
                    // list.
                    //
                    // You MUST finish processing this buffer and post it back
                    // to the
                    // board before the board fills all of the available DMA
                    // buffers,
                    // and its on-board memory.
                    //
                    // Records are arranged in the buffer as follows: R0A, R1A, R2A ... RnA, R0B,
                    // R1B, R2B ...
                    // with RXY the record number X of channel Y
                    //
                    //
                    // Sample codes are unsigned by default. As a result:
                    // - a sample code of 0x0000 represents a negative full
                    // scale input signal.
                    // - a sample code of 0x8000 represents a ~0V signal.
                    // - a sample code of 0xFFFF represents a positive full
                    // scale input signal.

                    if (saveData)
                    {
                        // Write buffer to file

                        size_t bytesWritten = fwrite(
                            pBuffer, sizeof(BYTE), bytesPerBuffer, fpData);
                        if (bytesWritten != bytesPerBuffer)
                        {
                            printf("Error: Write buffer %u failed -- %u\n", buffersCompletedAllBoards, GetLastError());
                            success = FALSE;
                        }
                    }
                }

                if (success)
                {
                    // Add this buffer to the end of the list of buffers
                    // available to this board

                    retCode = AlazarPostAsyncBuffer(boardHandle, pBuffer, bytesPerBuffer);
                    if (retCode != ApiSuccess)
                    {
                        printf("Error: AlazarPostAsyncBuffer %u failed -- %s\n",
                               buffersCompletedAllBoards,
                               AlazarErrorToText(retCode));
                        success = FALSE;
                    }
                }
            }

            // If the acquisition failed, exit the acquisition loop

            if (!success)
                break;

            buffersCompletedPerBoard++;

            // If a key was pressed, exit the acquisition loop

            if (_kbhit())
            {
                printf("Aborted...\n");
                break;
            }

            // Display progress

            printf("Completed %u buffers\r", buffersCompletedAllBoards);
        }

        // Display results

        double transferTime_sec = (GetTickCount() - startTickCount) / 1000.;
        printf("Capture completed in %.2lf sec\n", transferTime_sec);

        double buffersPerSec;
        double bytesPerSec;
        if (transferTime_sec > 0.)
        {
            buffersPerSec = buffersCompletedAllBoards / transferTime_sec;
            bytesPerSec = bytesTransferredAllBoards / transferTime_sec;
        }
        else
        {
            buffersPerSec = 0.;
            bytesPerSec = 0.;
        }

        printf("Captured %d buffers (%.4g buffers per sec)\n", buffersCompletedAllBoards, buffersPerSec);
        printf("Transferred %I64d bytes (%.4g bytes per sec)\n", bytesTransferredAllBoards, bytesPerSec);
    }

    // Stop the acquisition

    for (boardIndex = 0; boardIndex < boardCount; boardIndex++)
    {
        retCode = AlazarAbortAsyncRead(BoardHandleArray[boardIndex]);
        if (retCode != ApiSuccess)
        {
            printf("Error: AlazarAbortAsyncRead %d failed -- %s\n", boardIndex, AlazarErrorToText(retCode));
            success = FALSE;
        }
    }

    // Free all memory allocated

    for (boardIndex = 0; boardIndex < boardCount; boardIndex++)
    {
        for (bufferIndex = 0; bufferIndex < BUFFER_COUNT; bufferIndex++)
        {
            if (BufferArray[boardIndex][bufferIndex] != NULL)
            {
				AlazarFreeBufferU16(BoardHandleArray[boardIndex], BufferArray[boardIndex][bufferIndex]);
            }
        }
    }

    // Close the data file

    if (fpData != NULL)
        fclose(fpData);

    return success;
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