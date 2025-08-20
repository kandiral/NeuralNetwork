import os 
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '1'

import sys
import json
import numpy as np

import tensorflow as tf
# Глобально установить float64 как дефолт (для Keras)
tf.keras.backend.set_floatx('float64')
# Установить новое значение
tf.keras.backend.set_epsilon(1e-10)  # Или любое значение, которое вы используете в Pascal

from tensorflow import keras
from tensorflow.keras import layers
from keras.models import Sequential
from keras.layers import Dense

from my_funcs import(
    load_float64_array_from_binary_file,
    save_float64_array_to_binary_file,
    save_float64_value_to_binary_file
)

print( '==== Python Test ===================================================' )
print( '---- ' + __file__ )
# print( 'sys.argv=' + str(sys.argv) )

main_path = os.path.dirname( os.path.realpath( __file__ ) ) + "\\"
# print( 'main_path=' + main_path )

data_path = os.path.dirname( os.path.dirname(main_path) ) + "\\" + 'data' + "\\" + sys.argv[ 1 ]
# print( 'data_path=' + data_path )

cfg_file = data_path + 'cfg.json'
# print( 'cfg_file=' + cfg_file )

print('epsilon=',tf.keras.backend.epsilon())

with open( cfg_file, "r", encoding = "utf-8" ) as file:
    cfg = json.load( file )

file_path = data_path + 'xdata.dat'
x_data = load_float64_array_from_binary_file( file_path )
x_data = tf.convert_to_tensor(x_data, dtype=np.float64);
# Add batch dimension to x_data
x_data = tf.expand_dims(x_data, axis=0)
print('xdata:',x_data.numpy())    

# Parse activations
activation_map = {0: 'linear', 1: 'tanh', 2: 'relu'}

prev_dim = cfg['inputsCount']

# Create the model
model = keras.Sequential()
model.add(layers.Input(shape=(prev_dim,), dtype='float64'))

for i, layer_cfg in enumerate(cfg['layers']):
    act = activation_map[layer_cfg['activation']]
    use_bias = layer_cfg['useBiases']
    units = layer_cfg['outputsCount']
    
    dense = layers.Dense(units, activation=act, use_bias=use_bias, dtype='float64')
    
    model.add(dense)
    
    # Load and print weights
    w_file = data_path + f'w{i}.dat'
    w = load_float64_array_from_binary_file(w_file)
    # Reshape to (OutputsCount, InputsCount) as per your convention, then transpose to (InputsCount, OutputsCount)
    w = np.reshape(w, (units, prev_dim)).astype(np.float64)
    w = np.transpose(w)  # Transpose to (InputsCount, OutputsCount) for Keras
    print(f'w{i}:', w)
    
    if use_bias:
        b_file = data_path + f'b{i}.dat'
        b = load_float64_array_from_binary_file(b_file)
        b = np.reshape(b, (units,)).astype(np.float64)
        print(f'b{i}:', b)
        dense.set_weights([w, b])
    else:
        dense.set_weights([w])
    
    prev_dim = units

# Perform forward pass
y_data = model(x_data)

print('ydata:',y_data.numpy())    
file_path = data_path + 'ydata.dat'
save_float64_array_to_binary_file( y_data, file_path )
