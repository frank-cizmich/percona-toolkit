#!/bin/bash

cat <<EOF > $TMPDIR/in
procs -----------memory---------- ---swap-- -----io---- --system-- -----cpu------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 0  0     68 288220 372588 13534140    0    0    24   138    1    1  4  1 94  1  0
 1  0     68 288080 372588 13534184    0    0     0   187  721  943  3  0 96  0  0
 0  0     68 287708 372588 13534276    0    0     0  1058  747  992  8  3 89  0  0
 1  0     68 287468 372588 13534340    0    0     0  1058  552  856 15  2 84  0  0
 1  0     68 287460 372588 13534388    0    0     0   322  859 1014 10  3 87  0  0
 0  0     68 287460 372588 13534444    0    0     0   214  612  729 10  3 88  0  0
 0  0     68 287460 372588 13534484    0    0     0   309  553  741  0  0 99  0  0
 1  0     68 287460 372588 13534532    0    0     2   197  605  727  2  1 97  0  0
 0  0     68 287344 372588 13534596    0    0     0  1037  485  626  0  0 99  0  0
 0  0     68 287220 372588 13534656    0    0     0   235  875 1004  0  0 99  0  0
EOF

cat <<EOF > $TMPDIR/expected
  procs  ---swap-- -----io---- ---system---- --------cpu--------
   r  b    si   so    bi    bo     ir     cs  us  sy  il  wa  st
   0  0     0    0    25   150      1      1   4   1  94   1   0
   1  0     0    0     0   175    700    900   3   0  96   0   0
   0  0     0    0     0  1000    700   1000   8   3  89   0   0
   1  0     0    0     0  1000    600    900  15   2  84   0   0
   1  0     0    0     0   300    900   1000  10   3  87   0   0
   0  0     0    0     0   225    600    700  10   3  88   0   0
   0  0     0    0     0   300    600    700   0   0  99   0   0
   1  0     0    0     2   200    600    700   2   1  97   0   0
   0  0     0    0     0  1000    500    600   0   0  99   0   0
   0  0     0    0     0   225    900   1000   0   0  99   0   0
EOF

format_vmstat $TMPDIR/in > $TMPDIR/got
no_diff $TMPDIR/got $TMPDIR/expected