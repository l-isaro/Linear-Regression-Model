# test_api.py
import requests

url = 'http://localhost:5000/predict'
input_data = {
    'Region': 'North',
    'Soil_Type': 'Loam',
    'Crop': 'Wheat',
    'Rainfall_mm': 500,
    'Temperature_Celsius': 25,
    'Fertilizer_Used': 'TRUE',
    'Irrigation_Used': 'FALSE',
    'Weather_Condition': 'Sunny',
    'Days_to_Harvest': 120
}

response = requests.post(url, json=input_data)
print(response.status_code)
print(response.json())