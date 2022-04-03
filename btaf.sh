#!/bin/bash
testdir_path='btaf-tests'

#variables
declare -i passed_count=0
declare -i tests_count=0

#opts
verbose='false' #full output from diff
h_flag='false' #displaying help
c_flag='false' #command mode
n_flag='false' #creating new test
d_flag='true' #default mode
default_program='main' #default mode, testing main program

while getopts ':nhcvdf:' flag; do
  case "${flag}" in
    h) h_flag='true';;
    c) c_flag='true';;
    v) verbose='true';;
    n) n_flag='true';;
    f) default_program="${OPTARG}" ;;
    d) d_flag='true';;
    \?) tput setaf 1; echo -e "Illegal option $*"; tput sgr0;
        echo -e "---- Displaying help message ----"
        h_flag='true'
        exit 1 ;;
  esac
done

#program modes
default_mode (){
    for test in "$testdir_path"/in/*.in; do
        tests_count+=1
        testname="$(basename "${test}")"
        if [ "$1" == "true" ] && \
             tput setaf 1; diff -w <(./"$2" <"$test" ) "$testdir_path/out/${testname:0:(-3)}.out"  || \
             diff -w <(./"$2" <"$test" ) "$testdir_path/out/${testname:0:(-3)}.out" > /dev/null
         then
            tput setaf 2; echo -e "${testname} TEST PASSED "
            passed_count+=1
        else
            tput setaf 1; echo -e "${testname} TEST FAILED "
        fi
    done
    display_test_results $passed_count $tests_count
}

cmd_mode (){
    for cmd in "$testdir_path"/cmd/*.sh; do
        tests_count+=1
        chmod +x "$cmd"
        testname="$(basename "${cmd}")"
        if [ "$1" == "true" ] && \
            tput setaf 1; diff -w <(eval "${cmd}") "$testdir_path/out/${testname:0:(-3)}.out"  || \
            diff -w <(eval "${cmd}") "$testdir_path/out/${testname:0:(-3)}.out" > /dev/null
        then
            tput setaf 2; echo -e "${testname} TEST PASSED "
            passed_count+=1
        else
            tput setaf 1; echo -e "${testname} TEST FAILED "
        fi
    done
    display_test_results $passed_count $tests_count
}

display_test_results() {
    tput setaf 6; echo -e "-----------------------------------------------------"; tput sgr0;
    if [ $1 -ne $2 ]; then
            tput setaf 1; echo -e "*** ONLY $1/$2 TESTS HAVE PASSED ***"
        else
            tput setaf 2; echo -e "*** GREAT! $1/$2 TESTS HAVE PASSED ***"
    fi
}

help_mode (){
    echo "Usage as follows: " #TODO: add usage
}

create_test_mode (){
    echo "Verbose: $1 , c_flag: $2" #TODO: add usage
}

#program main
case 'true' in
    "$n_flag") create_test_mode "$verbose" "$c_flag"
        exit 0;;
    "$h_flag") help_mode
        exit 0;;
    "$c_flag") cmd_mode "$verbose"
        exit 0;;
    "$_flag") default_mode "$verbose" "$default_program"
        exit 0;;
        *) default_mode "$verbose" "$default_program"
        exit 0;;
esac