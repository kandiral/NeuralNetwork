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

file_path = data_path + 'ytrue.dat'
y_true = load_float64_array_from_binary_file( file_path )
y_true = tf.convert_to_tensor(y_true, dtype=np.float64);

file_path = data_path + 'ypred.dat'
y_pred = load_float64_array_from_binary_file( file_path )
y_pred = tf.convert_to_tensor(y_pred, dtype=np.float64);

if cfg["lf"] == 'MSE':
    print( '---- MSE' )
    loss_fn = tf.keras.losses.MeanSquaredError()

elif cfg["lf"] == 'MAE':
    print( '---- MAE' )
    loss_fn = tf.keras.losses.MeanAbsoluteError()
    
elif cfg["lf"] == 'MAPE':
    print( '---- MAPE' )
    loss_fn = tf.keras.losses.MeanAbsolutePercentageError()

elif cfg["lf"] == 'MSLE':
    print( '---- MSLE' )
    loss_fn = tf.keras.losses.MeanSquaredLogarithmicError()

elif cfg["lf"] == 'CosineSimilarity':
    print( '---- CosineSimilarity' )
    loss_fn = tf.keras.losses.CosineSimilarity()
    
loss_value = loss_fn(y_true, y_pred)
print('Loss=',loss_value.numpy())
file_path = data_path + 'loss.dat'
save_float64_value_to_binary_file( loss_value, file_path )

# --- Расчёт начальных градиентов ---
with tf.GradientTape() as tape:
    tape.watch(y_pred)  # следим за y_pred
    loss = loss_fn(y_true, y_pred)

grads = tape.gradient(loss, y_pred)
print('grads:',grads.numpy())    
file_path = data_path + 'grads.dat'
save_float64_array_to_binary_file( grads, file_path )
    