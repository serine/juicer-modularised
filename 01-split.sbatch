#!/bin/bash

#SBATCH --job-name=split
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=7000
#SBATCH --cpus-per-task=48
#SBATCH --array=1-32

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

threads=48
input=fqs.txt

fq1=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))
fq2=${fq1/_R1/_R2}

res_dir="."

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

prefix="${res_dir}/$(basename ${fq1} _R1.fastq.gz)"

res_fn="${res_dir}/${prefix}"

seqkit split2 --read1 ${fq1} \
              --read2 ${fq2} \
              --by-part 20 \
              --seq-type dna \
              --threads ${threads} \
              --out-dir ${res_fn}
