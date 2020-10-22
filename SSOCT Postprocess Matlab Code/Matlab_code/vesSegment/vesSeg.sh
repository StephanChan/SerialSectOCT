#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 16
#$ -N TDE
#$ -j y

module load matlab/2019b
matlab -nodisplay -singleCompThread -r "vesSeg_script; exit"

