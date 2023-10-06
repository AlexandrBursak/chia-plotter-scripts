#/bin/bash

farm_key=$CHIA_FARM_KEY
pool_contract_address=$CHIA_POOL_CONTRCT_ADDRESS

fast_disk_dir="/mnt/Fast-disk/chia-plotter/plotting/"

path_to_bladebit_cuda="/home/burik/plotter/bladebit_cuda/bladebit_cuda"
path_to_bladebit="/home/burik/plotter/bladebit_cuda/bladebit_cuda"

# set all core/threads of processor
number_threads=$(nproc --all)

# Folders, where should be stored the plots
# path_array=("/mnt/InPl14Tb-2/Plots" "/mnt/InPl12Tb/Plots")
path_array=( $fast_disk_dir )


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

plot_size=85195312 # for compress type 5
# plot_size = {
#     'C1': 91750400, # 87.5
#     'C2': 90177536, # 86.0
#     'C3': 88604672, # 84.5
#     'C4': 86926951, # 82.9
#     'C5': 85161440, # 81.3
#     'C6': 83486720, # 79.6
#     'C7': 81794364, # 78.0
# }

type_plotting="cudaplot"
number_plots=200 # number plats that we want to plot
compress=5 # compress level
counter=1 
stop_plotting=false # for breaking the loop if free space is not enough
while [ $counter -le $number_plots ]
do
    start_time=$(date +%s)

    echo "---------- Cycle #$counter --- Date start: $(date -d @$start_time) -----------"

    # Check where is anough free space
    for current_path in ${path_array[@]}; do
        # get free space
        get_free_space "$current_path" 
        if [[ $free_space -gt $plot_size ]]; then
            echo "$free_space > $plot_size"
            stop_plotting=false
            break
        fi
        stop_plotting=true
    done

    if [[ "$stop_plotting" == true ]]; then
        echo "Not enough space for plotting"
        break
    fi

# run the blidebit script
if [[ "$type_plotting" == 'cudaplot' ]]; then
$path_to_bladebit_cuda \
    -t $number_threads \
    -f $farm_key \
    -c $pool_contract_address \
    -z $compress \
    -n 1 \
    $type_plotting \
    $fast_disk_dir \
    /
elif [[ "$type_plotting" == 'ramplot' ]]; then
$path_to_bladebit \
    -t $number_threads \
    -f $farm_key \
    -c $pool_contract_address \
    --compress $compress \
    -n 1 \
    $type_plotting \
    --check 100 --check-threshold 0.9 \
    $fast_disk_dir \
    /
else
$path_to_bladebit \
    -t $number_threads \
    -f $farm_key \
    -c $pool_contract_address \
    --compress $compress \
    -n 1 \
    -t1 <temp_directory> \
    $type_plotting \
    --check 100 --check-threshold 0.9 \
    $fast_disk_dir \
    /
fi

    ((counter++))
    end_time=$(date +%s)
    elapsed_time=$((end_time - start_time))

    echo "Build one more Plot in $elapsed_time sec."
    echo "Paused to 10s"
    sleep 10
done
echo All done


# ./helloerror
# + file: no message; console: message 1,2,3;

# ./helloerror >error.txt
# + file: message 1,2; console: message 3;

# ./helloerror 2>&1 >error.txt
# + file: message 1,2; console: message 3;
# + same as ./helloerror >error.txt

# ./helloerror >error.txt 2>&1
# + file: message 3,1,2; console: no message;
# + note the order 3 is first, then 1, then 2

# ./helloerror | tee error.txt 2>&1
# + file: message 1,2; console: message 3,1,2;
# + note the order 3 is first, then 1, then 2

# ./helloerror 2>&1 | tee error.txt
# + file: message 3,1,2; console: message 3,1,2;
