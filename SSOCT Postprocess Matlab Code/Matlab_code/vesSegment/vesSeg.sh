#!/bin/bash -l

#$ -P npbssmic
#$ -pe omp 8
#$ -m ea
#$ -l h_rt=24:00:00
#$ -N vessel_segmentation
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "vesSeg_script; exit"

