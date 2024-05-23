
from flask import Flask, request, render_template
import numpy as np
import joblib
import pandas as pd
import os
from sklearn.pipeline import Pipeline

app = Flask(__name__)

# Load the model
model_path = os.path.join(os.getcwd(), 'final_model.joblib')
model = joblib.load(model_path)

# Dropdown values
makes = ["ACURA", "BUICK", "CADILLAC", "CHEVROLET", "CHRYSLER", "DODGE", "FORD", "GMC", "HONDA", "HUMMER", "HYUNDAI", 
         "INFINITI", "ISUZU", "JEEP", "KIA", "LEXUS", "LINCOLN", "MAZDA", "MERCURY", "MINI", "MITSUBISHI", "NISSAN", 
         "OLDSMOBILE", "PLYMOUTH", "PONTIAC", "SATURN", "SCION", "SUBARU", "SUZUKI", "TOYOTA", "TOYOTA SCION", "VOLKSWAGEN", "VOLVO"]

zip_regions = ["12", "16", "17", "19", "20", "21", "22", "23", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "37", "38", "39", "42", "43", "45", "46", "47", "48", "50", "55", "60", "62", "63", "64", "68", "70", "71", "72", "73", "74", "75", "76", "77", "78", "79", "80", "83", "84", "85", "87", "89", "90", "91", "92", "94", "95", "97", "98", "99"]

@app.route('/')
def home():
    return render_template('index.html', makes=makes, zip_regions=zip_regions)

@app.route('/predict', methods=['POST'])
def predict():
    # Collect all relevant features from the form
    input_data = {feature: request.form.get(feature, 'nan') for feature in model.feature_names_in_ if feature not in ['IsBadBuy']}
    
    # Convert numeric fields and ensure data types match training
    numeric_fields = [field for field in input_data if input_data[field].replace('.', '', 1).isdigit()]
    for field in numeric_fields:
        input_data[field] = float(input_data[field])
    
    # Vehicle Age calculation, if necessary
    if 'VehYear' in input_data and 'VehicleAge' not in input_data:
        input_data["VehicleAge"] = 2024 - int(input_data["VehYear"])
    
    # Prepare DataFrame for model
    data = pd.DataFrame([input_data])

    # Ensure the DataFrame matches the training features, including dummy variables for categories
    for col in model.feature_names_in_:
        if col not in data:
            data[col] = 0  # Assuming missing categorical columns should be zero (for one-hot encoding)
    
    # Make prediction
    prediction = model.predict(data)
    prediction_text = "This is a Good Buy" if prediction[0] == 0 else "This is a Bad Buy"
    
    return render_template('index.html', prediction_text=prediction_text, makes=makes, zip_regions=zip_regions)

if __name__ == "__main__":
    app.run(debug=True)
