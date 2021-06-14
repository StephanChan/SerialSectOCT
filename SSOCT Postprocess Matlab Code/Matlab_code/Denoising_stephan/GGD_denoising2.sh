#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 8
#$ -N kernel_smooth
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; kernel_smooth; exit"

