#!/bin/bash

#SBATCH --job-name=sort
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=7000
#SBATCH --cpus-per-task=48
#SBATCH --array=1-32

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

sort_mem=325G
#sort_mem=250G
threads=48
input=bams.txt
bam1=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))
bam2=${bam/_R1/_R2}

tmp_dir="TMP_DIR"

if [[ ! -d ${tmp_dir} ]]
then
  mkdir ${tmp_dir}
fi

res_dir="sam_sorted2"

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

sam_out="${res_dir}/$(basename ${bam1} _R1.bam).sam.gz"

echo "MSG: Beginning processing -> ${sam_out}"

sort -T ${tmp_dir} \
     -S ${sort_mem} \
     -k1,1f \
     -m \
     <(awk 'BEGIN{OFS="\t"}NF>=11{$1=$1"/1"; print}' <(sort -T ${tmp_dir} -S ${sort_mem} -k1,1f <(samtools view ${bam1}) ) ) \
     <(awk 'BEGIN{OFS="\t"}NF>=11{$1=$1"/2"; print}' <(sort -T ${tmp_dir} -S ${sort_mem} -k1,1f <(samtools view ${bam2}) ) ) | pigz -p ${threads} > ${sam_out}

echo "MSG: Successfully created -> ${sam_out}"
