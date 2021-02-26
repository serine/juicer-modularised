#!/bin/bash

#SBATCH --job-name=bam_merge
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4000
#SBATCH --cpus-per-task=1
#SBATCH --array=1-64

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

input=merged_bams.txt

bams_list=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))

res_dir="bams"

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

bam_fn="${res_dir}/$(basename ${bams_list} .txt).bam"

echo samtools cat -o ${bam_fn} -b ${bams_list}
samtools cat -o ${bam_fn} -b ${bams_list}
