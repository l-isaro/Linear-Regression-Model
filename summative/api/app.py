import gzip
import pickle
import pandas as pd
from flask import Flask
from flask_restx import Api, Resource, fields
from flask_cors import CORS

app = Flask(__name__)
CORS(app)
api = Api(app,
          title='Agritech Crop Yield Prediction API',
          version='1.0',
          description='Predict crop yield based on agricultural inputs')

ns = api.namespace('predict', description='Prediction operations')

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

prediction_model = api.model('PredictionInput', {
    'Region': fields.String(required=True, description='Region of the crop (e.g., North)'),
    'Soil_Type': fields.String(required=True, description='Type of soil (e.g., Loam)'),
    'Crop': fields.String(required=True, description='Crop type (e.g., Wheat)'),
    'Rainfall_mm': fields.Float(required=True, description='Rainfall in millimeters (e.g., 500)'),
    'Temperature_Celsius': fields.Float(required=True, description='Temperature in Celsius (e.g., 25)'),
    'Fertilizer_Used': fields.String(required=True, description='Fertilizer used (TRUE/FALSE)'),
    'Irrigation_Used': fields.String(required=True, description='Irrigation used (TRUE/FALSE)'),
    'Weather_Condition': fields.String(required=True, description='Weather condition (e.g., Sunny)'),
    'Days_to_Harvest': fields.Integer(required=True, description='Days to harvest (e.g., 120)')
})

def preprocess_input(input_data):
    if isinstance(input_data, dict):
        input_data = pd.DataFrame([input_data])

    input_data['Region'] = input_data['Region'].str.capitalize()
    input_data['Soil_Type'] = input_data['Soil_Type'].str.capitalize()
    input_data['Crop'] = input_data['Crop'].str.capitalize()
    input_data['Weather_Condition'] = input_data['Weather_Condition'].str.capitalize()

    input_data['Region'] = label_encoder_region.transform(input_data['Region'])
    input_data['Soil_Type'] = label_encoder_soil.transform(input_data['Soil_Type'])
    input_data['Crop'] = label_encoder_crop.transform(input_data['Crop'])
    input_data['Weather_Condition'] = label_encoder_weather.transform(input_data['Weather_Condition'])

    input_data['Fertilizer_Used'] = input_data['Fertilizer_Used'].astype(str).str.upper().map({'TRUE': 1, 'FALSE': 0})
    input_data['Irrigation_Used'] = input_data['Irrigation_Used'].astype(str).str.upper().map({'TRUE': 1, 'FALSE': 0})

    X = input_data[['Region', 'Soil_Type', 'Crop', 'Rainfall_mm', 'Temperature_Celsius', 
                    'Fertilizer_Used', 'Irrigation_Used', 'Weather_Condition', 'Days_to_Harvest']]
    return X

@ns.route('')
class Predict(Resource):
    @ns.doc('predict_crop_yield')
    @ns.expect(prediction_model, validate=True)
    @ns.response(200, 'Success')
    @ns.response(400, 'Validation Error')
    @ns.response(500, 'Server Error')
    def post(self):
        try:
            input_data = api.payload
            if not input_data:
                return {'error': 'No input data provided'}, 400

            X = preprocess_input(input_data)
            prediction = model.predict(X)[0]

            return {
                'prediction': float(prediction),
            }, 200
        except Exception as e:
            return {'error': str(e)}, 500

@app.route('/', methods=['GET'])
def home():
    return {'message': 'Agritech Crop Yield Prediction API is running', 'status': 'OK'}, 200

if __name__ == '__main__':
    import os
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)