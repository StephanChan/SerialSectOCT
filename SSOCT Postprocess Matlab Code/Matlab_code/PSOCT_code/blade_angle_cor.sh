#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 2
#$ -N blade_angle_cor
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; blade_angle_cor; exit"
