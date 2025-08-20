import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '1'
import sys
import json
import numpy as np
import tensorflow as tf
tf.keras.backend.set_floatx('float64')
tf.keras.backend.set_epsilon(1e-10)
from tensorflow import keras
from tensorflow.keras import layers
from tensorflow.keras import losses
from my_funcs import(
    load_float64_array_from_binary_file,
    save_float64_array_to_binary_file,
    save_float64_value_to_binary_file
)

print('==== Python Test ===================================================')
print('---- ' + __file__)
main_path = os.path.dirname(os.path.realpath(__file__)) + "\\"
data_path = os.path.dirname(os.path.dirname(main_path)) + "\\" + 'data' + "\\" + sys.argv[1]
cfg_file = data_path + 'cfg.json'
print('epsilon=', tf.keras.backend.epsilon())

with open(cfg_file, "r", encoding="utf-8") as file:
    cfg = json.load(file)

# Load input data
file_path = data_path + 'xdata.dat'
x_data = load_float64_array_from_binary_file(file_path)
x_data = tf.convert_to_tensor(x_data, dtype=np.float64)
x_data = tf.expand_dims(x_data, axis=0) # Add batch dimension
print('xdata:', x_data.numpy())

# Load y_true
file_path = data_path + 'ytrue.dat'
y_true = load_float64_array_from_binary_file(file_path)
y_true = tf.convert_to_tensor(y_true, dtype=np.float64)
y_true = tf.expand_dims(y_true, axis=0) # Add batch dimension
print('y_true:', y_true.numpy())

# Parse activations, loss function, and optimizer
activation_map = {0: 'linear', 1: 'tanh', 2: 'relu'}
loss_map = {
    0: 'mean_squared_error', 
    1: 'mean_absolute_error', 
    2: 'mean_absolute_percentage_error', 
    3: 'mean_squared_logarithmic_error', 
    4: 'cosine_similarity'
}
loss_map_callable = {
    0: losses.MeanSquaredError(),
    1: losses.MeanAbsoluteError(),
    2: losses.MeanAbsolutePercentageError(),
    3: losses.MeanSquaredLogarithmicError(),
    4: losses.CosineSimilarity()
}
optimizer_map = {0: keras.optimizers.SGD, 1: keras.optimizers.Adam, 2: keras.optimizers.RMSprop}
loss_func = loss_map[cfg['lossFunc']]
loss_func_callable = loss_map_callable[cfg['lossFunc']]
count = cfg.get('count', 1) # Default to 1 if not specified
optimizer_type = optimizer_map[cfg['optimizer']] # Select optimizer based on cfg

# Create the model
model = keras.Sequential()
prev_dim = cfg['inputsCount']
model.add(layers.Input(shape=(prev_dim,), dtype='float64'))

for i, layer_cfg in enumerate(cfg['layers']):
    act = activation_map[layer_cfg['activation']]
    use_bias = layer_cfg['useBiases']
    units = layer_cfg['outputsCount']
    
    dense = layers.Dense(units, activation=act, use_bias=use_bias, dtype='float64')
    model.add(dense)
    
    # Load weights
    w_file = data_path + f'w{i}.dat'
    w = load_float64_array_from_binary_file(w_file)
    w = np.reshape(w, (units, prev_dim)).astype(np.float64)
    w = np.transpose(w) # Transpose to (InputsCount, OutputsCount) for Keras
    print(f'Start Weights For Layer #{i}:', w)
    
    if use_bias:
        b_file = data_path + f'b{i}.dat'
        b = load_float64_array_from_binary_file(b_file)
        b = np.reshape(b, (units,)).astype(np.float64)
        print(f'Start Biases For Layer #{i}:', b)
        dense.set_weights([w, b])
    else:
        dense.set_weights([w])
    
    prev_dim = units

# Compile model with optimizer and loss
optimizer = optimizer_type() # Initialize selected optimizer
model.compile(optimizer=optimizer, loss=loss_func)

# Perform backward passes
for pass_idx in range(count):
    print(f'Backward pass {pass_idx + 1}/{count}')
    
    # Compute gradients
    with tf.GradientTape() as tape:
        predictions = model(x_data, training=True)
        print('predictions=', predictions.numpy()[:5])  # Выводим только первые 5
        loss = loss_func_callable(y_true, predictions)
        print('loss=', loss.numpy())
    
    # Get gradients
    gradients = tape.gradient(loss, model.trainable_variables)
    print(f'Total gradients: {len(gradients)}')
    
    # Проходим по градиентам и соответствующим слоям
    grad_index = 0
    for i, layer in enumerate(model.layers):
        if not hasattr(layer, 'trainable_weights') or not layer.trainable_weights:
            continue
            
        print(f'\n--- Layer {i}: {layer.name} ---')
        
        # Веса
        if grad_index < len(gradients):
            w_grad = gradients[grad_index]
            print(f'WeightsGrads: {w_grad.numpy()}')
            
            #file_path = data_path + f'w_grad{i}_pass{pass_idx}.dat'
            #save_float64_array_to_binary_file(w_grad.numpy().T, file_path)
            
            grad_index += 1
        
        # Смещения (если есть)
        if layer.use_bias and grad_index < len(gradients):
            b_grad = gradients[grad_index]
            print(f'BiasesGrads: {b_grad.numpy()}')
            
            #file_path = data_path + f'b_grad{i}_pass{pass_idx}.dat'
            #save_float64_array_to_binary_file(b_grad.numpy(), file_path)
            
            grad_index += 1
    
    # Apply gradients
    model.optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    
    for i, layer in enumerate(model.layers):
        # Веса
        w = layer.get_weights()[0]
        print(f'Weights: {w}')
        
        #file_path = data_path + f'w{i}_pass{pass_idx}.dat'
        #save_float64_array_to_binary_file(w.T, file_path)
        
        # Смещения (если есть)
        if layer.use_bias:
            # Сохраняем смещения
            b = layer.get_weights()[1]
            print(f'Biases: {b}')
            
            #file_path = data_path + f'b{i}_pass{pass_idx}.dat'
            #save_float64_array_to_binary_file(b, file_path)
    

# Perform final forward pass to get updated predictions
y_data = model(x_data)
print('ydata:', y_data.numpy())
file_path = data_path + 'ydata.dat'
save_float64_array_to_binary_file(y_data, file_path)