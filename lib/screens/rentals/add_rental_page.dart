import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/database_helper.dart';
import '../../models/rental_model.dart';
import '../../models/renter_model.dart';
import '../../models/vehicle_model.dart';

class AddRentalPage extends StatefulWidget {
  const AddRentalPage({super.key});

  @override
  State<AddRentalPage> createState() => _AddRentalPageState();
}

class _AddRentalPageState extends State<AddRentalPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullValueController = TextEditingController();
  final _discountedValueController = TextEditingController();
  final _depositValueController = TextEditingController();
  final _depositReceivedController = TextEditingController();
  final _initialKmController = TextEditingController();
  final _kmClosingDayController = TextEditingController();
  final _kmLimitController = TextEditingController();
  final _excessKmValueController = TextEditingController();
  final _notesController = TextEditingController();

  final _dateFormatter = DateFormat('dd/MM/yyyy');

  bool _loading = true;
  bool _saving = false;

  List<VehicleModel> _vehicles = [];
  List<RenterModel> _renters = [];

  VehicleModel? _selectedVehicle;
  RenterModel? _selectedRenter;

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  String _paymentFrequency = 'Semanal';
  int _paymentWeekday = DateTime.friday;

  @override
  void initState() {
    super.initState();

    _endDate = DateTime(
      _startDate.year + 1,
      _startDate.month,
      _startDate.day,
    );

    _kmClosingDayController.text = '10';
    _kmLimitController.text = '7000';
    _excessKmValueController.text = '0,50';
    _depositValueController.text = '1500,00';
    _depositReceivedController.text = '0,00';

    _loadInitialData();
  }

  @override
  void dispose() {
    _fullValueController.dispose();
    _discountedValueController.dispose();
    _depositValueController.dispose();
    _depositReceivedController.dispose();
    _initialKmController.dispose();
    _kmClosingDayController.dispose();
    _kmLimitController.dispose();
    _excessKmValueController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final vehicles = await DatabaseHelper.instance.getVehicles();
      final renters = await DatabaseHelper.instance.getRenters();

      final availableVehicles = vehicles.where((vehicle) {
        return vehicle.status == 'Disponível';
      }).toList();

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicles = availableVehicles;
        _renters = renters;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível carregar os dados: $error',
          ),
        ),
      );
    }
  }

  double _parseMoney(String value) {
    final normalized = value
        .trim()
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');

    return double.tryParse(normalized) ?? 0;
  }

  String _vehicleName(VehicleModel vehicle) {
    return '${vehicle.brand} ${vehicle.model} — ${vehicle.plate}';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Segunda-feira';
      case DateTime.tuesday:
        return 'Terça-feira';
      case DateTime.wednesday:
        return 'Quarta-feira';
      case DateTime.thursday:
        return 'Quinta-feira';
      case DateTime.friday:
        return 'Sexta-feira';
      case DateTime.saturday:
        return 'Sábado';
      case DateTime.sunday:
        return 'Domingo';
      default:
        return 'Não definido';
    }
  }

  void _selectVehicle(VehicleModel? vehicle) {
    setState(() {
      _selectedVehicle = vehicle;

      if (vehicle != null) {
        _initialKmController.text = vehicle.currentKm.toString();

        if (_fullValueController.text.trim().isEmpty) {
          _fullValueController.text = vehicle.rentalValue
              .toStringAsFixed(2)
              .replaceAll('.', ',');
        }
      }
    });
  }

  Future<void> _selectStartDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _startDate = selectedDate;

      _endDate = DateTime(
        selectedDate.year + 1,
        selectedDate.month,
        selectedDate.day,
      );
    });
  }

  Future<void> _selectEndDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate,
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );

    if (selectedDate == null) {
      return;
    }

    setState(() {
      _endDate = selectedDate;
    });
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    return null;
  }

  String? _moneyValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    if (_parseMoney(value) < 0) {
      return 'Digite um valor válido';
    }

    return null;
  }

  String? _positiveIntegerValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final number = int.tryParse(value.trim());

    if (number == null || number < 0) {
      return 'Digite um número válido';
    }

    return null;
  }

  String? _closingDayValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatório';
    }

    final day = int.tryParse(value.trim());

    if (day == null || day < 1 || day > 31) {
      return 'Use um dia entre 1 e 31';
    }

    return null;
  }

  Future<void> _saveRental() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um veículo.'),
        ),
      );

      return;
    }

    if (_selectedRenter == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um locatário.'),
        ),
      );

      return;
    }

    final vehicleId = _selectedVehicle!.id;
    final renterId = _selectedRenter!.id;

    if (vehicleId == null || renterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O veículo ou o locatário selecionado não possui ID.',
          ),
        ),
      );

      return;
    }

    final fullValue = _parseMoney(
      _fullValueController.text,
    );

    final discountedValue = _parseMoney(
      _discountedValueController.text,
    );

    final depositValue = _parseMoney(
      _depositValueController.text,
    );

    final depositReceived = _parseMoney(
      _depositReceivedController.text,
    );

    if (discountedValue > fullValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O valor com desconto não pode ser maior que o valor cheio.',
          ),
        ),
      );

      return;
    }

    if (depositReceived > depositValue) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'O valor recebido da caução não pode ser maior que a caução total.',
          ),
        ),
      );

      return;
    }

    final initialKm = int.parse(
      _initialKmController.text.trim(),
    );

    setState(() {
      _saving = true;
    });

    try {
      final rental = RentalModel(
        vehicleId: vehicleId,
        renterId: renterId,
        startDate: _startDate,
        endDate: _endDate,
        fullValue: fullValue,
        discountedValue: discountedValue,
        paymentFrequency: _paymentFrequency,
        paymentWeekday: _paymentWeekday,
        depositValue: depositValue,
        depositReceived: depositReceived,
        initialKm: initialKm,
        currentKm: initialKm,
        kmClosingDay: int.parse(
          _kmClosingDayController.text.trim(),
        ),
        kmLimitPerCycle: int.parse(
          _kmLimitController.text.trim(),
        ),
        excessKmValue: _parseMoney(
          _excessKmValueController.text,
        ),
        status: 'Ativa',
        notes: _notesController.text.trim(),
      );

      await DatabaseHelper.instance.insertRental(rental);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Locação criada com sucesso.',
          ),
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível criar a locação: $error',
          ),
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova locação'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              32,
            ),
            children: [
              const _SectionTitle(
                title: 'Veículo e locatário',
                icon: Icons.link,
              ),
              const SizedBox(height: 12),

              if (_vehicles.isEmpty)
                const _WarningCard(
                  message:
                      'Não existem veículos disponíveis. Cadastre um veículo ou encerre uma locação ativa.',
                )
              else
                DropdownButtonFormField<VehicleModel>(
                  value: _selectedVehicle,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Veículo',
                    prefixIcon: Icon(
                      Icons.directions_car_outlined,
                    ),
                  ),
                  items: _vehicles.map((vehicle) {
                    return DropdownMenuItem<VehicleModel>(
                      value: vehicle,
                      child: Text(
                        _vehicleName(vehicle),
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _selectVehicle,
                  validator: (vehicle) {
                    if (vehicle == null) {
                      return 'Selecione um veículo';
                    }

                    return null;
                  },
                ),

              const SizedBox(height: 14),

              if (_renters.isEmpty)
                const _WarningCard(
                  message:
                      'Não existem locatários cadastrados. Cadastre um locatário antes de criar a locação.',
                )
              else
                DropdownButtonFormField<RenterModel>(
                  value: _selectedRenter,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Locatário',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                  ),
                  items: _renters.map((renter) {
                    return DropdownMenuItem<RenterModel>(
                      value: renter,
                      child: Text(
                        renter.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (renter) {
                    setState(() {
                      _selectedRenter = renter;
                    });
                  },
                  validator: (renter) {
                    if (renter == null) {
                      return 'Selecione um locatário';
                    }

                    return null;
                  },
                ),

              const SizedBox(height: 26),

              const _SectionTitle(
                title: 'Valores negociados',
                icon: Icons.payments_outlined,
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _fullValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor cheio',
                        hintText: '650,00',
                        prefixText: 'R\$ ',
                      ),
                      validator: _moneyValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _discountedValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Com desconto',
                        hintText: '600,00',
                        prefixText: 'R\$ ',
                      ),
                      validator: _moneyValidator,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<String>(
                value: _paymentFrequency,
                decoration: const InputDecoration(
                  labelText: 'Periodicidade',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Semanal',
                    child: Text('Semanal'),
                  ),
                  DropdownMenuItem(
                    value: 'Quinzenal',
                    child: Text('Quinzenal'),
                  ),
                  DropdownMenuItem(
                    value: 'Mensal',
                    child: Text('Mensal'),
                  ),
                ],
                onChanged: (frequency) {
                  if (frequency == null) {
                    return;
                  }

                  setState(() {
                    _paymentFrequency = frequency;
                  });
                },
              ),

              const SizedBox(height: 14),

              DropdownButtonFormField<int>(
                value: _paymentWeekday,
                decoration: const InputDecoration(
                  labelText: 'Dia do pagamento',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                items: List.generate(7, (index) {
                  final weekday = index + 1;

                  return DropdownMenuItem<int>(
                    value: weekday,
                    child: Text(
                      _weekdayName(weekday),
                    ),
                  );
                }),
                onChanged: (weekday) {
                  if (weekday == null) {
                    return;
                  }

                  setState(() {
                    _paymentWeekday = weekday;
                  });
                },
              ),

              const SizedBox(height: 26),

              const _SectionTitle(
                title: 'Datas do contrato',
                icon: Icons.date_range_outlined,
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _DateField(
                      label: 'Data de início',
                      value: _dateFormatter.format(
                        _startDate,
                      ),
                      onTap: _selectStartDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DateField(
                      label: 'Data de término',
                      value: _endDate == null
                          ? 'Sem término'
                          : _dateFormatter.format(
                              _endDate!,
                            ),
                      onTap: _selectEndDate,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              const _SectionTitle(
                title: 'Caução',
                icon: Icons.account_balance_wallet_outlined,
              ),
              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _depositValueController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Caução total',
                        prefixText: 'R\$ ',
                      ),
                      validator: _moneyValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller:
                          _depositReceivedController,
                      keyboardType:
                          const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Valor recebido',
                        prefixText: 'R\$ ',
                      ),
                      validator: _moneyValidator,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 26),

              const _SectionTitle(
                title: 'Controle de quilometragem',
                icon: Icons.speed_outlined,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _initialKmController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'KM inicial da locação',
                  suffixText: 'km',
                  prefixIcon: Icon(Icons.speed),
                ),
                validator: _positiveIntegerValidator,
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _kmClosingDayController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Dia do fechamento',
                        hintText: '10',
                        prefixText: 'Dia ',
                      ),
                      validator: _closingDayValidator,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _kmLimitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Limite por ciclo',
                        hintText: '7000',
                        suffixText: 'km',
                      ),
                      validator: _positiveIntegerValidator,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              TextFormField(
                controller: _excessKmValueController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor por KM excedente',
                  hintText: '0,50',
                  prefixText: 'R\$ ',
                  suffixText: 'por km',
                ),
                validator: _moneyValidator,
              ),

              const SizedBox(height: 26),

              const _SectionTitle(
                title: 'Observações',
                icon: Icons.notes_outlined,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _notesController,
                maxLines: 4,
                textCapitalization:
                    TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Observações da locação',
                  alignLabelWithHint: true,
                  hintText:
                      'Informações adicionais, acordos especiais ou condições específicas.',
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: _saving ||
                          _vehicles.isEmpty ||
                          _renters.isEmpty
                      ? null
                      : _saveRental,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.check_circle_outline,
                        ),
                  label: Text(
                    _saving
                        ? 'Criando locação...'
                        : 'Criar locação',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionTitle({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
          ),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final String message;

  const _WarningCard({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: colorScheme.onErrorContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}