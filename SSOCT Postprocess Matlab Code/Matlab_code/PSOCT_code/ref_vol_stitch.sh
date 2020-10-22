#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 4
#$ -N ref_vol_stitch
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; ref_vol_stitch; exit"

