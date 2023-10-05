import math

plot_size = {
	'C1': 91750400, # 87.5
	'C2': 90177536, # 86.0
	'C3': 88604672, # 84.5
	'C4': 86926951, # 82.9
	'C5': 85161440, # 81.3
	'C6': 83486720, # 79.6
	'C7': 81794364, # 78.0
}

bigger_plots = 'C5'
smaller_plots = 'C7'
smaller, bigger = plot_size[smaller_plots], plot_size[bigger_plots]
merge=3350000 # can be set to a more suitable size

disk_sizes = { 
	'4tb':   3907018584,
	'6tb':   5859376921, # 5,45697
	'8tb':   7814026584,
	'10tb':  9766436864,
	'12tb': 11718523904,
	'14tb': 13671961600,
	'16tb': 15625879552,
	'18tb': 17578130764, # 16,37091
	'20tb': 19531256404, # 18,1899
	'20tb': 21484382045, # 20,00889
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
# Used space < total space == 3903957936 < 3907018584  Free space ± 3060648
# For 4tb: C5 - 42, C7 - 4
# =============== End cycle ===============
# ----- Disk size: 8tb == 7814026584 -----
# Used space < total space == 7811282948 < 7814026584  Free space ± 2743636
# For 8tb: C5 - 85, C7 - 7
# =============== End cycle ===============
# ----- Disk size: 10tb == 9766436864 -----
# Used space < total space == 9763261916 < 9766436864  Free space ± 3174948
# For 10tb: C5 - 106, C7 - 9
# =============== End cycle ===============
# ----- Disk size: 12tb == 11718523904 -----
# Used space < total space == 11715240884 < 11718523904  Free space ± 3283020
# For 12tb: C5 - 127, C7 - 11
# =============== End cycle ===============
# ----- Disk size: 14tb == 13671961600 -----
# Used space < total space == 13670586928 < 13671961600  Free space ± 1374672
# For 14tb: C5 - 149, C7 - 12
# =============== End cycle ===============
# ----- Disk size: 16tb == 15625879552 -----
# Used space < total space == 15622565896 < 15625879552  Free space ± 3313656
# For 16tb: C5 - 170, C7 - 14
# =============== End cycle ===============
