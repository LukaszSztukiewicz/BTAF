#!/bin/bash
testdir_path='btaf-tests'

#string constants
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' #No Color

#variables
declare -i passed_count=0
declare -i tests_count=0

#opts
verbose='false' #full output from diff
h_flag='false' #displaying help
c_flag='false' #command mode
n_flag='false' #creating new test
tested_program='main' #default mode, testing main program

while getopts ':nhcvf:' flag; do
  case "${flag}" in
    h) h_flag='true';;
    c) c_flag='true';;
    v) verbose='true';;
    n) n_flag='true';;
    f) tested_program="${OPTARG}" ;;
    \?) echo -e "${RED} Illegal option $* ${NC}"
        echo -e "---- Displaying help message ----"
        h_flag='true'
        exit 1 ;;
  esac
done

#testing modes
default_mode (){

    pushd $testdir_path > /dev/null || return

    for test in in/*.in; do
        tests_count+=1

        if [ "$1" == "true" ]; then
            if diff -w <(../"$2" <"$test" ) "out/${test:3:(-3)}.out"
            then
                echo -e "${GREEN} ${test:3:(-3)} TEST PASSED "
                passed_count+=1
            else
                echo -e "${RED} ${test:3:(-3)} TEST FAILED "
            fi
        else
            if diff -w <(../"$2" <"$test" ) "out/${test:3:(-3)}.out" > /dev/null
            then
                echo -e "${GREEN} ${test:3:(-3)} TEST PASSED "
                passed_count+=1
            else
                echo -e "${RED} ${test:3:(-3)} TEST FAILED "
            fi
        fi
    done

    echo -e "${CYAN}-----------------------------------------------------${NC}"

    if [ $passed_count -ne $tests_count ]; then
            echo -e "${RED} ** ONLY ${passed_count}/${tests_count} TESTS HAVE PASSED **"
        else
            echo -e "${GREEN} ** GREAT! ${passed_count}/${tests_count} TESTS HAVE PASSED **"
    fi
}

cmd_mode (){

    for cmd in "$testdir_path"/cmd/*.sh; do
        
        tests_count+=1
        chmod +x "$cmd"
        testname="$(basename "${cmd}")"
        echo $testname

        if [ "$1" == "true" ]; then
            if diff -w <(eval "${cmd}") "out/${testname:(-3)}.out"
            then
                echo -e "${GREEN} ${testname:(-3)} TEST PASSED "
                passed_count+=1
            else
                echo -e "${RED} ${testname:(-3)} TEST FAILED "
            fi
        else
            if diff -w <(eval "${cmd}") "out/${testname:(-3)}.out" > /dev/null
            then
                echo -e "${GREEN} ${testname:(-3)} TEST PASSED "
                passed_count+=1
            else
                echo -e "${RED} ${testname:(-3)} TEST FAILED "
            fi
        fi
    done

    echo -e "${CYAN}-----------------------------------------------------${NC}"

    if [ $passed_count -ne $tests_count ]; then
            echo -e "${RED} ** ONLY ${passed_count}/${tests_count} TESTS HAVE PASSED **"
        else
            echo -e "${GREEN} ** GREAT! ${passed_count}/${tests_count} TESTS HAVE PASSED **"
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
        *) default_mode "$verbose" "$tested_program"
        exit 0;;
esac