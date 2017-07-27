#!/bin/bash

kind=''
sym=''
nuc=''
exepath=/home/dhenness/prophet/exe
ver=dfratomgpu_binarysearch2.x
alljobs=false

while [ $# -gt 0 ]
do
  val=$1
  shift
  case $val in
    "-a")
       alljobs=true
     ;;
    "-gauss")
       nuc='gauss_'
     ;;
    "-point")
       nuc='point_'
     ;;
    "-S")
       sym='S'
       low=$1
       high=$2
       shift
       shift
     ;;
    "-P")
       sym='P'
       low=$1
       high=$2
       shift
       shift
     ;;
     "-D")
       sym='D'
       low=$1
       high=$2
       shift
       shift
     ;;
     "-F")
       sym='F'
       low=$1
       high=$2
       shift
       shift
     ;;
     *)
       job=$val
     ;;
  esac
done

if [[ -z $nuc ]]; then
  echo No nuc entered
  exit
fi

if [ "$alljobs" = true ]; then
  for file in *inp; do
    dir=`echo $file | sed 's/_.*$//'`
    mkdir $dir
    cp $file $dir/$file-orig
    OLDS=`echo $file | sed -e "s/^.*$nuc//" -e 's/s.*$//'`
    OLDP=`echo $file | sed -e "s/^.*$nuc.*s//" -e 's/p.*$//'`
    OLDD=`echo $file | sed -e "s/^.*$nuc.*p+//" -e 's/d.*$//'`
    OLDF=`echo $file | sed -e "s/^.*$nuc.*d+//" -e 's/f.*$//'`
    NEWS=$OLDS
    NEWP=$OLDP
    NEWD=$OLDD
    NEWF=$OLDF
    oldbs=`grep 'nbs' $file | sed -e 's/^.*nbs=//' -e 's/.end//'`
    echo Changing directory to $dir
    cd $dir
    rm *.inp
    rm *.sh
    i=$low
    while [ $i -le $high ]; do
      if [ $sym == 'S' ]; then
        let NEWS=$OLDS-$i
      elif [ $sym == 'P' ] && [ $OLDP -ne 0 ]; then
        let NEWP=$OLDP-$i
      elif [ $sym == 'D' ] && [ $OLDD -ne 0 ]; then
        let NEWD=$OLDD-$i
      elif [ $sym == 'F' ] && [ $OLDF -ne 0 ]; then
        let NEWF=$OLDF-$i
      fi
      newfile=$dir'_'$nuc$NEWS's'$NEWP'p-'$NEWP'p+'$NEWD'd-'$NEWD'd+'$NEWF'f-'$NEWF'f+.inp'
  
      if [ $OLDF -ne 0 ]; then
        newbs=$NEWS' '$NEWP' '$NEWP' '$NEWD' '$NEWD' '$NEWF' '$NEWF' '
      elif [ $OLDD -ne 0 ]; then
        newbs=$NEWS' '$NEWP' '$NEWP' '$NEWD' '$NEWD' '
      elif [ $OLDP -ne 0 ]; then
        newbs=$NEWS' '$NEWP' '$NEWP' '
      else
        newbs=$NEWS' '
      fi
  
      cp $file-orig $newfile
      sed -i -e "s/$oldbs/$newbs/" $newfile
      if [ $sym == 'S' ]; then
        sed -i -e "s/maxbs=$OLDS/maxbs=$NEWS/" $newfile
      fi
      make_gpu_job.sh -tt ${newfile%????} -pr $exepath/$ver \'$newfile\'
      let i=$i+1
    done
    ls *_sub.sh > jobsub.sh
    sed -i 's/^/sbatch /' jobsub.sh
    chmod +x jobsub.sh
    ./jobsub.sh
    cd ..
  done
else
  if [ -z "$job" ]; then
    echo no job given
    exit
  fi
  file="$job"
  dir=`echo $file | sed 's/_.*$//'`
  mkdir $dir
  cp $file $dir/$file-orig
  OLDS=`echo $file | sed -e "s/^.*$nuc//" -e 's/s.*$//'`
  OLDP=`echo $file | sed -e "s/^.*$nuc.*s//" -e 's/p.*$//'`
  OLDD=`echo $file | sed -e "s/^.*$nuc.*p+//" -e 's/d.*$//'`
  OLDF=`echo $file | sed -e "s/^.*$nuc.*d+//" -e 's/f.*$//'`
  NEWS=$OLDS
  NEWP=$OLDP
  NEWD=$OLDD
  NEWF=$OLDF
  oldbs=`grep 'nbs' $file | sed -e 's/^.*nbs=//' -e 's/.end//'`
  echo Changing directory to $dir
  cd $dir
  rm *.inp
  rm *.sh
  i=$low
  while [ $i -le $high ]; do
    if [ $sym == 'S' ]; then
      let NEWS=$OLDS-$i
    elif [ $sym == 'P' ] && [ $OLDP -ne 0 ]; then
      let NEWP=$OLDP-$i
    elif [ $sym == 'D' ] && [ $OLDD -ne 0 ]; then
      let NEWD=$OLDD-$i
    elif [ $sym == 'F' ] && [ $OLDF -ne 0 ]; then
      let NEWF=$OLDF-$i
    fi
    newfile=$dir'_'$nuc$NEWS's'$NEWP'p-'$NEWP'p+'$NEWD'd-'$NEWD'd+'$NEWF'f-'$NEWF'f+.inp'

    if [ $OLDF -ne 0 ]; then
      newbs=$NEWS' '$NEWP' '$NEWP' '$NEWD' '$NEWD' '$NEWF' '$NEWF' '
    elif [ $OLDD -ne 0 ]; then
      newbs=$NEWS' '$NEWP' '$NEWP' '$NEWD' '$NEWD' '
    elif [ $OLDP -ne 0 ]; then
      newbs=$NEWS' '$NEWP' '$NEWP' '
    else
      newbs=$NEWS' '
    fi

    cp $file-orig $newfile
    sed -i -e "s/$oldbs/$newbs/" $newfile
    make_gpu_job.sh -tt ${newfile%????} -pr $exepath/$ver \'$newfile\'
    let i=$i+1
  done
  ls *_sub.sh > jobsub.sh
  sed -i 's/^/sbatch /' jobsub.sh
  chmod +x jobsub.sh
  ./jobsub.sh
  cd ..
fi

