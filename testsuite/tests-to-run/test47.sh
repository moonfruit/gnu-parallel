#!/bin/bash

SERVER1=parallel-server3
SERVER2=parallel-server2

# Minimal version of test17

# Make sure sort order is the same
export LANG=C

echo '### Test --transfer --return --cleanup'

rm -rf /tmp/parallel.file*
stdout ssh $SERVER1 rm -rf 'tmp/parallel.file*'  '/tmp/parallel.file*'
stdout ssh parallel@$SERVER2 rm -rf 'tmp/parallel.file*' '/tmp/parallel.file*'
(seq 1 2) >/tmp/test17
echo '# Create some weirdly files in /tmp'
mkdir -p /tmp/parallel.file
cat /tmp/test17 | parallel -k /bin/echo file{} '>'/tmp/parallel.file{}.file
cat /tmp/test17 | parallel -k /bin/echo /tmp/parallel.file{}.file >/tmp/test17abs
cat /tmp/test17 | parallel -k /bin/echo tmp/parallel.file{}.file >/tmp/test17rel

echo '### --transfer - abspath'
stdout ssh $SERVER1 'rm -rf /tmp/parallel.file*'
stdout ssh parallel@$SERVER2 'rm -rf /tmp/parallel.file*'
cat /tmp/test17abs | parallel -k --transfer --sshlogin $SERVER1,parallel@$SERVER2 cat {}";"rm {}
# One of these should give the empty dir /tmp/parallel.file
echo good if no file
stdout ssh $SERVER1 ls '/tmp/parallel.file*'
# The other: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*'

echo '### --transfer - relpath'
stdout ssh $SERVER1 'rm -rf tmp/parallel.file*' 
stdout ssh parallel@$SERVER2 'rm -rf tmp/parallel.file*'
cd /
cat /tmp/test17rel | parallel -k --transfer --sshlogin $SERVER1,parallel@$SERVER2 cat {}";"rm {}
# Should give: No such file or directory
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' 
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*'

echo '### --transfer --cleanup - abspath'
cat /tmp/test17abs | parallel -k --transfer --cleanup --sshlogin $SERVER1,parallel@$SERVER2 cat {}
echo good if no file
# Should give: No such file or directory
stdout ssh $SERVER1 ls '/tmp/parallel.file*'
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*'

echo '### --transfer --cleanup - relpath'
cat /tmp/test17rel | parallel -k --transfer --cleanup --sshlogin $SERVER1,parallel@$SERVER2 cat {}
# Should give: No such file or directory
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --return - abspath'
rm -rf /tmp/parallel.file*out
cat /tmp/test17abs | parallel -k --return {.}.out --sshlogin $SERVER1,parallel@$SERVER2 echo {} ">"{.}.out
ls /tmp/parallel.file*out

echo '### --return - relpath'
rm -rf /tmp/parallel.file*out
cat /tmp/test17rel | parallel -k --return {.}.out --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out
ls tmp/parallel.file*out

echo '### --return - multiple files'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
ls tmp/parallel.file*out tmp/parallel.file*done

echo '### --return --cleanup - abspath'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*' || echo OK

echo '### --return --cleanup - relpath'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
ls tmp/parallel.file*out tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --return --cleanup - multiple returns'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp/parallel.file ';'echo {} ">"{.}.out';'echo {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --transfer --return --cleanup - abspath'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*' || echo OK


echo '### --transfer --return --cleanup - relpath'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --transfer --return --cleanup - multiple files'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --transfer --return {.}.out --return {}.done --cleanup \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --trc - abspath'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*' || echo OK

echo '### --trc - relpath'
rm -rf tmp/parallel.file*out tmp/parallel.file*done
cat /tmp/test17rel | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls tmp/parallel.file*out tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls 'tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls 'tmp/parallel.file*' || echo OK

echo '### --trc - multiple files'
rm -rf /tmp/parallel.file*out /tmp/parallel.file*done
cat /tmp/test17abs | parallel -k --trc {.}.out --trc {}.done \
  --sshlogin $SERVER1,parallel@$SERVER2 mkdir -p tmp ';'cat {} ">"{.}.out';'cat {} ">"{}.done';'
ls /tmp/parallel.file*out /tmp/parallel.file*done
echo good if no file
stdout ssh $SERVER1 ls '/tmp/parallel.file*' || echo OK
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*' || echo OK

echo '### --transfer --cleanup - multiple argument files'
parallel -kv --transfer --cleanup -Sparallel@$SERVER2 cat {2} {1} :::: /tmp/test17rel <(sort -r /tmp/test17abs)
# Should give: No such file or directory
stdout ssh parallel@$SERVER2 ls '/tmp/parallel.file*' || echo OK
