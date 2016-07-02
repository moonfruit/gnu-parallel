#!/bin/bash

# This file must be sourced in bash:
#
#   source `which env_parallel.bash`
#
# after which 'env_parallel' works
#
#
# Copyright (C) 2016
# Ole Tange and Free Software Foundation, Inc.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, see <http://www.gnu.org/licenses/>
# or write to the Free Software Foundation, Inc., 51 Franklin St,
# Fifth Floor, Boston, MA 02110-1301 USA

# Supports env of 127426 bytes

env_parallel() {
    # env_parallel.bash

    # Get the --env variables if set
    # and convert  a b c  to (a|b|c)
    # If --env not set: Match everything (.*)
    local grep_REGEXP="$(
        perl -e 'for(@ARGV){
                $next_is_env and push @envvar, split/,/, $_;
                $next_is_env=/^--env$/;
            }
            $vars = join "|",map { quotemeta $_ } @envvar;
            print $vars ? "($vars)" : "(.*)";
            ' -- "$@"
    )"

    # Grep alias names
    local _alias_NAMES="$(compgen -a |
        egrep "^${grep_REGEXP}\$")"
    local _list_alias_BODIES="alias $_alias_NAMES"
    if [[ "$_alias_NAMES" = "" ]] ; then
	# no aliases selected
	_list_alias_BODIES="true"
    fi

    # Grep function names
    local _function_NAMES="$(compgen -A function |
        egrep "^${grep_REGEXP}\$")"
    local _list_function_BODIES="typeset -f $_function_NAMES"
    if [[ "$_function_NAMES" = "" ]] ; then
	# no functions selected
	_list_function_BODIES="true"
    fi

    # Grep variable names
    local _variable_NAMES="$(compgen -A variable |
        egrep "^${grep_REGEXP}\$" |
        grep -vFf <(readonly) |
        egrep -v '^(BASHOPTS|BASHPID|EUID|GROUPS|FUNCNAME|DIRSTACK|_|PIPESTATUS|PPID|SHELLOPTS|UID|USERNAME|BASH_[A-Z_]+)$')"
    local _list_variable_VALUES="typeset -p $_variable_NAMES"
    if [[ "$_variable_NAMES" = "" ]] ; then
	# no variables selected
	_list_variable_VALUES="true"
    fi

    # Copy shopt (so e.g. extended globbing works)
    # But force expand_aliases as aliases otherwise do not work
    export PARALLEL_ENV="$(
        shopt 2>/dev/null |
        perl -pe 's:\s+off:;: and s/^/shopt -u /;
                  s:\s+on:;: and s/^/shopt -s /;';
        echo 'shopt -s expand_aliases 2>/dev/null';
        $_list_alias_BODIES;
        $_list_variable_VALUES;
        $_list_function_BODIES)";
    `which parallel` "$@";
    unset PARALLEL_ENV;
}

# Supports env of 127375 bytes
#
# _env_parallel() {
#   # Saving to a tempfile
#   export PARALLEL_ENV=`tempfile`;
#   (echo "shopt -s expand_aliases 2>/dev/null"; alias;typeset -p |
#     grep -vFf <(readonly) |
#     grep -v 'declare .. (GROUPS|FUNCNAME|DIRSTACK|_|PIPESTATUS|USERNAME|BASH_[A-Z_]+) ';
#     typeset -f) > $PARALLEL_ENV
#   `which parallel` "$@";
#   rm "$PARALLEL_ENV"
#   unset PARALLEL_ENV;
# }
