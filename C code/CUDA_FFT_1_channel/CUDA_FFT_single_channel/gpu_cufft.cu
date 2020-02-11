// Serial_code.cpp : This file contains the 'main' function. Program execution begins and ends there.
//



#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include <string.h>
#include <cstdio>
#include <cstdlib>
//#include <time.h>
#include <math.h>
//#include "cuPrintf.cu"
//#include "cuPrintf.cuh"
#include <cuda_runtime.h>
#include <cufft.h>
#include <cufftXt.h>
#include <helper_cuda.h>
#include <helper_functions.h>
//#define NUM_STREAMS 4
//#define NUM_BLINES 40
//#define NBLINES 1100
//#define NALINES 1250
//#define SAMPLES 1440
//#define DEPTH   100
#define SWAP(a,b) tempr=(a); (a)=(b); (b)=tempr
#define data_t float
#define PI 3.14159265359
#define sample_f 1000
#define signal_f 100
#define PRINT_TIME 1

extern "C" __declspec(dllexport) void single_channel_process(uint16_t *h_signal, data_t *h_processed_signal, int z0, int DEPTH, int a, int b, int NALINES, int NBLINES, int SAMPLES);
int main(int argc, char **argv) {
    uint16_t *h_signal;
    data_t *h_processed_signal;
    FILE *fp;
    long long int i;
	
	int NALINES = 1250;
	int NBLINES = 1100;
	int SAMPLES = 1440;
	int DEPTH = 100;

    long long int length_raw = (long long int)SAMPLES * (long long int)NALINES * (long long int)NBLINES * (long long int)1;   //FIXME: can not initialize a number this big
    long long int length_data = (long long int)DEPTH * (long long int)1 * (long long int)NALINES * (long long int)NBLINES;
    //printf("size of h_signal is %lld, %lld\n", (long long int)length_raw, (long long int)length_raw*sizeof(uint16_t));
    h_signal = (uint16_t *)malloc(sizeof(uint16_t) * (long long int)length_raw);   //1440*1100*1250*2
	//h_FFT_buffer = (data_t *)malloc(sizeof(data_t)*NALINES * 4096 * 20);
    h_processed_signal = (data_t *)malloc(sizeof(data_t) * (long long int)length_data);  //600*1100*1250
	
    // init raw data
    /*for (i = 0; i < length_raw; i++) {
      h_signal[i] = (uint16_t)((sin(2*PI*signal_f*i/sample_f)+1)/2*65535);
    }
	*/
	fp = fopen("C:\\Users\\BOAS-USER\\Documents\\Data\\200121 layered glass sample\\spectral data\\1-1-1440-1250-1100-A0.dat","rb");
	if (fp != NULL) {
		fread(h_signal, sizeof(uint16_t), length_raw, fp);
		fclose(fp);
		printf("read file success\n");
	}
	else
		printf("open file failed\n");
	//printf("%d %d\n", h_signal[0], h_signal[100]);
	/*fp = fopen("h_signal.txt", "w");
	if (fp != NULL) {
		for (i = 0; i < NALINES * SAMPLES * 40; i++)
			fprintf(fp, "%d, %d\n", i, h_signal[i]);
		//for (i = 0; i < NALINES * SAMPLES * 40; i++)
		//	fprintf(fp, "%d, %d\n", i, h_signal[i]);
		fclose(fp);
		printf("write to file success\n");
	}
	else
		printf("open file failed\n");*/
	//for (i = 0; i < length_data; i++) {
	//	h_processed_signal[i] =-1;
	//}

    //fopen_s(&fp, "", "rb");
    //fread(h_signal, 2, length_raw, fp);
    //fclose(fp);
    //printf("finished initializing data, size of processed data: %lld\n", (long long int)length_data* sizeof(data_t));
    printf("start processing...\n");
	single_channel_process(h_signal, h_processed_signal, 0,DEPTH,0,0,NALINES, NBLINES, SAMPLES);
	printf("finished processing...\n");
	//printf("finished processing data, size of processed data: %lld\n", (long long int)length(h_processed_signal));
    /*fp=fopen("data.dat", "w");
	if (fp != NULL) {
		fwrite(h_processed_signal, sizeof(data_t), length_data, fp);
		fclose(fp);
		printf("write to file success\n");
	}
	else
		printf("open file failed\n");
		*/
	/*
	fp = fopen("GPU_h_FFT_buffer.txt", "w");
	if (fp != NULL) {
		for(i= 0;i<NALINES*4096*10;i++)
		   fprintf(fp,"%d, %f\n",i, h_FFT_buffer[i]);
		fclose(fp);
		printf("write to file success\n");
	}
	else
		printf("open file failed\n");
		*/
	/*
	fp = fopen("GPU_h_processed.txt", "w");
	if (fp != NULL) {
		for (i = 0; i < NALINES * DEPTH * NBLINES; i++)
			fprintf(fp, "%d, %.10f\n", i, h_processed_signal[i]);
		fclose(fp);
		printf("write to file success\n");
	}
	else
		printf("open file failed\n");
		*/
return 0;
}


void single_channel_process(uint16_t *h_signal, data_t *h_processed_signal, int z0, int DEPTH, int a, int b, int NALINES, int NBLINES, int SAMPLES) {
    void my_cufft(uint16_t *h_signalA, data_t *dispersion, data_t *hann, data_t *h_processed_signal, int z0, int DEPTH, int numBline, int NALINES);
	//cudaEvent_t start, stop;
    //float elapsed_gpu;
    long long int i;
	int size1, size2, size3;
	//change size1, size2, size3 for difference NBLINES
	size1 = 400;
	size2 = 400;
	size3 = 300;
    data_t *dispersion, *d_dispersion, *hann, *d_hann;
    data_t f, arg;
    data_t k0,k1,dk,kc;
    data_t   *d_processed;
    uint16_t *d_dataA;
    dispersion = (data_t *) malloc(sizeof(data_t) * SAMPLES * 2);
    //init dispersion compensation array
	k0 = 2 * PI / 1363 ;
	k1 = 2 * PI / 1227 ;
	kc = 2 * PI / 1295 ;
	dk = (k1 - k0) / (SAMPLES-1);
    a = data_t(a * pow(10, 4));
    b = data_t(b * pow(10, 6));

    for (i = 0; i < SAMPLES; i ++) {
        f = 3 * (k0 - kc + (i) * dk);
        arg = a * pow(f, 2) + b * pow(f, 3);
        dispersion[2*i] = (data_t) cos(arg);
        dispersion[2*i + 1] = (data_t) sin(arg);
		//printf("%.10f, %.10f\n", dispersion[2*i],dispersion[2*i+1]);
        //dispersion[2*i] = 1;
        //dispersion[2*i+1] = 0;
    }

	//init hann window array
	hann= (data_t *)malloc(sizeof(data_t) * SAMPLES);
	for (i = 0; i < SAMPLES; i++) {
		hann[i] = 0.5*(1 - cos(2 * PI*i / (SAMPLES-1)));
		//printf("%.10f\n", hann[i]);
	}

//#if PRINT_TIME
    // Create the cuda events
//    cudaEventCreate(&start);
//    cudaEventCreate(&stop);
   /* cudaEventCreate(&start_kernel);
    cudaEventCreate(&stop_kernel);
    cudaEventCreate(&start_malloc);
    cudaEventCreate(&stop_malloc);
    cudaEventCreate(&start_mempyHD);
    cudaEventCreate(&stop_mempyHD);
    cudaEventCreate(&start_mempyDH);
    cudaEventCreate(&stop_mempyDH);*/
    // Record event on the default stream
//    cudaEventRecord(start, 0);
//#endif
    //cudaEventRecord(start_malloc, 0);
	checkCudaErrors(cudaMalloc((void **) &d_dataA, (long long int)NALINES * (long long int)size1 * (long long int)sizeof(uint16_t) * (long long int)SAMPLES*1));
	checkCudaErrors(cudaMalloc((void **) &d_processed, (long long int)NALINES * size1 * sizeof(data_t) * 1 * DEPTH));
	checkCudaErrors(cudaMalloc((void **) &d_dispersion, sizeof(data_t) * SAMPLES * 2));
	checkCudaErrors(cudaMalloc((void **)&d_hann, sizeof(data_t) * SAMPLES));
    //cudaEventRecord(stop_malloc, 0);
    //cudaEventSynchronize(stop_malloc);

	//cudaMemset(d_processed, 0, (long long int)NALINES * size1 * sizeof(data_t) * 1 * DEPTH);
 //first part of data
	
    //cudaEventRecord(start_mempyHD, 0);
	checkCudaErrors(
            cudaMemcpy(d_dataA, h_signal, (long long int)NALINES * size1 * sizeof(uint16_t) * SAMPLES*1, cudaMemcpyHostToDevice));
	
	checkCudaErrors(cudaMemcpy(d_dispersion, dispersion, sizeof(data_t) * SAMPLES * 2, cudaMemcpyHostToDevice));
	checkCudaErrors(cudaMemcpy(d_hann, hann, sizeof(data_t) * SAMPLES, cudaMemcpyHostToDevice));
   //// cudaEventRecord(stop_mempyHD, 0);
   // cudaEventSynchronize(stop_mempyHD);
	//printf("finished memcopy host to device first half\n");
//    cudaPrintfInit();
    // Launch the kernel
    //dim3 dimBlock(32, 32, 1);
    //dim3 dimGrid(9, 39, 1);
    //cudaEventRecord(start_kernel, 0);
    //kernel_process << < dimGrid, dimBlock >> > (d_dataA, d_dataB, d_dispersion, d_processed, z0);
    my_cufft(d_dataA, d_dispersion, d_hann, d_processed, z0, DEPTH, size1, NALINES);
   // cudaEventRecord(stop_kernel, 0);
   // cudaEventSynchronize(stop_kernel);
//    cudaPrintfDisplay(stdout, true);
//    cudaPrintfEnd();
    // Check for errors during launch
    //CUDA_SAFE_CALL(cudaPeekAtLastError());
    // Transfer the results back to the host
	//printf("finished process first half\n");
   // cudaEventRecord(start_mempyDH, 0);
	checkCudaErrors(cudaMemcpy(h_processed_signal, d_processed, NALINES * size1 * sizeof(data_t) * 1 * DEPTH,
                              cudaMemcpyDeviceToHost));
   // cudaEventRecord(stop_mempyDH, 0);
   // cudaEventSynchronize(stop_mempyDH);
	//printf("finished memcopy device to host for first half\n");
	
 //second part
	//checkCudaErrors(cudaMemcpy(d_dispersion, dispersion, sizeof(data_t) * 2048 * 2, cudaMemcpyHostToDevice));
	//checkCudaErrors(cudaMemcpy(d_hann, hann, sizeof(data_t) * SAMPLES, cudaMemcpyHostToDevice));
    checkCudaErrors(
            cudaMemcpy(d_dataA, h_signal+(long long int)NALINES*size1*SAMPLES*1, (long long int)NALINES * size2 * sizeof(uint16_t) * SAMPLES*1, cudaMemcpyHostToDevice));
   
    //cudaEventRecord(start_kernel, 0);
    //kernel_process << < dimGrid, dimBlock >> > (d_dataA, d_dataB, d_dispersion, d_processed, z0);
    my_cufft(d_dataA, d_dispersion, d_hann, d_processed, z0, DEPTH, size2, NALINES);
	//printf("finished process second half\n");
    //cudaEventRecord(stop_kernel, 0);
    //cudaEventSynchronize(stop_kernel);
    //cudaPrintfDisplay(stdout, true);
   // cudaPrintfEnd();
    // Check for errors during launch
    //CUDA_SAFE_CALL(cudaPeekAtLastError());
    // Transfer the results back to the host
	checkCudaErrors(cudaMemcpy(h_processed_signal+(long long int)NALINES *size1 * 1 * DEPTH, d_processed, (long long int)NALINES * size2 * sizeof(data_t) * 1 * DEPTH,
                              cudaMemcpyDeviceToHost));
//third part
	checkCudaErrors(
		cudaMemcpy(d_dataA, h_signal + (long long int)NALINES*(size1+size2)*SAMPLES *1, (long long int)NALINES * size3 * sizeof(uint16_t)  * SAMPLES*1, cudaMemcpyHostToDevice));
	
	//cudaEventRecord(start_kernel, 0);
	//kernel_process << < dimGrid, dimBlock >> > (d_dataA, d_dataB, d_dispersion, d_processed, z0);
	my_cufft(d_dataA, d_dispersion, d_hann, d_processed, z0, DEPTH, size3, NALINES);
	//printf("finished process third half\n");
	//cudaEventRecord(stop_kernel, 0);
	//cudaEventSynchronize(stop_kernel);
	//cudaPrintfDisplay(stdout, true);
   // cudaPrintfEnd();
	// Check for errors during launch
	//CUDA_SAFE_CALL(cudaPeekAtLastError());
	// Transfer the results back to the host
	checkCudaErrors(cudaMemcpy(h_processed_signal + (long long int)NALINES * (size1+size2) * 1 * DEPTH, d_processed, (long long int)NALINES * size3 * sizeof(data_t) * 1 * DEPTH,
		cudaMemcpyDeviceToHost));
	
		
	checkCudaErrors(cudaFree(d_dataA));
	checkCudaErrors(cudaFree(d_processed));
	checkCudaErrors(cudaFree(d_dispersion));
	checkCudaErrors(cudaFree(d_hann));
	//printf("finished process\n");
	/*
#if PRINT_TIME
    // Stop and destroy the timer
    cudaEventRecord(stop,0);
    cudaEventSynchronize(stop);
    cudaEventElapsedTime(&elapsed_gpu, start, stop);
    printf("\nGPU time: %f (msec)\n", elapsed_gpu);
    cudaEventDestroy(start);
    cudaEventDestroy(stop);
	
	/*
    cudaEventElapsedTime(&elapsed_gpu, start_kernel, stop_kernel);
    printf("\nkernel time: %f (msec)\n", elapsed_gpu*2.75);
    cudaEventDestroy(start_kernel);
    cudaEventDestroy(stop_kernel);
	
    cudaEventElapsedTime(&elapsed_gpu, start_malloc, stop_malloc);
    printf("\nmalloc time: %f (msec)\n", elapsed_gpu);
    cudaEventDestroy(start_malloc);
    cudaEventDestroy(stop_malloc);

    cudaEventElapsedTime(&elapsed_gpu, start_mempyHD, stop_mempyHD);
    printf("\nmemcpy Host to Device time: %f (msec)\n", elapsed_gpu*2.75);
    cudaEventDestroy(start_mempyHD);
    cudaEventDestroy(stop_mempyHD);

    cudaEventElapsedTime(&elapsed_gpu, start_mempyDH, stop_mempyDH);
    printf("\nmemcpy Device to Host time: %f (msec)\n", elapsed_gpu*2.75);
    cudaEventDestroy(start_mempyDH);
    cudaEventDestroy(stop_mempyDH);
#endif
	*/
    cudaDeviceReset();
}


static __global__ void copy_data(long long int length_fft_data, int part, data_t *FFT_buffer, uint16_t *d_signal, data_t *hann) {
	//copy data to compex FFT buffer
	const int blockID = blockIdx.x + blockIdx.y*gridDim.x;
	const int threadID = blockID * (blockDim.x*blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
	const int numThreads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;
	//cuPrintf("blockID: %d, threadID: %d, numTHreads: %d, datanum:%d\n", blockID, threadID, numThreads, length_fft_data);
	long long int i;
	for (i = threadID; i < length_fft_data; i += numThreads) {
		long long int k = (i % 1440) * 2 + long long int(i / 1440) * 4096;
	    FFT_buffer[k] = (d_signal[i + (long long int)part*length_fft_data]*0.8/65535-0.4)*hann[i % 1440];
		//cuPrintf("FFT_buffer %d is %f\n", i + (long long int)part*length_fft_data, FFT_buffer[k]);
	}
	
}

static __global__ void my_hilbert(data_t *FFT_buffer, long long int length_fft) {
	const int blockID = blockIdx.x + blockIdx.y*gridDim.x;
	const int threadID = blockID * (blockDim.x*blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
	const int numThreads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;

	long long int i;
	for (i = threadID; i < long long int(length_fft / 2); i += numThreads) {
		//new_data[i % 1440*2 + i / 1440 * 4096] = old_data[i]
		long long int k =( i % 2048) + long long int(i / 2048) * 4096;
		if (i % 2048 > 1) {
			FFT_buffer[k] = 2 * FFT_buffer[k] / 2048;
			FFT_buffer[k + 2048] = 0;
			//cuPrintf("FFT_buffer is %f, %f\n", FFT_buffer[k], FFT_buffer[k + 2048]);
		}
		else {
			FFT_buffer[k] = FFT_buffer[k] / 2048;
			FFT_buffer[k + 2048] = 0;
		}
	}
}

static __global__ void my_dispersion(data_t *FFT_buffer, data_t *dispersion, long long int length_fft_data) {
	const int blockID = blockIdx.x + blockIdx.y*gridDim.x;
	const int threadID = blockID * (blockDim.x*blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
	const int numThreads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;
	long long int i;
	for (i = threadID; i < length_fft_data; i += numThreads) {
		long long int k = (i % 1440) * 2 + long long int(i / 1440) * 4096;
		int d = (i % 1440) * 2;
	//dispersion compensation
		data_t a = FFT_buffer[k];
		data_t b = FFT_buffer[k+1];
		FFT_buffer[k] = (a * dispersion[d] - b * dispersion[d + 1]);
		FFT_buffer[k + 1] = (a * dispersion[d + 1] + b * dispersion[d]);
		//cuPrintf("FFT_buffer %d is %.10f, %.10f\n", k, FFT_buffer[k], FFT_buffer[k+1]);
	}
}
/*
static __global__ void calc(data_t *FFT_buffer, int num_Blines_per_FFT, int part, data_t *d_processed, int z0, int DEPTH, int NALINES) {
	const int numThreads = blockDim.x * gridDim.x;
	const int threadID = blockIdx.x * blockDim.x + threadIdx.x;
	long long int i;
	long long range = NALINES * DEPTH *num_Blines_per_FFT;
	long long int step = part * num_Blines_per_FFT*NALINES*DEPTH * 3;
	for (i = threadID; i < range; i += numThreads) {
		long long int k = i % DEPTH *3  + i *3;
		long long int d = i % (DEPTH*NALINES)/DEPTH*4096 + i / DEPTH /NALINES*NALINES*1440*2 + (i % (DEPTH*NALINES) % DEPTH+z0)*3;
			data_t a = (data_t)(pow(FFT_buffer[d], 2) + pow(FFT_buffer[d + 1], 2));
			data_t p = (data_t)atan(FFT_buffer[d + 1] / FFT_buffer[d]);
			data_t a2 = (data_t)(pow(FFT_buffer[d+4096*NALINES], 2) + pow(FFT_buffer[d + 1 + 4096 * NALINES], 2));
			data_t p2 = (data_t)atan(FFT_buffer[d + 1 + 4096 * NALINES] / FFT_buffer[d + 4096 * NALINES]);

			d_processed[k + step] = a + a2;
			d_processed[k+1 + step] = (data_t)atan(sqrt(a / a2));
			d_processed[k+2 + step] = p - p2;
		
	}
}
*/
static __global__ void calc_amp(data_t *FFT_buffer, int num_Blines_per_FFT, int part, data_t *d_processed, int z0, int DEPTH, int NALINES) {
	const int blockID = blockIdx.x + blockIdx.y*gridDim.x;
	const int threadID = blockID * (blockDim.x*blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
	const int numThreads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;

	long long int i;
	long long range = (long long int)num_Blines_per_FFT*NALINES * DEPTH;
	long long int step = (long long int)part * num_Blines_per_FFT*NALINES*DEPTH * 1;
	for (i = threadID; i < range; i += numThreads) {
		long long int k = i;   //
		long long int d = long long int(i / DEPTH) *4096 + (i % DEPTH + z0) * 2;
		data_t a = (data_t)sqrt(pow(FFT_buffer[d]/1440, 2) + pow(FFT_buffer[d + 1]/1440, 2));
		//data_t p = (data_t)atan(FFT_buffer[d + 1] / FFT_buffer[d]);
		//data_t a2 = (data_t)(pow(FFT_buffer[d + 4096 * NALINES], 2) + pow(FFT_buffer[d + 1 + 4096 * NALINES], 2));
		//data_t p2 = (data_t)atan(FFT_buffer[d + 1 + 4096 * NALINES] / FFT_buffer[d + 4096 * NALINES]);
		//cuPrintf("i is %d, d is %d, a is %f, FFT_buffer is%f\n", i, d, a, FFT_buffer[d]);
		d_processed[k + step] = a;
		//d_processed[k + 1 + step] = (data_t)atan(sqrt(a / a2));
		//d_processed[k + 2 + step] = p - p2;

	}
}

/*
static __global__ void printf_data(data_t *FFT_buffer, long long int length_fft) {
	const int blockID = blockIdx.x + blockIdx.y*gridDim.x;
	const int threadID = blockID * (blockDim.x*blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
	const int numThreads = blockDim.x * blockDim.y * gridDim.x * gridDim.y;

	long long int i;
	for (i = threadID; i < 10; i += numThreads) {
		cuPrintf("i: %d, FFT_buffer:%.10f\n", i, sqrt(FFT_buffer[i+20*1250*100]));
	}
}
*/
void my_cufft(uint16_t *d_signal, data_t *dispersion, data_t *hann, data_t *d_processed, int z0, int DEPTH, int numBline, int NALINES) {
    int num_Blines_per_FFT;
    int part;
    long long int length_fft, length_fft_data;
    num_Blines_per_FFT=20;
    length_fft=(long long int)num_Blines_per_FFT*NALINES*4096;
    length_fft_data=(long long int)num_Blines_per_FFT*NALINES*1440;
	data_t *FFT_buffer;
    //cufftHandle* plan = (cufftHandle *)malloc(sizeof(cufftHandle));
	cufftHandle plan;
	cufftPlan1d(&plan, 2048, CUFFT_C2C, (long long int)NALINES * num_Blines_per_FFT);
	checkCudaErrors(cudaMalloc((void **) &FFT_buffer, sizeof(data_t) * length_fft));
	dim3 dimBlock(32, 32, 1);
	dim3 dimGrid(20, 20, 1);
	//dim3 a(1, 1, 1);
	//dim3 b(1, 1, 1);
    

    for(part=0; part< numBline/num_Blines_per_FFT; part++){
		//printf("part= %d   ,length_fft=%lld, length_fft_data=%lld , %ld\n", part, length_fft, length_fft_data, plan);
        //copy data to compex FFT buffer
		cudaMemset(FFT_buffer, 0, length_fft * (long long int)sizeof(data_t));
		copy_data << <dimBlock , dimGrid>> > (length_fft_data, part, FFT_buffer, d_signal, hann);

		//printf_data << <a, b >> > (FFT_buffer, length_fft);
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
        //Hilbert transform
        checkCudaErrors(cufftExecC2C(plan, reinterpret_cast<cufftComplex *>(FFT_buffer), reinterpret_cast<cufftComplex *>(FFT_buffer), CUFFT_FORWARD));
        
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
		my_hilbert << <dimBlock, dimGrid>> > ((data_t *)FFT_buffer, length_fft);
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
		//printf("finished hilbert\n");
        checkCudaErrors(cufftExecC2C(plan, reinterpret_cast<cufftComplex *>(FFT_buffer), reinterpret_cast<cufftComplex *>(FFT_buffer), CUFFT_INVERSE));
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
		//printf_data << <a, b >> > (dispersion, length_fft);
        //dispersion compensation
		my_dispersion << <dimBlock, dimGrid>> > ((data_t *)FFT_buffer, dispersion, length_fft_data);
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
        //to space domain
        checkCudaErrors(cufftExecC2C(plan, reinterpret_cast<cufftComplex *>(FFT_buffer), reinterpret_cast<cufftComplex *>(FFT_buffer), CUFFT_FORWARD));
		//printf_data << <a, b >> > (FFT_buffer, length_fft);
		calc_amp << <dimBlock, dimGrid>> > ((data_t *)FFT_buffer, num_Blines_per_FFT, part, d_processed, z0, DEPTH, NALINES);
		//checkCudaErrors(cudaMemcpy(h_FFT_buffer, FFT_buffer, length_fft * sizeof(data_t),
		//	cudaMemcpyDeviceToHost));
		//printf_data << <a, b >> > (d_processed, length_fft);
    }
	
	checkCudaErrors(cudaFree(FFT_buffer));
	//checkCudaErrors(cudaFree(plan));
}


// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
