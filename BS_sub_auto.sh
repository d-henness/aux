#!/bin/bash

kind='both' # can be equal to 'm' for minus sym, 'p' for plus sym, or 'both' for both sym
sym=''
nuc=''
exepath=/home/dhenness/prophet/exe
ver=dfratomgpu_binarysearch2.x
alljobs=false
bottom=false
wtime=01:00:00

while [ $# -gt 0 ]
do
  val=$1
  shift
  case $val in
    "-a")
       alljobs=true
     ;;
    "-b")
      bottom=true
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
     "-t")
       wtime=$1
       shift
     ;;
     "-k")
       kind=$1
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
  job=`ls *inp`
elif [ -z "$job" ]; then
  echo no job given
  exit
fi

for file in $job; do
  dir=`echo $file | sed 's/_.*$//'`
  mkdir $dir
  cp $file $dir/$file-orig
  OLDS=`echo $file | sed -e "s/^.*$nuc//" -e 's/s.*$//'`
  OLDPm=`echo $file | sed -e "s/^.*$nuc.*s//" -e 's/p.*$//'`
  OLDPp=`echo $file | sed -e "s/^.*$nuc.*p-//" -e 's/p.*$//'`
  OLDDm=`echo $file | sed -e "s/^.*$nuc.*p+//" -e 's/d.*$//'`
  OLDDp=`echo $file | sed -e "s/^.*$nuc.*d-//" -e 's/d.*$//'`
  OLDFm=`echo $file | sed -e "s/^.*$nuc.*d+//" -e 's/f.*$//'`
  OLDFp=`echo $file | sed -e "s/^.*$nuc.*f-//" -e 's/f.*$//'`
  NEWS=$OLDS
  NEWPm=$OLDPm
  NEWPp=$OLDPp
  NEWDm=$OLDDm
  NEWDp=$OLDDp
  NEWFm=$OLDFm
  NEWFp=$OLDFp

  oldbs=`grep 'nbs' $file | sed -e 's/^.*nbs=//' -e 's/.end//'`
  if [ "$bottom" = true ]; then
    oldbottom=`grep 'start' $file | sed -e 's/^.*start=//' -e 's/.end//'`
    OLDSB=`echo $oldbottom | awk '{print $1}'`
    OLDPBm=`echo $oldbottom | awk '{print $2}'`
    OLDPBp=`echo $oldbottom | awk '{print $3}'`
    OLDDBm=`echo $oldbottom | awk '{print $4}'`
    OLDDBp=`echo $oldbottom | awk '{print $5}'`
    OLDFBm=`echo $oldbottom | awk '{print $6}'`
    OLDFBp=`echo $oldbottom | awk '{print $7}'`
    NEWSB=$OLDSB
    NEWPBm=$OLDPBm
    NEWPBp=$OLDPBp
    NEWDBm=$OLDDBm
    NEWDBp=$OLDDBp
    NEWFBm=$OLDFBm
    NEWFBp=$OLDFBp
  fi
  echo Changing directory to $dir
  cd $dir
  rm *.inp
  rm *.sh
  i=$low
  while [ $i -le $high ]; do
    if [ $sym == 'S' ]; then
      let NEWS=$OLDS-$i
    elif [ $sym == 'P' ] && [ $OLDPp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWPm=$OLDPm-$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWPp=$OLDPp-$i
      fi
    elif [ $sym == 'D' ] && [ $OLDDp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWDm=$OLDDm-$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWDp=$OLDDp-$i
      fi
    elif [ $sym == 'F' ] && [ $OLDFp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWFm=$OLDFm-$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWFp=$OLDFp-$i
      fi
    fi
    if [ $sym == 'S' ] && [ "$bottom" = true ]; then
      let NEWSB=$OLDSB+$i
    elif [ $sym == 'P' ] && [ "$bottom" = true ] && [ $OLDPp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWPBm=$OLDPBm+$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWPBp=$OLDPBp+$i
      fi
    elif [ $sym == 'D' ] && [ "$bottom" = true ] && [ $OLDDp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWDBm=$OLDDBm+$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWDBp=$OLDDBp+$i
      fi
    elif [ $sym == 'F' ] && [ "$bottom" = true ] && [ $OLDFp -ne 0 ]; then
      if [ "$kind" = 'm' ] || [ "$kind" = 'both' ]; then
        let NEWFBm=$OLDFBm+$i
      fi
      if [ "$kind" = 'p' ] || [ "$kind" = 'both' ]; then
        let NEWFBp=$OLDFBp+$i
      fi
    fi
    newfile=$dir'_'$nuc$NEWS's'$NEWPm'p-'$NEWPp'p+'$NEWDm'd-'$NEWDp'd+'$NEWFm'f-'$NEWFp'f+.inp'

    if [ $OLDFp -ne 0 ]; then
      newbs=$NEWS' '$NEWPm' '$NEWPp' '$NEWDm' '$NEWDp' '$NEWFm' '$NEWFp' '
    elif [ $OLDDp -ne 0 ]; then
      newbs=$NEWS' '$NEWPm' '$NEWPp' '$NEWDm' '$NEWDp' '
    elif [ $OLDPp -ne 0 ]; then
      newbs=$NEWS' '$NEWPm' '$NEWPp' '
    else
      newbs=$NEWS' '
    fi

    if [ "$bottom" = true ];then
      if [ $OLDFp -ne 0 ]; then
        newbottom=$NEWSB' '$NEWPBm' '$NEWPBp' '$NEWDBm' '$NEWDBp' '$NEWFBm' '$NEWFBp' '
      elif [ $OLDDp -ne 0 ]; then
        newbottom=$NEWSB' '$NEWPBm' '$NEWPBp' '$NEWDBm' '$NEWDBp' '
      elif [ $OLDPp -ne 0 ]; then
        newbottom=$NEWSB' '$NEWPBm' '$NEWPBp' '
      else
        newbottom=$NEWSB' '
      fi
    fi

    cp $file-orig $newfile
    sed -i -e "s/$oldbs/$newbs/" $newfile
    if [ "$bottom" = true ];then
      sed -i -e "s/$oldbottom/$newbottom/" $newfile
    fi
    make_gpu_job.sh -tt ${newfile%????} -pr $exepath/$ver \'$newfile\' -t $wtime
    let i=$i+1
  done
  ls *_sub.sh > jobsub.sh
  sed -i 's/^/sbatch /' jobsub.sh
  chmod +x jobsub.sh
#  ./jobsub.sh
  cd ..
done
