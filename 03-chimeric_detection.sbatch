#!/bin/bash

#SBATCH --job-name=chimeric
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

input=sam_sorted.txt
#input=sam_sorted2.txt
sam=($(head -n ${SLURM_ARRAY_TASK_ID} ${input} | tail -1))
threads=48
sort_mem=330G

site_file="mm10_MboI_fixed.txt"
prefix=$(basename ${sam} .sam.gz)

res_dir="03-chimers-n-frags2"

if [[ ! -d ${res_dir} ]]
then
  mkdir ${res_dir}
fi

tmp_dir="TMP_DIR"

if [[ ! -d ${tmp_dir} ]]
then
  mkdir ${tmp_dir}
fi

chimer_exe="scripts/chimeric_blacklist.awk"
frag_exe="scripts/fragment2.pl"

#norm_fn="${res_dir}/${prefix}_norm.txt"
abnorm_fn="${res_dir}/${prefix}_abnorm.sam"
unmapped_fn="${res_dir}/${prefix}_unmapped.sam"

merged_fn="${res_dir}/${prefix}_merged_sort.txt.gz"

echo ""
echo "MSG: Initating additional filenames:"
echo ""
echo "       Normalised:      ${norm_fn}"
echo "       Abnormal reads:  ${abnorm_fn}"
echo "       Unmapped reads:  ${unmapped_fn}"
echo ""

touch ${abnorm_fn} ${unmapped_fn}

echo "MSG: Begining chimeric detection in -> ${prefix}"

            #${frag_exe} /dev/stdin ${site_file} | \
#time awk -v "fname1"=${norm_fn} \
time awk -v "fname1"=/dev/stdout \
         -v "fname2"=${abnorm_fn} \
         -v "fname3"=${unmapped_fn} \
         -f ${chimer_exe} \
         <(zcat ${sam}) | \
            ${frag_exe} ${site_file} | \
                sort -T ${tmp_dir} \
                     -S ${sort_mem} \
		             -k2,2d \
		             -k6,6d \
		             -k4,4n \
		             -k8,8n \
		             -k1,1n \
		             -k5,5n \
		             -k3,3n | pigz -p ${threads} > ${merged_fn}

pigz -p ${threads} ${abnorm_fn}
pigz -p ${threads} ${unmapped_fn}
