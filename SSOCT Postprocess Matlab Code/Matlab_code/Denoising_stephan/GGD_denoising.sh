#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 4
#$ -N GGD_denoising
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; vol_denoising; exit"

