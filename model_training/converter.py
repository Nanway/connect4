import tensorflow as tf
import sys

if (len(sys.argv) < 3):
    print("Usage python converter.py model_path output_model_path")
    exit()

model_name = sys.argv[1]
output = sys.argv[2]

model = tf.keras.models.load_model(model_name)
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converted = converter.convert()
open(output, "wb").write(converted)