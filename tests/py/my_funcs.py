import os 
import sys
import array
import numbers
import numpy as np
import tensorflow as tf

def load_float32_array_from_binary_file(file_path):
    with open(file_path, 'rb') as file:
        file_data = file.read()
    float_array = array.array('f')
    float_array.frombytes(file_data)
    return np.array( float_array, dtype=np.float32 )

def load_float64_array_from_binary_file(file_path):
    with open(file_path, 'rb') as file:
        file_data = file.read()
    float_array = array.array('d')
    float_array.frombytes(file_data)
    return np.array( float_array, dtype=np.float64 )

def save_float32_array_to_binary_file(array_data, file_path):
    float_array = array.array('f', array_data)
    with open(file_path, 'wb') as file:
        float_array.tofile(file)

def save_float64_array_to_binary_file(array_data, file_path):

    flat_array = []
    for g in array_data:
        flat_array.extend(g.numpy().astype('float64').flatten())
        
    float_array = array.array('d', flat_array)
    with open(file_path, 'wb') as file:
        float_array.tofile(file)
        
def save_float64_value_to_binary_file(value, file_path):
    # Если это Tensor — преобразуем в Python float
    if isinstance(value, tf.Tensor):
        value = value.numpy()
        
    # Проверка, что значение — число
    if not isinstance(value, numbers.Real):
        raise TypeError(f"Ожидалось число, получено: {type(value).__name__}")

    # Приводим к float64
    try:
        float_value = float(value)
    except (ValueError, TypeError):
        raise ValueError(f"Невозможно привести {value!r} к float64")

    # Создаем массив с форматом 'd' (float64)
    float_array = array.array('d', [float_value])

    # Сохраняем в файл
    with open(file_path, 'wb') as file:
        float_array.tofile(file)
        
def create_sequences(data, seq_length):
    X, y = [], []
    for i in range(len(data) - seq_length):
        X.append(data[i:i+seq_length])
        y.append(data[i+seq_length])
    return np.array(X), np.array(y)
