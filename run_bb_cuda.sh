#/bin/bash

farm_key=$CHIA_FARM_KEY
pool_contract_address=$CHIA_POOL_CONTRCT_ADDRESS

fast_disk_dir="/mnt/Fast-disk/chia-plotter/plotting/"

path_to_bladebit="/home/burik/plotter/bladebit_cuda/bladebit_cuda"

number_threads=28

# Folders, where should be stored the plots
path_array=("/mnt/InPl12Tb/12TbPlots" "/mnt/InPl14Tb-2/14TbPlots")

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

number_plots=100 # number plats that we want to plot
compress=5 # compress level
counter=1 
stop_plotting=false # for breaking the loop if free space is not enough
while [ $counter -le $number_plots ]
do

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

    echo $counter

# run the blidebit script
$path_to_bladebit \
    -t $number_threads \
    -f $farm_key \
    -c $pool_contract_address \
    -z $compress \
    -n 1 \
    cudaplot \
    $fast_disk_dir \
    /

    ((counter++))

    sleep 10
done
echo All done