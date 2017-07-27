#!/bin/bash

for JOB in *inp; do
cat << EOF > ${JOB%????}_sub.sh
#!/bin/bash
#SBATCH --account=def-mariusz
#SBATCH --gres=gpu:1              # request GPU "generic resource"
#SBATCH --mem=4000M               # memory per node
#SBATCH --time=0-01:00            # time (DD-HH:MM)
#SBATCH --job-name=${JOB%????}
#SBATCH --output=%x-%j.log        # %N for node name, %j for jobID
echo '------------------------------------'
echo '------------------------------------'
date
echo '------------------------------------'
echo '------------------------------------'
dfratomrun.sh $JOB
echo '------------------------------------'
echo '------------------------------------'
date
echo '------------------------------------'
echo '------------------------------------'
EOF
done

ls *_sub.sh > jobsub.sh
sed -i 's/^/sbatch /' jobsub.sh
chmod +x jobsub.sh
