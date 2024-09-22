#!/bin/bash

# This a script that can sync a folder that contains a lot of git repos.
# Note: This script must be used standalone.
# from shreker long

function echo_sucess() {
    echo -e "GIT-SYNC:" "\033[32m$1\033[0m"
}

function echo_failure() {
    echo -e "GIT-SYNC:" "\033[41;37m$1\033[0m"
}

function echo_warning() {
    echo -e "GIT-SYNC:" "\033[43;37m$1\033[0m"
}

function echo_separator() {
    echo -e "GIT-SYNC:" "\033[44;37m$1\033[0m"
}

function echo_info() {
    echo -e "GIT-SYNC:" "\033[40;37m$1\033[0m"
}

function judgement() {
    cmd=$1
    result_code=$2
    output=$3
    
    # if [[ $result_code -ne 0 ]]; then
    #   echo_info Result Code: $2
    # fi
    if [[ ${#output} -gt 0 ]]; then
        echo_info "${output}"
    fi
    
    # if [[ $result_code -eq 0 ]]; then
    #   new_line
    #   echo_sucess "Command Of \"$cmd\" Executed Successfully."
    # else
    if [[ $result_code -ne 0 ]]; then
        if [[ $result_code -eq 1 ]]; then
            echo_failure "ERROR: Common Unkown Error."
        else
            if [[ $result_code -eq 2 ]]; then
                echo_failure "ERROR: Command mistake: $result_code"
                elif [[ $result_code -eq 126 ]]; then
                echo_failure "ERROR: Unexecutable: $result_code"
                elif [[ $result_code -eq 127 ]]; then
                echo_failure "ERROR: Not a command: $result_code"
                elif [[ $result_code -eq 128 ]]; then
                echo_failure "ERROR: Invalid exit parameter: $result_code"
                elif [[ $result_code -eq "128+x Linux" ]]; then
                echo_failure "ERROR: Signal x mistake: $result_code"
                elif [[ $result_code -eq "128+x" ]]; then
                echo_failure "ERROR: User teminated: $result_code"
                elif [[ $result_code -eq "255" ]]; then
                echo_failure "ERROR: Exit status Invalid: $result_code"
            else
                echo_failure "UNEXPECTED CODE: $result_code"
            fi
            new_line
            echo_failure "Command Of \"$cmd\" Executed Failure. Please Try After Checking It."
            read -p "Pressing Enter To Resume ... "
            exit $result_code
        fi
    fi
}

#read -p "PLEASE ENTER THE MESSAGE: " message
#while [ ! $message ]
#do
#  read -p "PLEASE ENTER THE MESSAGE: " message
#done

function print_start_line() {
    new_line
    echo_separator "☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆☆"
}

function new_line() {
    echo -e "\n"
}

cur_dir=`pwd`

echo_separator "☆☆☆ Start Backup ... for ${cur_dir} ☆☆☆"

# echo_info "Current Params: $1"

if [[ -d $1 ]]; then
    cur_dir=$1
fi

# echo_info "Current Folder: ${cur_dir}"

print_start_line
echo_info "Changing Directory to: ${cur_dir}"
cd ${cur_dir}
judgement "cd ${cur_dir}" $?

print_start_line
echo_info "Status ... for ${cur_dir}"
result=`git status`
judgement "git status" $? "$result"

need_push=0

if [[ $result =~ "use \"git push\" to publish your local commits" ]]; then
    need_push=1
fi

if [[ $result =~ "Changes not staged for commit" || $result =~ "Untracked files:" ]]; then
    print_start_line
    echo_info "Add ... for ${cur_dir}"
    result=`git add ./`
    judgement "git add ./" $? "$result"
    
    print_start_line
    echo_info "Commiting ... for ${cur_dir}"
    result=`git commit -m "-- Auto Save Files --"`
    judgement "git commit" $? "$result"
    need_push=1
else
    new_line
    echo_info "Nothing To Add and Commit, Working Tree Clean. Skipping ..."
fi

print_start_line
echo_info "Pulling ... for ${cur_dir}"
result=`git pull`
judgement "git pull" $? "$result"

if [[ $need_push -eq 1 ]]; then
    print_start_line
    echo_info "Pushing Local Changes to Remote for ${cur_dir}"
    result=`git push`
    judgement "git push" $? "$result"
else
    echo_info "Nothing to push, Skipping ..."
fi

# new_line
# read -p "PRESSING ENTER TO EXIT ... "
