#!/bin/bash

. `which env_parallel.bash`
env_parallel --session

true <<'EOF'
#!/bin/bash

# Find the command line limit formula
# macosx.p = 10.7.5
# El capitan = 10.11.4

. `which binsearch`
doit() {
    nfunc=$1
    lfunc=$2
    lfuncname=$3
    nvar=$4
    lvar=$5
    lvarname=$6
    varval="$(perl -e 'print "x "x('$lvar'/2)')"
    varname=$(perl -e 'print "x"x'$lvarname)
    funcval="$(perl -e 'print "x "x('$lfunc'/2)')"
    funcname=$(perl -e 'print "x"x'$lfuncname)
    for a in `seq $nvar`; do eval "export v$varname$a='$varval'" ; done
    for a in `seq $nfunc`; do eval "f$funcname$a() { $funcval; }" ; done
    for a in `seq $nfunc`; do eval "export -f f$funcname$a" ; done
    myrun() {
	/bin/echo $(perl -e 'print " x"x('$1'/2-5)')
    }
    export -f myrun
    binlen=dummy
    binlen=$(binsearch -q myrun)
    perl -e '
    $envc=(keys %ENV);
    $envn=length join"",(keys %ENV);
    $envv=length join"",(values %ENV);
    $maxlen=3+(262144 - $envn - $envv) / 5 - $envc*2;
    print("Max len = $maxlen\n");
    $bin='$binlen';
    print("$bin=",$bin-$maxlen," $envc $envn $envv\n");
       '
}
export -f doit

val="$(seq 2 100 1000)"
val="10 20 50 100 200 500 1000"
val="11 23 57 101 207 503 1007"
parallel --shuf --tag -k doit ::: $val ::: $val ::: $val ::: $val ::: $val ::: $val
EOF

# Each should generate at least 2 commands

par_many_args() {
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    geny() { yes | head -c $1; }
    for a in `seq 6000`; do eval "export a$a=1" ; done
    geny 10000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/( y){10,}//g'
}

par_many_var() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    for a in `seq 6000`; do eval "export a$a=1" ; done
    gen 10000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_many_var_func() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    for a in `seq 2000`; do eval "export a$a=1" ; done
    for a in `seq 2000`; do eval "a$a() { 1; }" ; done
    for a in `seq 2000`; do eval export -f a$a ; done
    gen 20000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_many_func() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    for a in `seq 5000`; do eval "a$a() { 1; }" ; done
    for a in `seq 5000`; do eval export -f a$a ; done
    gen 10000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_big_func() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    big=`seq 1000`
    for a in `seq 1`; do eval "a$a() { '$big'; }" ; done
    for a in `seq 1`; do eval export -f a$a ; done
    gen 20000 | stdout parallel --load 2 -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_many_var_big_func() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    big=`seq 1000`
    for a in `seq 5000`; do eval "export a$a=1" ; done
    for a in `seq 10`; do eval "a$a() { '$big'; }" ; done
    for a in `seq 10`; do eval export -f a$a ; done
    gen 10000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_big_func_name() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    big=`perl -e print\"x\"x10000`
    for a in `seq 10`; do eval "export a$big$a=1" ; done
    gen 15000 | stdout parallel -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

par_big_var_func_name() {
    export LC_ALL=C
    rm -f ~/.parallel/tmp/sshlogin/*/linelen
    gen() { seq -f %f 1000000000000000 1000000000050000 | head -c $1; }
    pecho() { perl -e 'print "@ARGV\n"' "$@"; }
    export -f pecho
    big=`perl -e print\"x\"x10000`
    for a in `seq 10`; do eval "export a$big$a=1" ; done
    for a in `seq 10`; do eval "a$big$a() { 1; }" ; done
    for a in `seq 10`; do eval export -f a$big$a ; done
    gen 10000 | stdout parallel --load 4 -Xkj1  'pecho {} {} {} {} | wc' |
	perl -pe 's/\d{10,}.\d+ //g'
}

#macsshlogin=ota@mac
macsshlogin=macosx.p
scp /usr/local/bin/parallel $macsshlogin:bin/

export LC_ALL=C
export -f $(compgen -A function | grep par_)
compgen -A function |
    grep par_ |
    LC_ALL=C sort |
    env_parallel --timeout 1000% --tag -k -S 6/$macsshlogin 'PATH=$HOME/bin:$PATH; {}'
