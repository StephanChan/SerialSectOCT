#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 1
#$ -N OCT_despeckle
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; oct_speckle_denoise_ggd; exit"

