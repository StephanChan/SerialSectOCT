#!/bin/bash -l

#$ -l h_rt=1:00:00
#$ -pe omp 4
#$ -N fitting_after_recon
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "id='$SGE_TASK_ID'; Fitting_after_recon; exit"

