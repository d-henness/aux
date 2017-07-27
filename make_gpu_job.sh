#!/bin/bash

#defaults
wtime='01:00:00'  # runtime limit
mem='2048M'       # memory per node
ngpu=1            # number of gpus
prog=''           # program to run, include the path
args=''           # args for the program
title=''          # title for the job
needarg=true      # true if the program needs args, false otherwise


while [ $# -gt 0 ]; do
  val=$1
  shift
  case $val in
    "-ng")
      ngpu=$1
      shift
    ;;
    "-t")
      wtime=$1
      shift
    ;;
    "-m")
      mem=$1
      shift
    ;;
    "-tt")
      title=$1
      shift
    ;;
    "-pr")
      prog=$1
      shift
    ;;
    "-na")
      needarg=false
    ;;
    *)
      args=$val
    ;;
  esac
done

if [[ -z $prog ]]; then
  echo Did not give a program to run
  exit
elif [[ -z $args ]] && [ "$needarg" = true ]; then
  echo Did not give arguments
  exit
elif [[ -z $title ]]; then
  echo Did not give a title
  exit
fi

cat << EOF > $title'_sub.sh'
#!/bin/bash
#SBATCH --account=def-mariusz
#SBATCH --gres=gpu:$ngpu
#SBATCH --mem=$mem
#SBATCH --time=$wtime
#SBATCH --job-name=$title
#SBATCH --output=%x-%j.out

echo ----------------------------------------
echo ----------------------------------------
echo began running on \`date\`
echo ----------------------------------------
echo ----------------------------------------
$prog $args
echo ----------------------------------------
echo ----------------------------------------
echo stopped running on \`date\`
echo ----------------------------------------
echo ----------------------------------------
EOF
