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
loss_map = {0: 'mean_squared_error', 1: 'mean_absolute_error', 2: 'mean_absolute_percentage_error', 3: 'mean_squared_logarithmic_error', 4: 'cosine_similarity'}
optimizer_map = {0: keras.optimizers.SGD, 1: keras.optimizers.Adam, 2: keras.optimizers.RMSprop}
loss_func = loss_map[cfg['lossFunc']]
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

# Compile model with optimizer and loss
optimizer = optimizer_type() # Initialize selected optimizer
model.compile(optimizer=optimizer, loss=loss_func)

# Perform backward passes
for pass_idx in range(count):
    print(f'Backward pass {pass_idx + 1}/{count}')
    
    # Compute gradients
    with tf.GradientTape() as tape:
        predictions = model(x_data, training=True)
        loss = model.loss(y_true, predictions)
    
    # Get gradients
    gradients = tape.gradient(loss, model.trainable_variables)
    
    # Save gradients and update weights
    for i, (layer, grad) in enumerate(zip(model.layers[1:], gradients)):
        # Gradients for weights and biases (if used)
        w_grad = grad[0] # Weight gradients
        file_path = data_path + f'w_grad{i}_pass{pass_idx}.dat'
        save_float64_array_to_binary_file(w_grad.numpy().T, file_path) # Transpose back to match your convention
        print(f'w_grad{i}_pass{pass_idx}:', w_grad.numpy().T)
        
        if layer.use_bias:
            b_grad = grad[1] # Bias gradient
            file_path = data_path + f'b_grad{i}_pass{pass_idx}.dat'
            save_float64_array_to_binary_file(b_grad.numpy(), file_path)
            print(f'b_grad{i}_pass{pass_idx}:', b_grad.numpy())
        
        # Update weights
        w = layer.get_weights()[0]
        file_path = data_path + f'w{i}_pass{pass_idx}.dat'
        save_float64_array_to_binary_file(w.T, file_path) # Transpose to match your convention
        print(f'w{i}_pass{pass_idx}:', w.T)
        
        if layer.use_bias:
            b = layer.get_weights()[1]
            file_path = data_path + f'b{i}_pass{pass_idx}.dat'
            save_float64_array_to_binary_file(b, file_path)
            print(f'b{i}_pass{pass_idx}:', b)
    
    # Apply gradients to update model weights
    model.optimizer.apply_gradients(zip(gradients, model.trainable_variables))

# Perform final forward pass to get updated predictions
y_data = model(x_data)
print('ydata:', y_data.numpy())
file_path = data_path + 'ydata.dat'
save_float64_array_to_binary_file(y_data, file_path)