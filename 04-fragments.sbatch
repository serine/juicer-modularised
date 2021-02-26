#!/bin/bash

#SBATCH --job-name=chimeric
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=7000
#SBATCH --cpus-per-task=1
#SBATCH --array=1-32

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

input=sam_sorted.txt
norm_fn=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))

site_file="mm10_MboI.txt"

prefix=$(basename ${sam} .sam.gz)

tmp_dir="TMP_DIR"

if [[ ! -d ${tmp_dir} ]]
then
  mkdir ${tmp_dir}
fi

res_dir="04-fragments"

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

merged_fn="${res_dir}/${prefix}_merged_sort.txt"
frag_exe="fragments2.pl"

time ${frag_exe} ${norm_fn} ${site_file} | \
            sort -T ${tmpdir} \
                 -S ${sort_mem} \
		         -k2,2d \
		         -k6,6d \
		         -k4,4n \
		         -k8,8n \
		         -k1,1n \
		         -k5,5n \
		         -k3,3n > ${merged_fn}

