import math

plot_size = {
	'C5': 85195312, # round to bigger size
	'C6': 83486720, # round to bigger size
	'C7': 81816406, # round to bigger size
}

bigger_plots = 'C5'
smaller_plots = 'C7'
smaller, bigger = plot_size[smaller_plots], plot_size[bigger_plots]
#merge=bigger-smaller
merge=3000000

disk_sizes = {
	'4tb':   3907018584,
	'8tb':   7814026584,
	'10tb':  9766436864,
	'12tb': 11718523904,
	'14tb': 13671961600,
	'16tb': 15625879552,
}


def get_total_space_use(disk_size, count_of_bigger, count_of_less):
	total_space_use = count_of_bigger * bigger + count_of_less * smaller

	if disk_size-total_space_use > smaller:
		count_of_less = count_of_less + 1
		total_space_use, count_of_bigger, count_of_less = get_total_space_use(disk_size, count_of_bigger, count_of_less)

	return total_space_use, count_of_bigger, count_of_less

for size in disk_sizes:
	disk_size=disk_sizes[size]
	print('----- Disk size:', size, '==', disk_size, '-----')

	count_of_bigger = math.floor(disk_size/bigger)
	total_use = count_of_bigger * bigger
	free = disk_size - total_use
	count_of_less = 0

	while merge < free:
		count_of_bigger = count_of_bigger - 1
		count_of_less = count_of_less + 1

		total_use, count_of_bigger, count_of_less = get_total_space_use(disk_size, count_of_bigger, count_of_less)
		free = disk_size - total_use

	validate_size = count_of_bigger * bigger + count_of_less * smaller

	if validate_size > disk_size:
		print('Something wrong', validate_size, '>', disk_size)
	else:
		print('Used space < total space ==', validate_size, '<', disk_size, ' Free space ±', free)
		print('For {size}: {bigger_plots} - {count_of_bigger}, {smaller_plots} - {count_of_less}'.format(
			size=size,
			bigger_plots=bigger_plots,
			count_of_bigger=count_of_bigger,
			smaller_plots=smaller_plots,
			count_of_less=count_of_less,
		))
	print('=============== End cycle ===============')

# ----- Disk size: 4tb == 3907018584 -----
# Used space < total space == 3905468728 < 3907018584  Free space ± 1549856
# For 4tb: C5 - 42, C7 - 4
# =============== End cycle ===============
# ----- Disk size: 8tb == 7814026584 -----
# Used space < total space == 7810937456 < 7814026584  Free space ± 3089128
# For 8tb: C5 - 84, C7 - 8
# =============== End cycle ===============
# ----- Disk size: 10tb == 9766436864 -----
# Used space < total space == 9763671820 < 9766436864  Free space ± 2765044
# For 10tb: C5 - 105, C7 - 10
# =============== End cycle ===============
# ----- Disk size: 12tb == 11718523904 -----
# Used space < total space == 11716406184 < 11718523904  Free space ± 2117720
# For 12tb: C5 - 126, C7 - 12
# =============== End cycle ===============
# ----- Disk size: 14tb == 13671961600 -----
# Used space < total space == 13669140548 < 13671961600  Free space ± 2821052
# For 14tb: C5 - 147, C7 - 14
# =============== End cycle ===============
# ----- Disk size: 16tb == 15625879552 -----
# Used space < total space == 15625253818 < 15625879552  Free space ± 625734
# For 16tb: C5 - 169, C7 - 15
# =============== End cycle ===============
