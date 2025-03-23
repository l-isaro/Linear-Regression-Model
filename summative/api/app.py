import gzip
import pickle
import pandas as pd
from flask import Flask, request
from flask_cors import CORS  # Add this import

app = Flask(__name__)
CORS(app)  # Add this line to allow all origins

# Load the model and label encoders
with gzip.open('best_model.pkl.gz', 'rb') as f:
    model_data = pickle.load(f)

model = model_data['model']
label_encoder_region = model_data['label_encoder_region']
label_encoder_soil = model_data['label_encoder_soil']
label_encoder_crop = model_data['label_encoder_crop']
label_encoder_weather = model_data['label_encoder_weather']

def preprocess_input(input_data):
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

    X = input_data[['Region', 'Soil_Type', 'Crop', 'Rainfall_mm', 'Temperature_Celsius', 
                    'Fertilizer_Used', 'Irrigation_Used', 'Weather_Condition', 'Days_to_Harvest']]
    return X

@app.route('/', methods=['GET'])
def home():
    return {'message': 'Crop Yield Prediction API is running', 'status': 'OK'}, 200

@app.route('/predict', methods=['POST'])
def predict():
    try:
        input_data = request.get_json()
        if not input_data:
            return {'error': 'No input data provided'}, 400

        X = preprocess_input(input_data)
        prediction = model.predict(X)[0]

        return {
            'prediction': float(prediction),
        }, 200
    except Exception as e:
        return {'error': str(e)}, 500

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)