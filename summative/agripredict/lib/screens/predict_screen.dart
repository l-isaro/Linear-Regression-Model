import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});

  @override
  _PredictScreenState createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  final _formKey = GlobalKey<FormState>();
  final _regionController = TextEditingController();
  final _soilTypeController = TextEditingController();
  final _cropController = TextEditingController();
  final _rainfallController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _weatherController = TextEditingController();
  final _daysToHarvestController = TextEditingController();

  final _regionFocus = FocusNode();
  final _soilTypeFocus = FocusNode();
  final _cropFocus = FocusNode();
  final _rainfallFocus = FocusNode();
  final _temperatureFocus = FocusNode();
  final _weatherFocus = FocusNode();
  final _daysToHarvestFocus = FocusNode();

  String? _fertilizerUsed = 'TRUE';
  String? _irrigationUsed = 'FALSE';
  bool _isLoading = false;

  void _showResultsDialog(String result) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.grey,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const Text(
                  'Predicted Yield',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  result,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _predict() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    const String apiUrl = 'https://crop-yield-api.onrender.com/predict';

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
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _showResultsDialog(
          '${result['prediction'].toStringAsFixed(2)} tons/ha',
        );
      } else {
        final responseData = jsonDecode(response.body);
        _showErrorDialog(
          'Error: ${response.statusCode}',
          responseData['error']?.toString() ?? 'Unknown error',
        );
      }
    } catch (e) {
      _showErrorDialog('Failed to connect', e.toString());
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.green,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Agritech',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Center(
                    child: Text(
                      'Predict your crop yield with ease',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Location'),
                  _buildTextField(
                    _regionController,
                    'Region',
                    'e.g., North',
                    focusNode: _regionFocus,
                    nextFocus: _soilTypeFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a region';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _soilTypeController,
                    'Soil Type',
                    'e.g., Loam',
                    focusNode: _soilTypeFocus,
                    nextFocus: _cropFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a soil type';
                      }
                      return null;
                    },
                  ),
                  _buildSectionTitle('Crop Details'),
                  _buildTextField(
                    _cropController,
                    'Crop',
                    'e.g., Wheat',
                    focusNode: _cropFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a crop';
                      }
                      return null;
                    },
                  ),
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
                    _rainfallController,
                    'Rainfall (mm)',
                    'e.g., 500',
                    keyboardType: TextInputType.number,
                    focusNode: _rainfallFocus,
                    nextFocus: _temperatureFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter rainfall';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _temperatureController,
                    'Temperature (°C)',
                    'e.g., 25',
                    keyboardType: TextInputType.number,
                    focusNode: _temperatureFocus,
                    nextFocus: _weatherFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter temperature';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _weatherController,
                    'Weather Condition',
                    'e.g., Sunny',
                    focusNode: _weatherFocus,
                    nextFocus: _daysToHarvestFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a weather condition';
                      }
                      return null;
                    },
                  ),
                  _buildTextField(
                    _daysToHarvestController,
                    'Days to Harvest',
                    'e.g., 120',
                    keyboardType: TextInputType.number,
                    focusNode: _daysToHarvestFocus,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter days to harvest';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _predict,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Predict',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
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
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            keyboardType: keyboardType ?? TextInputType.text,
            validator: validator,
            onFieldSubmitted: (value) {
              if (nextFocus != null) {
                FocusScope.of(context).requestFocus(nextFocus);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedValue,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 16,
              ),
            ),
            items: options.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (value) {
              if (value == null) {
                return 'Please select an option';
              }
              return null;
            },
          ),
        ],
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
    _regionFocus.dispose();
    _soilTypeFocus.dispose();
    _cropFocus.dispose();
    _rainfallFocus.dispose();
    _temperatureFocus.dispose();
    _weatherFocus.dispose();
    _daysToHarvestFocus.dispose();
    super.dispose();
  }
}
