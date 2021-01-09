import numpy as npy
import tensorflow as tf


fc1_w = npy.load('dense_kernel_0.npy')

image_tensor = tf.io.read_file('img.png')
image_tensor = tf.io.decode_image(image_tensor)
image = tf.image.resize(image_tensor, [32, 32]).numpy()
image = image[:, :, 0]
image = image / 255.0
image = (image > 0.5) * 1.0

for r in range(32):
    for c in range(32):
        print(int(image[r][c]), end='')
    print()

image = npy.reshape(image, [1, 1024])

fc1_b = npy.load('dense_bias_0.npy')

fc1 = npy.matmul(image, fc1_w)
fc1 += fc1_b

fc1 = tf.keras.activations.relu(fc1).numpy()
fc2_w = npy.load('dense_1_kernel_0.npy')

fc2_b = npy.load('dense_1_bias_0.npy')

fc2 = npy.matmul(fc1, fc2_w)
fc2 += fc2_b

fc2 = tf.keras.activations.relu(fc2).numpy()

fc3_w = npy.load('dense_2_kernel_0.npy')
fc3_b = npy.load('dense_2_bias_0.npy')

fc3 = npy.matmul(fc2, fc3_w)
fc3 += fc3_b

print(fc3)

