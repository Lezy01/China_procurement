#!/bin/bash
#SBATCH --job-name=proc_classify
#SBATCH --output=logs/log_%A_%a.out
#SBATCH --error=logs/log_%A_%a.err
#SBATCH --account=ssd
#SBATCH --partition=ssd
#SBATCH --time=01:00:00
#SBATCH --mem=18G
#SBATCH --array=0-40


module load python/anaconda-2022.05
source /software/python-anaconda-2022.05-el8-x86_64/etc/profile.d/conda.sh
conda activate procurement

FILE_LIST=(dta/batch_dta/*.pkl)
FILE=${FILE_LIST[$SLURM_ARRAY_TASK_ID]}

python classify.py $FILE
