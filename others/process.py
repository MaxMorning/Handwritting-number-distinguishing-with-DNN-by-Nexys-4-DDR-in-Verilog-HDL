import numpy as npy

def convert(num):
    if num < 0:
        # num = -num
        num *= 1024
        # num += 32768
        num = int(num - 0.5)
        num = 65535 + num
        n_str = str(hex(num))[2:]
        if len(n_str) == 1:
            n_str = 'fff' + n_str
        elif len(n_str) == 2:
            n_str = 'ff' + n_str
        elif len(n_str) == 3:
            n_str = 'f' + n_str
        return n_str
    else:
        num *= 1024
        num = int(num + 0.5)
        n_str = str(hex(num))[2:]
        if len(n_str) == 1:
            n_str = '000' + n_str
        elif len(n_str) == 2:
            n_str = '00' + n_str
        elif len(n_str) == 3:
            n_str = '0' + n_str
        return n_str


file = open('16bit.coe', 'w')
file_str = "memory_initialization_radix=16;\nmemory_initialization_vector=\n"

# fc1 params
fc1_w = npy.load('dense_kernel_0.npy')
for r in range(128):
    cnt_128 = 0
    unit_128_8 = ''
    for c in range(1024):
        unit_128_8 += convert(fc1_w[c][r])
        if cnt_128 < 127:
            cnt_128 += 1
        else:
            cnt_128 = 0
            file_str += unit_128_8 + ',\n'
            unit_128_8 = ''

fc1_b = npy.load('dense_bias_0.npy')
unit_128_8 = ''
for i in range(128):
    unit_128_8 += convert(fc1_b[i])
file_str += unit_128_8 + ',\n'

# fc2 params
fc2_w = npy.load('dense_1_kernel_0.npy')
for r in range(128):
    unit_128_8 = ''
    for c in range(128):
        unit_128_8 += convert(fc2_w[c][r])
    unit_128_8 += ',\n'
    file_str += unit_128_8

fc2_b = npy.load('dense_1_bias_0.npy')
unit_128_8 = ''
for i in range(128):
    unit_128_8 += convert(fc2_b[i])
file_str += unit_128_8 + ',\n'

# fc3 params
fc3_w = npy.load('dense_2_kernel_0.npy')
for r in range(10):
    unit_128_8 = ''
    for c in range(128):
        unit_128_8 += convert(fc3_w[c][r])
    unit_128_8 += ',\n'
    file_str += unit_128_8

fc3_b = npy.load('dense_2_bias_0.npy')
unit_128_8 = ''
for i in range(128):
    if i < 10:
        unit_128_8 += convert(fc3_b[i])
    else:
        unit_128_8 += '0000'
file_str += unit_128_8 + ';'

file.write(file_str)
