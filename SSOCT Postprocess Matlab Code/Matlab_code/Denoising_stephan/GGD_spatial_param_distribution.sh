#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 16
#$ -N GGD_fitting
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; spatial_GGD_param_distribution; exit"

