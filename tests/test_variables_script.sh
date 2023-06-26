#!/bin/bash  
# this code will check if there is a variable without a default value in a given module, that is not define in the test for that module.
# if the code find variables that is missing it will echo them back and the user will need to add them to the test for the module.

cp $1 ./module_test_tmp.tf
file="./module_test_tmp.tf"
echo '' >> ./module_test_tmp.tf
declare -i default_counter=0
variable_name=""
declare -i brackets_counter=0
missing_variables=""

while read line; do  
    #Reading each line 
    if [[ "$line" == *"variable"* ]] ; then
            variable_name=$(echo "$line" | awk -F'"' '{print $2}')   
    fi
    if [[ "$line" == *"{"* ]] ; then
            let brackets_counter++
    fi
    if [[ "$line" == *"}"* ]] ; then
            let brackets_counter--
            if [[ $brackets_counter -eq 0 ]] && [[ $default_counter -eq 0 ]] ; then
                if ! cat $2 | grep -q "$variable_name"; then
                   missing_variables+="$variable_name, "
                fi
            fi
            if [[ $brackets_counter -eq 0 ]] && [[ $default_counter -eq 1 ]] ; then
               let default_counter=0
            fi
    fi
    if [[ "$line" == *"default"* ]]; then
        default_counter=1  
    fi

done < $file

echo $missing_variables
rm ./module_test_tmp.tf
