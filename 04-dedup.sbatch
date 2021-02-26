#!/bin/bash

#SBATCH --job-name=dedup
#SBATCH --account=df22
#SBATCH --partition=genomics
#SBATCH --qos=genomics
#SBATCH --time=04:00:00
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=7000
#SBATCH --cpus-per-task=1
#SBATCH --array=1-31

source /projects/df22/kirill/downloads/miniconda3/etc/profile.d/conda.sh
conda activate hic_cstm

input=merged-sorted-clean.txt
merged=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))

prefix=$(basename ${merged} _merged_sort.txt.gz)

res_dir="04-deduped/${prefix}/"

if [[ ! -d ${res_dir} ]]
then
  mkdir -p ${res_dir}
fi

dedup_exe="scripts/dups.awk"

touch ${res_dir}/dups.txt
touch ${res_dir}/optdups.txt
touch ${res_dir}/merged_nodups.txt

echo "MSG: Begining deduplication -> ${prefix}"

#time awk -f ${juiceDir}/scripts/common/dups.awk \
#         -v name=${outputdir}/ \
#         -v nowobble=1 \
#         ${merge_fn}


time awk -f ${dedup_exe} \
         -v name=${res_dir} \
         <(zcat ${merged})

