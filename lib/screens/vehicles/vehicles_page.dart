import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/database_helper.dart';
import '../../models/vehicle_model.dart';
import 'add_vehicle_page.dart';

class VehiclesPage extends StatefulWidget {
  const VehiclesPage({super.key});

  @override
  State<VehiclesPage> createState() => _VehiclesPageState();
}

class _VehiclesPageState extends State<VehiclesPage> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  bool _loading = true;
  List<VehicleModel> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loading = true;
    });

    try {
      final vehicles =
          await DatabaseHelper.instance.getVehicles();

      if (!mounted) {
        return;
      }

      setState(() {
        _vehicles = vehicles;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erro ao carregar veículos: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openVehicleForm({
    VehicleModel? vehicle,
  }) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddVehiclePage(
          vehicle: vehicle,
        ),
      ),
    );

    if (saved == true) {
      await _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(
    VehicleModel vehicle,
  ) async {
    if (vehicle.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir veículo'),
          content: Text(
            'Deseja excluir ${vehicle.brand} '
            '${vehicle.model}, placa ${vehicle.plate}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await DatabaseHelper.instance.deleteVehicle(
        vehicle.id!,
      );

      await _loadVehicles();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veículo excluído com sucesso.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível excluir o veículo: $error',
          ),
        ),
      );
    }
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case 'Alugado':
        return colorScheme.primary;
      case 'Manutenção':
        return colorScheme.error;
      case 'Vendido':
        return colorScheme.outline;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Veículos'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openVehicleForm,
        icon: const Icon(Icons.add),
        label: const Text('Novo veículo'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _vehicles.isEmpty
              ? _EmptyVehicles(
                  onAdd: _openVehicleForm,
                )
              : RefreshIndicator(
                  onRefresh: _loadVehicles,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      12,
                      16,
                      100,
                    ),
                    itemCount: _vehicles.length,
                    separatorBuilder: (_, __) {
                      return const SizedBox(height: 12);
                    },
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];

                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            _openVehicleForm(
                              vehicle: vehicle,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    borderRadius:
                                        BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    Icons.directions_car,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${vehicle.brand} '
                                        '${vehicle.model}',
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${vehicle.plate} • '
                                        '${vehicle.year} • '
                                        '${vehicle.color}',
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _InfoChip(
                                            icon: Icons.speed,
                                            label:
                                                '${vehicle.currentKm} km',
                                          ),
                                          _InfoChip(
                                            icon: Icons
                                                .payments_outlined,
                                            label:
                                                '${_currencyFormatter.format(vehicle.rentalValue)} base',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Container(
                                        padding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            context,
                                            vehicle.status,
                                          ).withValues(
                                            alpha: 0.14,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          vehicle.status,
                                          style: TextStyle(
                                            color: _statusColor(
                                              context,
                                              vehicle.status,
                                            ),
                                            fontWeight:
                                                FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      _openVehicleForm(
                                        vehicle: vehicle,
                                      );
                                    }

                                    if (value == 'delete') {
                                      _deleteVehicle(vehicle);
                                    }
                                  },
                                  itemBuilder: (_) {
                                    return const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Editar'),
                                          ],
                                        ),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline,
                                            ),
                                            SizedBox(width: 10),
                                            Text('Excluir'),
                                          ],
                                        ),
                                      ),
                                    ];
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyVehicles extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyVehicles({
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhum veículo cadastrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre o primeiro veículo da sua frota para começar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar veículo'),
            ),
          ],
        ),
      ),
    );
  }
}