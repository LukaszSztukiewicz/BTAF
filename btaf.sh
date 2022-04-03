#!/bin/bash
dir_path='btaf-dir'

#variables
declare -i passed_count=0
declare -i tests_count=0

#opts
default_program='main' #default mode, testing main program
t_flag='false'; test_to_run='None' #run particular test
verbose='false' #full output from diff
h_flag='false' #displaying help
c_flag='false' #command mode
n_flag='false' #creating new test
l_flag='false' #listing tests
i_flag='false' #interactive mode
e_flag='false' #edit mode
u_flag='false' #uninstall btaf
d_flag='true' #default mode

while getopts ':hcvndliet:f:' flag; do
  case "${flag}" in
    h) h_flag='true';;
    c) c_flag='true';;
    v) verbose='true';;
    n) n_flag='true';;
    d) d_flag='true';;
    l) l_flag='true';;
    i) i_flag='true';;
    e) e_flag='true';;
    t) t_flag='true'; test_to_run="${OPTARG}";;
    f) default_program="${OPTARG}" ;;
    \?) tput setaf 1; echo -e "Illegal option $*"; tput sgr0;
        echo -e "---- Displaying help message ----"
        h_flag='true'
        exit 1 ;;
  esac
done

#program modes
default_mode (){
    for test in "$dir_path"/in/*.in; do
        tests_count+=1
        testname="$(basename "${test}")"
        if [ "$1" == "true" ] && \
             tput setaf 1; diff -w <(./"$2" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out"  || \
             diff -w <(./"$2" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out" > /dev/null
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
    for cmd in "$dir_path"/cmd/*.sh; do
        tests_count+=1
        chmod +x "$cmd"
        testname="$(basename "${cmd}")"
        if [ "$1" == "true" ] && \
            tput setaf 1; diff -w <(eval "${cmd}") "$dir_path/out/${testname:0:(-3)}.out"  || \
            diff -w <(eval "${cmd}") "$dir_path/out/${testname:0:(-3)}.out" > /dev/null
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
    man $dir_path/manpage.txt
}

create_test_mode (){
    #test name
    timestamp=$(date +%s)
    read -rp "Enter test name (default is [$timestamp]): " name
    newtest_name=${name:-${timestamp}}

    if [ "$c_flag" == "true" ] && [ ! -f /$dir_path/cmd/"$newtest_name" ]; then
        touch newtest_name
    echo "File not found!"
        echo "Test name: " "$newtest_name"
        
    fi

    #input to program
    timestamp=$(date +%s)
    read -rp "Enter test name (default is [$timestamp]): " name
    newtest_name=${name:-${timestamp}}

    #command
    timestamp=$(date +%s)
    read -rp "Enter test name (default is [$timestamp]): " name
    newtest_name=${name:-${timestamp}}

    #expected output
    timestamp=$(date +%s)
    read -rp "Enter test name (default is [$timestamp]): " name
    newtest_name=${name:-${timestamp}}
}

#program main
case 'true' in
    "$n_flag") create_test_mode
        exit 0;;
    "$h_flag") help_mode
        exit 0;;
    "$c_flag") cmd_mode "$verbose"
        exit 0;;
    "$d_flag") default_mode "$verbose" "$default_program"
        exit 0;;
        *) default_mode "$verbose" "$default_program"
        exit 0;;
esac