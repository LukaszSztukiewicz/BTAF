#!/bin/bash
dir_path='btaf-dir'

#variables
declare -i passed_count=0
declare -i tests_count=0

#defaults
program_to_test='main' #default mode - testing main program

#opts
a_flag='false' #all
c_flag='false' #command mode
d_flag='false' #delete test
e_flag='false' #edit mode
h_flag='false' #displaying help
i_flag='false' #interactive mode (prompting)
l_flag='false' #listing tests
m_flag='false' #showing man page
n_flag='false' #creating new test
p_flag='false' #program to test
s_flag='false' #save test to zip
t_flag='false' #run particular test, default lastest created, accepts array of tests
u_flag='false' #uninstall btaf
v_flag='false' #verbose
V_flag='false' #print version
x_flag='false' #crosstest mode
z_flag='false' #unzip tests 


while getopts ':acd:e:hilmnp:s:t:uvVx:z:' flag; do
  case "${flag}" in
    a) a_flag='true';;
    c) c_flag='true';;
    d) d_flag='true'; test_to_delete="${OPTARG}";;
    e) e_flag='true'; test_to_edit="${OPTARG}";;
    h) h_flag='true';;
    i) i_flag='true';;
    l) l_flag='true';;
    m) m_flag='true';;
    n) n_flag='true';;
    p) p_flag='true'; program_to_test="${OPTARG}";;
    s) s_flag='true'; test_to_save="${OPTARG}";;
    t) t_flag='true'; tests_to_run="${OPTARG}";;
    u) u_flag='true';;
    v) v_flag='true';;
    V) V_flag='true';;
    x) x_flag='true'; program_to_crosstest="${OPTARG}";;
    z) z_flag='true'; file_to_unzip="${OPTARG}";;
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
        if [ "$v_flag" == "true" ] && \
             (tput setaf 1; diff -w <(./"$program_to_test" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out")  || \
             diff -w <(./"$program_to_test" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out" > /dev/null
         then
            tput setaf 2; echo -e "${testname} TEST PASSED "
            passed_count+=1
        else
            tput setaf 1; echo -e "${testname} TEST FAILED "
        fi
    done
    display_test_results $passed_count $tests_count
}
command_mode (){
    for cmd in "$dir_path"/cmd/*.sh; do
        tests_count+=1
        chmod +x "$cmd"
        testname="$(basename "${cmd}")"
        if [ "$v_flag" == "true" ] && \
            (tput setaf 1; diff -w <(eval "${cmd}") "$dir_path/out/${testname:0:(-3)}.out")  || \
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
    if [ "$1" -ne "$2" ]; then
            tput setaf 1; echo -e "*** ONLY $1/$2 TESTS HAVE PASSED ***"
        else
            tput setaf 2; echo -e "*** GREAT! $1/$2 TESTS HAVE PASSED ***"
    fi
}
delete_mode(){
    #if a flag is set to true delete all tests
    if [ "$a_flag" == "true" ]; then
        rm -rf $dir_path/cmd/*
        rm -rf $dir_path/in/*
        rm -rf $dir_path/out/*
        echo -e "All tests deleted"
    #else delete provided test
    else
        if [ -f "$dir_path/cmd/$test_to_delete.sh" ]; then
            rm "$dir_path/cmd/$test_to_delete.sh"
            echo -e "Test $test_to_delete deleted"
        elif [ -f "$dir_path/in/$test_to_delete.in" ]; then
            rm "$dir_path/in/$test_to_delete.in"
            echo -e "Test $test_to_delete deleted"
        fi
        if [ -f "$dir_path/out/$test_to_delete.out" ]; then
            rm "$dir_path/out/$test_to_delete.out"
            echo -e "Test $test_to_delete deleted"
        else
            echo -e "Test $test_to_delete not found"
        fi
    fi
}
edit_mode(){
    if [ -f "$dir_path/cmd/$test_to_edit.sh" ]; then
        vim "$dir_path/cmd/$test_to_edit.sh"
    elif [ -f "$dir_path/in/$test_to_edit.in" ]; then
        vim "$dir_path/in/$test_to_edit.in"
    fi
    if [ -f "$dir_path/out/$test_to_edit.out" ]; then
        vim "$dir_path/out/$test_to_edit.out"
    else
        echo -e "Test $test_to_edit not found"
    fi
}
list_mode(){
    echo "Default tests:"
    for test in "$dir_path"/in/*.in; do
        testname="$(basename "${test}")"
        echo -e "${testname:0:(-3)}"
    done
    echo "Command tests:"
    for cmd in "$dir_path"/cmd/*.sh; do
        testname="$(basename "${cmd}")"
        echo -e "${testname:0:(-3)}"
    done
}
save_mode(){
    if [ -f "$dir_path/cmd/$test_to_save.sh" ]; then
        zip -j "$dir_path/cmd/$test_to_save.zip" "$dir_path/cmd/$test_to_save.sh"
        echo -e "Test $test_to_save saved"
    elif [ -f "$dir_path/in/$test_to_save.in" ]; then
        zip -j "$dir_path/in/$test_to_save.zip" "$dir_path/in/$test_to_save.in"
        echo -e "Test $test_to_save saved"
    fi
    if [ -f "$dir_path/out/$test_to_save.out" ]; then
        zip -j "$dir_path/out/$test_to_save.zip" "$dir_path/out/$test_to_save.out"
        echo -e "Test $test_to_save saved"
    else
        echo -e "Test $test_to_save not found"
    fi
}
run_mode(){
    for test in "${tests_to_run[@]}"; do
        tests_count+=1
        testname="$(basename "${test}")"
        if [ "$v_flag" == "true" ] && \
            (tput setaf 1; diff -w <(./"$program_to_test" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out")  || \
            diff -w <(./"$program_to_test" <"$test" ) "$dir_path/out/${testname:0:(-3)}.out" > /dev/null
        then
            tput setaf 2; echo -e "${testname} TEST PASSED "
            passed_count+=1
        else
            tput setaf 1; echo -e "${testname} TEST FAILED "
        fi
    done
    display_test_results $passed_count $tests_count
}
#crosstest program_to_test with program_to_crosstest
crosstest_mode(){
    if [ -f "$dir_path/cmd/$program_to_test.sh" ]; then
        tests_count+=1
        if [ "$v_flag" == "true" ] && \
            (tput setaf 1; diff -w <(./"$program_to_test" <"$dir_path/in/$program_to_crosstest.in" ) "$dir_path/out/$program_to_crosstest.out")  || \
            diff -w <(./"$program_to_test" <"$dir_path/in/$program_to_crosstest.in" ) "$dir_path/out/$program_to_crosstest.out" > /dev/null
        then
            tput setaf 2; echo -e "${program_to_crosstest} TEST PASSED "
            passed_count+=1
        else
            tput setaf 1; echo -e "${program_to_crosstest} TEST FAILED "
        fi
    else
        echo -e "Program $program_to_test not found"
    fi
    display_test_results $passed_count $tests_count
}
#install required directories
create_directories (){
    mkdir -p "$dir_path/cmd"
    mkdir -p "$dir_path/in"
    mkdir -p "$dir_path/out"
    echo -e "Directories created"
}
#uninstall btaf by removing all files
uninstall_mode (){
    rm -rf "$dir_path"
    rm btaf.sh
}
unzip_mode (){
    echo -e "Unzip to implement" #TODO
}
man_mode (){
    man $dir_path/manpage.txt
}
help_mode (){
    echo "Help to implement" #TODO
}
Version_mode (){
    echo "Version to implement" #TODO
}

create_new_test_mode (){
    #test name
    timestamp=$(date +%s)
    read -rp "Enter test name (default is [$timestamp]): " name
    newtest_name="${name:-${timestamp}}"
    #if test name already exists
    if [ -f "$dir_path/cmd/$newtest_name.sh" ] || [ -f "$dir_path/in/$newtest_name.in" ] || [ -f "$dir_path/out/$newtest_name.out" ]; then
        echo "Test ${newtest_name} already exists"
        return
    fi
    if [ "$c_flag" == "true" ] && [ ! -f /$dir_path/cmd/"${newtest_name}.sh" ] && [ ! -f /$dir_path/out/"${newtest_name}.out" ] || \
        [ "$d_flag" == "true" ] && [ ! -f /$dir_path/out/"${newtest_name}.out" ] && [ ! -f /$dir_path/in/"${newtest_name}.in" ]; then
            if [ "$c_flag" == "true" ]; then
                    touch $dir_path/cmd/"${newtest_name}.sh"
                else
                    touch $dir_path/in/"${newtest_name}.in"
            fi
            touch $dir_path/out/"${newtest_name}.out"
    else
        echo "Test ${newtest_name} already exists"
    fi   

    #input to program or command
    if [ "$c_flag" == "true" ]; then
            read -rp "Enter command to test (default is [echo test ${newtest_name}]): " new_command
            newtest_command=${new_command:-"echo test ${newtest_name}"}
        else
            read -rp "Enter input to program (default is [test ${newtest_name}]): " input
            newtest_input=${input:-"test ${newtest_name}"}
    fi

    #expected output
    if [ "$c_flag" == "true" ]; then
            read -rp "Enter excpected output (default is [test ${newtest_name}]): " output
            newtest_output=${output:-"test ${newtest_name}"}
        else
            read -rp "Enter excpected output (default is [test ${newtest_name}]): " output
            newtest_output=${output:-"test ${newtest_name}"}
    fi

    #saving test
    if [ "$c_flag" == "true" ]; then
            echo "$newtest_command" > $dir_path/cmd/"${newtest_name}.sh"
        else
            echo "$newtest_input" > $dir_path/in/"${newtest_name}.in"
    fi
    echo "$newtest_output" > $dir_path/out/"${newtest_name}.out"
    echo "Test ${newtest_name} succesfully created"
}

#program main
case 'true' in
    "$n_flag") create_new_test_mode
        exit 0;;
    "$c_flag") command_mode
        exit 0;;
    "$d_flag") delete_mode
        exit 0;;
    "$e_flag") edit_mode
        exit 0;;
    "$h_flag") help_mode
        exit 0;;
    "$l_flag") list_mode
        exit 0;;
    "$m_flag") man_mode
        exit 0;;
    "$t_flag") run_mode
        exit 0;;
    "$u_flag") uninstall_mode
        exit 0;;
    "$V_flag") Version_mode
        exit 0;;
    "$x_flag") crosstest_mode
        exit 0;;
    "$z_flag") unzip_file
        exit 0;;
        *) default_mode
        exit 0;;
esac