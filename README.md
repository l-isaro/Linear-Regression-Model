# Agritech Crop Yield Prediction

## Mission
The mission of this project is to empower farmers with a mobile application that predicts crop yield based on environmental and agricultural factors, enabling data-driven decisions to optimize productivity and sustainability in small to medium-scale farming operations in diverse regions.

## Dataset Description and Source
The dataset used in this project is a rich agricultural dataset with **10,000 samples** (high volume) and a variety of features, capturing diverse farming scenarios across multiple regions, crops, and conditions. It includes **9 key features**: `Region`, `Soil_Type`, `Crop`, `Rainfall_mm`, `Temperature_Celsius`, `Fertilizer_Used`, `Irrigation_Used`, `Weather_Condition`, and `Days_to_Harvest`, with the target variable being crop yield in tons per hectare (tons/ha). The data was sourced from a combination of synthetic data generation and real-world agricultural records inspired by datasets like the FAO (Food and Agriculture Organization) and Kaggle’s "Crop Yield Prediction Dataset". This rich dataset ensures the model can generalize across different farming contexts, making it suitable for small to medium-scale farmers in varied climates.

## Video Demo
Watch a 6-minute demo of the Agritech app and API in action, including a mobile app prediction, Swagger UI API test, and a discussion of model performance:  
[Watch the Video Demo](https://youtu.be/4y-GpEX6X8Y)

## Use Case
This project addresses a specific use case: **predicting crop yield for small to medium-scale farmers** in regions with diverse climates (e.g., North, South, East, West) to help them plan planting, irrigation, and fertilization strategies. Unlike generic prediction models, this app focuses on actionable insights for farmers growing major crops like wheat, maize, and rice, considering local environmental factors such as rainfall, temperature, and soil type. The app provides yield predictions in tons/ha, enabling farmers to estimate harvests and optimize resource use, particularly in regions prone to variable weather conditions.

## Data Exploration and Visualizations
To understand the dataset and improve model training, we included the following visualizations, which directly influenced the training outcome:

1. **Correlation Heatmap**:
   - This heatmap visualizes the relationships between numerical features (`Rainfall_mm`, `Temperature_Celsius`, `Days_to_Harvest`) and the target variable (yield in tons/ha).
![correlation_heatmap](https://github.com/user-attachments/assets/d03b57b6-3fc6-47c1-93df-c5812daffd30)

2. **Average Yield and Rainfall by Weather Condition**:
   - This line plot shows the average yield and rainfall across different weather conditions (e.g., Sunny, Rainy, Cloudy).
![weather_yield_pattern](https://github.com/user-attachments/assets/d1c4f646-dd96-4493-b259-cf63ed947131)

## How to Use the App
1. **Mobile App**: Open the `Agritech` app on your mobile device, navigate to the Predict screen, and enter details like region, soil type, crop, rainfall, temperature, fertilizer use, irrigation, weather, and days to harvest. Tap "Predict" to get the yield in tons/ha.
2. **API Testing**: Use Swagger UI at `https://crop-yield-api.onrender.com/` to test the `/predict/` endpoint with a JSON payload (e.g., `{"Region": "North", "Soil_Type": "Loam", "Crop": "Wheat", "Rainfall_mm": 500, "Temperature_Celsius": 25, "Fertilizer_Used": "TRUE", "Irrigation_Used": "FALSE", "Weather_Condition": "Sunny", "Days_to_Harvest": 120}`).

## Deployment
The API is deployed on Render at `https://crop-yield-api.onrender.com/`, providing a scalable solution for real-time crop yield predictions. The mobile app integrates with this API to deliver predictions to farmers on the go.
