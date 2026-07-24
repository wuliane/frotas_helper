import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../models/vehicle_model.dart';

class AddVehiclePage extends StatefulWidget {
  const AddVehiclePage({super.key});

  @override
  State<AddVehiclePage> createState() => _AddVehiclePageState();
}

class _AddVehiclePageState extends State<AddVehiclePage> {
  final _formKey = GlobalKey<FormState>();

  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _kmController = TextEditingController();
  final _purchaseValueController = TextEditingController();
  final _rentalValueController = TextEditingController();

  String _status = 'Disponível';
  bool _saving = false;

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _kmController.dispose();
    _purchaseValueController.dispose();
    _rentalValueController.dispose();
    super.dispose();
  }

  double _parseDouble(String value) {
    return double.tryParse(
          value.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final vehicle = VehicleModel(
        plate: _plateController.text.trim().toUpperCase(),
        brand: _brandController.text.trim(),
        model: _modelController.text.trim(),
        year: int.parse(_yearController.text.trim()),
        color: _colorController.text.trim(),
        currentKm: int.parse(_kmController.text.trim()),
        purchaseValue: _parseDouble(_purchaseValueController.text),
        rentalValue: _parseDouble(_rentalValueController.text),
        status: _status,
      );

      await DatabaseHelper.instance.insertVehicle(vehicle);

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Não foi possível salvar o veículo: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _integerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    if (int.tryParse(value.trim()) == null) {
      return 'Digite somente números';
    }

    return null;
  }

  String? _moneyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    if (_parseDouble(value) < 0) {
      return 'Digite um valor válido';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastrar veículo'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              TextFormField(
                controller: _plateController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Placa',
                  hintText: 'ABC1D23',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _brandController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Marca',
                  hintText: 'Volkswagen',
                  prefixIcon: Icon(Icons.factory_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _modelController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Modelo',
                  hintText: 'Voyage 1.0',
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _yearController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Ano',
                        hintText: '2020',
                      ),
                      validator: _integerValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _colorController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Cor',
                        hintText: 'Branco',
                      ),
                      validator: _requiredValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _kmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quilometragem atual',
                  hintText: '85000',
                  suffixText: 'km',
                  prefixIcon: Icon(Icons.speed_outlined),
                ),
                validator: _integerValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _purchaseValueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor de compra',
                  hintText: '37000,00',
                  prefixText: 'R\$ ',
                ),
                validator: _moneyValidator,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _rentalValueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor do aluguel semanal',
                  hintText: '600,00',
                  prefixText: 'R\$ ',
                ),
                validator: _moneyValidator,
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Situação',
                  prefixIcon: Icon(Icons.info_outline),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Disponível',
                    child: Text('Disponível'),
                  ),
                  DropdownMenuItem(
                    value: 'Alugado',
                    child: Text('Alugado'),
                  ),
                  DropdownMenuItem(
                    value: 'Manutenção',
                    child: Text('Manutenção'),
                  ),
                  DropdownMenuItem(
                    value: 'Vendido',
                    child: Text('Vendido'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) {
                    return;
                  }

                  setState(() {
                    _status = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : _saveVehicle,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(
                  _saving ? 'Salvando...' : 'Salvar veículo',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}