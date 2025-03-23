import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  // Controllers for text fields
  final _regionController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _cropController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weatherController = TextEditingController();
  final _daysToHarvestController = TextEditingController();

  // Dropdown values for boolean fields
  String? _fertilizerUsed = 'TRUE';
  String? _irrigationUsed = 'FALSE';

  String _result = '';

  Future<void> _predict() async {
    const String apiUrl = 'https://crop-yield-api.onrender.com/predict';

    // Validate inputs
    if (_regionController.text.isEmpty ||
        _soilTypeController.text.isEmpty ||
        _cropController.text.isEmpty ||
        _rainfallController.text.isEmpty ||
        _temperatureController.text.isEmpty ||
        _weatherController.text.isEmpty ||
        _daysToHarvestController.text.isEmpty ||
        _fertilizerUsed == null ||
        _irrigationUsed == null) {
      setState(() {
        _result = 'Error: Please fill in all fields.';
      });
      return;
    }

    // Prepare data
    final Map<String, dynamic> data = {
      'Region': _regionController.text,
      'Soil_Type': _soilTypeController.text,
      'Crop': _cropController.text,
      'Rainfall_mm': double.tryParse(_rainfallController.text) ?? 0,
      'Temperature_Celsius': double.tryParse(_temperatureController.text) ?? 0,
      'Fertilizer_Used': _fertilizerUsed!,
      'Irrigation_Used': _irrigationUsed!,
      'Weather_Condition': _weatherController.text,
      'Days_to_Harvest': int.tryParse(_daysToHarvestController.text) ?? 0,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        setState(() {
          _result =
              'Predicted Yield: ${result['prediction'].toStringAsFixed(2)} tons/ha\nModel: ${result['model_name']}';
        });
      } else {
        setState(() {
          _result = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: Unable to connect to the server. $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Yield Prediction'),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Enter Crop Details',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _buildSectionTitle('Location'),
                _buildTextField(_regionController, 'Region', 'e.g., North'),
                _buildTextField(_soilTypeController, 'Soil Type', 'e.g., Loam'),
                _buildSectionTitle('Crop Details'),
                _buildTextField(_cropController, 'Crop', 'e.g., Wheat'),
                _buildDropdown(
                    'Fertilizer Used', ['TRUE', 'FALSE'], _fertilizerUsed,
                    (value) {
                  setState(() => _fertilizerUsed = value);
                }),
                _buildDropdown(
                    'Irrigation Used', ['TRUE', 'FALSE'], _irrigationUsed,
                    (value) {
                  setState(() => _irrigationUsed = value);
                }),
                _buildSectionTitle('Conditions'),
                _buildTextField(
                    _rainfallController, 'Rainfall (mm)', 'e.g., 500',
                    keyboardType: TextInputType.number),
                _buildTextField(
                    _temperatureController, 'Temperature (°C)', 'e.g., 25',
                    keyboardType: TextInputType.number),
                _buildTextField(
                    _weatherController, 'Weather Condition', 'e.g., Sunny'),
                _buildTextField(
                    _daysToHarvestController, 'Days to Harvest', 'e.g., 120',
                    keyboardType: TextInputType.number),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _predict,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text(
                    'Predict',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    _result.isEmpty ? 'Prediction will appear here' : _result,
                    style: TextStyle(
                      fontSize: 16,
                      color: _result.startsWith('Error')
                          ? Colors.red
                          : Colors.green[900],
                      fontWeight:
                          _result.isEmpty ? FontWeight.normal : FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, String hint,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        keyboardType: keyboardType ?? TextInputType.text,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options,
      String? selectedValue, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
        items: options.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  @override
  void dispose() {
    _regionController.dispose();
    _soilTypeController.dispose();
    _cropController.dispose();
    _rainfallController.dispose();
    _temperatureController.dispose();
    _weatherController.dispose();
    _daysToHarvestController.dispose();
    super.dispose();
  }
}
