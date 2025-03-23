# app.py
import gzip
import pickle
import pandas as pd
from flask import Flask, request, jsonify

app = Flask(__name__)

# Load the model and label encoders
def load_model():
    with gzip.open('best_model.pkl.gz', 'rb') as f:
        model_data = pickle.load(f)
    return model_data

model_data = load_model()
model = model_data['model']
label_encoder_region = model_data['label_encoder_region']
label_encoder_soil = model_data['label_encoder_soil']
label_encoder_crop = model_data['label_encoder_crop']
label_encoder_weather = model_data['label_encoder_weather']

# Preprocessing function (adapted from your code)
def preprocess_input(input_data):
    # Convert input data to DataFrame if it’s a dict
    if isinstance(input_data, dict):
        input_data = pd.DataFrame([input_data])

    # Encode categorical variables
    input_data['Region'] = label_encoder_region.transform(input_data['Region'])
    input_data['Soil_Type'] = label_encoder_soil.transform(input_data['Soil_Type'])
    input_data['Crop'] = label_encoder_crop.transform(input_data['Crop'])
    input_data['Weather_Condition'] = label_encoder_weather.transform(input_data['Weather_Condition'])

    # Convert Fertilizer_Used and Irrigation_Used to integers (1/0)
    input_data['Fertilizer_Used'] = input_data['Fertilizer_Used'].astype(str).str.upper().map({'TRUE': 1, 'FALSE': 0})
    input_data['Irrigation_Used'] = input_data['Irrigation_Used'].astype(str).str.upper().map({'TRUE': 1, 'FALSE': 0})

    # Ensure correct feature order
    X = input_data[['Region', 'Soil_Type', 'Crop', 'Rainfall_mm', 'Temperature_Celsius', 
                    'Fertilizer_Used', 'Irrigation_Used', 'Weather_Condition', 'Days_to_Harvest']]
    return X

# API endpoint for prediction
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get JSON data from the request
        input_data = request.get_json()
        if not input_data:
            return jsonify({'error': 'No input data provided'}), 400

        # Preprocess the input
        X = preprocess_input(input_data)

        # Make prediction
        prediction = model.predict(X)[0]

        # Return the result as JSON
        return jsonify({
            'prediction': float(prediction),
            'model_name': model_data['model_name']
        }), 200

    except Exception as e:
        return jsonify({'error': str(e)}), 500

# Root endpoint for basic status check
@app.route('/', methods=['GET'])
def home():
    return jsonify({'message': 'Crop Yield Prediction API is running', 'status': 'OK'}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)