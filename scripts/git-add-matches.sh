#!/bin/bash

export FILE_NAME=$1
export PATTERN=$2

# Credit: https://stackoverflow.com/a/37339566

diff=`mktemp`
git diff $FILE_NAME > $diff
[ -s $diff ] || exit

patch=`mktemp`

gawk -v pat="$PATTERN" '
function hh(){
  if(keep && n > 0){
    for(i=0;i<n;i++){
      if(i==hrn){
        printf "@@ -%d,%d +%d,%d @@\n", har[1],har[2],har[3],har[4];
      }
      print out[i];
    }
  }
}
{
  if(/^diff --git a\/.* b\/.*/){
    hh();
    keep=0;
    dr=NR;
    n=0;
    out[n++]=$0
  }
  else if(NR == dr+1 && /^index [0-9a-f]+\.\.[0-9a-f]+ [0-9]+$/){
    ir=NR;
    out[n++]=$0
  }
  else if(NR == ir+1 && /^\-\-\- a\//){
    mr=NR;
    out[n++]=$0
  }
  else if(NR == mr+1 && /^\+\+\+ b\//){
    pr=NR;
    out[n++]=$0
  }
  else if(NR == pr+1 && match($0, /^@@ \-([0-9]+),?([0-9]+)? \+([0-9]+),?([0-9]+)? @@/, har)){
    hr=NR;
    hrn=n
  }
  else if(NR > hr){
    if(/^\-/ && $0 !~ pat){
      har[4]++;
      sub(/^\-/, " ", $0);
      out[n++] = $0
    }
    else if(/^\+/ && $0 !~ pat){
      har[4]--;
    }
    else{
      if(/^[+-]/){
        keep=1
      }
      out[n++] = $0
    }
  }
}
END{
  hh()
}' $diff > $patch

git restore -- $FILE_NAME
git apply --recount $patch
git add $FILE_NAME

rm $diff
rm $patch
