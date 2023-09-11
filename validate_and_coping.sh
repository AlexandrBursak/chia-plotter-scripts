#!/bin/bash

# Temporary fast disk
source_dir="/mnt/Fast-disk/chia-plotter/plotting"

# Log files
logs_file=""
path_logs="validation_logs"

# Folders, where should be stored the plots
path_array=("/mnt/InPl12Tb/12TbPlots" "/mnt/InPl14Tb-2/14TbPlots")

plot_size=85195312 # for compress type 5

count_validation=100 
min_allowed_proofs=90

# Check for free space for plots
get_free_space() {
  if [ $# -eq 0 ]; then
    echo "Error: Please set argument with pass to folder"
    return 1
  fi
  mount_point="$1"
  # Get information about dick from command df
  disk_info=$(df "$mount_point")
  # Get information about free space
  free_space=$(echo "$disk_info" | awk 'NR==2 {print $4}')
  # Information about free space
  echo "Free space in the ($mount_point): $free_space"
}

# Start unlimit loop
count=0
action_on_plot=false
while true; do
    # Search the files ".plot" in the temporary fast disk
    for file in "$source_dir"/*.plot; do

        if [ -e "$file" ]; then
            count=$((count + 1))

            start_time=$(date +%s)

            # Get the basename of file
            file_name=$(basename "$file")
            # echo "Перевіряємо файл для переміщення $count: $file_name"
            echo "Start checking file $count: $file_name"

            # Create a log file
            logs_file="$path_logs/$file_name.log"
            touch "$logs_file"
            echo "Create log file $logs_file"

            # Start the chia plot validation and store result to log file
            chia plots check -n $count_validation -g $file  > "$logs_file" 2>&1 &

            # Analyze the log file for Proofs value
            while read -r line
            do
              if [[ $line =~ "Proofs" ]]; then
                first_digit_with_profs=$(echo "$line" | grep -oPm1 'Proofs (\d+)')
                echo "$first_digit_with_profs for current file"
                first_digit=$(echo "$first_digit_with_profs" | grep -oP '(\d+)')
                break
              fi
            done < <(tail -f "$logs_file")

            # if Proofs is less than required then the plot file doesn't copy to the final destination
            if [ $first_digit -lt $min_allowed_proofs ]; then
                action_on_plot=false
            else
                # Get the free space destination place
                for current_path in ${path_array[@]}; do
                    get_free_space "$current_path"
                    if [[ $free_space -gt $plot_size ]]; then
                        echo "$free_space > $plot_size"
                        break
                    fi
                done
                echo "Move $source_dir/$file_name to $current_path/$file_name"
                action_on_plot=true

                # Copy the file to the destination dir
                pv "$source_dir/$file_name" > "$current_path/$file_name"
            fi

            # Remove the file from the temporary fast disk
            rm $file

            if [[ "$action_on_plot" == true ]]; then
              echo "Moved file $count: $file into $current_path."
            else
              echo "Removed file $count: $file, because $first_digit < $min_allowed_proofs."
            fi

            end_time=$(date +%s)
            elapsed_time=$((end_time - start_time))

            echo "============= $first_digit_with_profs; FINISHED in $elapsed_time s.==============="
        fi

    done
    sleep 1  # Sleep before start now loop
done