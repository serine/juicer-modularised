#!/bin/bash

#SBATCH --job-name=map
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=7000
#SBATCH --cpus-per-task=48
#SBATCH --array=1-160

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

threads=48
input=${FASTQIN}
fq=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))

res_dir="bams-splits"

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

bwa_idx="/scratch/df22/kirill/projects/BrendanRuss/T-cells-differentiation2.Hi-C.2020.04.01/refFiles/bwaIdx/Mus_musculus.GRCm38.dna.core.fa.gz"

bam="${res_dir}/$(basename ${fq} .fastq.gz).bam"

bwa mem -K 10000000 \
        -t ${threads} \
        ${bwa_idx} \
        ${fq} | \
            samtools view -Sb - > ${bam}
