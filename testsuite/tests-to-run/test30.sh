#!/bin/bash


cat <<'EOF' | parallel -j0 -k
echo '### Test of --eta'
seq 1 10 | stdout parallel --eta "sleep 1; echo {}" | wc -l

echo '### Test of --eta with no jobs'
stdout parallel --eta "sleep 1; echo {}" < /dev/null

echo '### Test of --progress'
seq 1 10 | stdout parallel --progress "sleep 1; echo {}" | wc -l

echo '### Test of --progress with no jobs'
stdout parallel --progress "sleep 1; echo {}" < /dev/null

echo '### bug #34422: parallel -X --eta crashes with div by zero'
seq 2 | stdout parallel -X --eta echo

echo '### --timeout on remote machines'
parallel -j0 --timeout 3 --onall -S .. 'sleep {}; echo {}' ::: 1 6 7 ; echo $?

echo '### --pipe without command'
seq -w 10 | stdout parallel --pipe
EOF
