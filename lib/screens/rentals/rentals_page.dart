import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/database/database_helper.dart';
import '../../models/rental_model.dart';
import '../../models/renter_model.dart';
import '../../models/vehicle_model.dart';

class RentalsPage extends StatefulWidget {
  const RentalsPage({super.key});

  @override
  State<RentalsPage> createState() => _RentalsPageState();
}

class _RentalsPageState extends State<RentalsPage> {
  final NumberFormat _currencyFormatter = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

  final DateFormat _dateFormatter = DateFormat('dd/MM/yyyy');

  bool _loading = true;
  String _selectedFilter = 'Ativas';
  List<_RentalListItem> _items = [];

  @override
  void initState() {
    super.initState();
    _loadRentals();
  }

  Future<void> _loadRentals() async {
    setState(() {
      _loading = true;
    });

    try {
      final rentals = await DatabaseHelper.instance.getRentals();

      final items = await Future.wait(
        rentals.map((rental) async {
          final vehicle = await DatabaseHelper.instance.getVehicleById(
            rental.vehicleId,
          );

          final renter = await DatabaseHelper.instance.getRenterById(
            rental.renterId,
          );

          return _RentalListItem(
            rental: rental,
            vehicle: vehicle,
            renter: renter,
          );
        }),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _items = items;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Não foi possível carregar as locações: $error',
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

  List<_RentalListItem> get _filteredItems {
    if (_selectedFilter == 'Todas') {
      return _items;
    }

    if (_selectedFilter == 'Encerradas') {
      return _items.where((item) {
        return item.rental.status == 'Encerrada';
      }).toList();
    }

    return _items.where((item) {
      return item.rental.status == 'Ativa';
    }).toList();
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'segunda-feira';
      case DateTime.tuesday:
        return 'terça-feira';
      case DateTime.wednesday:
        return 'quarta-feira';
      case DateTime.thursday:
        return 'quinta-feira';
      case DateTime.friday:
        return 'sexta-feira';
      case DateTime.saturday:
        return 'sábado';
      case DateTime.sunday:
        return 'domingo';
      default:
        return 'não definido';
    }
  }

  Color _statusColor(
    BuildContext context,
    String status,
  ) {
    if (status == 'Ativa') {
      return Colors.green;
    }

    return Theme.of(context).colorScheme.outline;
  }

  void _openNewRental() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'O formulário de nova locação será criado no próximo passo.',
        ),
      ),
    );
  }

  void _openRentalDetails(_RentalListItem item) {
    final vehicleName = item.vehicle == null
        ? 'Veículo não encontrado'
        : '${item.vehicle!.brand} ${item.vehicle!.model}';

    final renterName =
        item.renter?.name ?? 'Locatário não encontrado';

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              4,
              20,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicleName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  renterName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                _DetailRow(
                  label: 'Situação',
                  value: item.rental.status,
                ),
                _DetailRow(
                  label: 'Início',
                  value: _dateFormatter.format(
                    item.rental.startDate,
                  ),
                ),
                _DetailRow(
                  label: 'Valor cheio',
                  value: _currencyFormatter.format(
                    item.rental.fullValue,
                  ),
                ),
                _DetailRow(
                  label: 'Valor com desconto',
                  value: _currencyFormatter.format(
                    item.rental.discountedValue,
                  ),
                ),
                _DetailRow(
                  label: 'Pagamento',
                  value:
                      '${item.rental.paymentFrequency} — ${_weekdayName(item.rental.paymentWeekday)}',
                ),
                _DetailRow(
                  label: 'Caução',
                  value:
                      '${_currencyFormatter.format(item.rental.depositReceived)} de ${_currencyFormatter.format(item.rental.depositValue)}',
                ),
                _DetailRow(
                  label: 'KM inicial',
                  value: '${item.rental.initialKm} km',
                ),
                _DetailRow(
                  label: 'KM atual',
                  value: '${item.rental.currentKm} km',
                ),
                _DetailRow(
                  label: 'Fechamento do KM',
                  value:
                      'Todo dia ${item.rental.kmClosingDay}',
                ),
                _DetailRow(
                  label: 'Limite por ciclo',
                  value:
                      '${item.rental.kmLimitPerCycle} km',
                ),
                _DetailRow(
                  label: 'KM excedente',
                  value:
                      '${_currencyFormatter.format(item.rental.excessKmValue)} por km',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Locações'),
        actions: [
          IconButton(
            onPressed: _loadRentals,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(width: 6),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewRental,
        icon: const Icon(Icons.add),
        label: const Text('Nova locação'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                12,
              ),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'Ativas',
                    label: Text('Ativas'),
                    icon: Icon(Icons.key_outlined),
                  ),
                  ButtonSegment(
                    value: 'Encerradas',
                    label: Text('Encerradas'),
                    icon: Icon(Icons.history),
                  ),
                  ButtonSegment(
                    value: 'Todas',
                    label: Text('Todas'),
                    icon: Icon(Icons.list_alt_outlined),
                  ),
                ],
                selected: {_selectedFilter},
                onSelectionChanged: (selection) {
                  setState(() {
                    _selectedFilter = selection.first;
                  });
                },
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : filteredItems.isEmpty
                      ? _EmptyRentals(
                          selectedFilter: _selectedFilter,
                          onAdd: _openNewRental,
                        )
                      : RefreshIndicator(
                          onRefresh: _loadRentals,
                          child: ListView.separated(
                            padding: const EdgeInsets.fromLTRB(
                              16,
                              4,
                              16,
                              100,
                            ),
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, _) {
                              return const SizedBox(height: 12);
                            },
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final rental = item.rental;

                              final vehicleName =
                                  item.vehicle == null
                                      ? 'Veículo não encontrado'
                                      : '${item.vehicle!.brand} ${item.vehicle!.model}';

                              final plate =
                                  item.vehicle?.plate ?? 'Sem placa';

                              final renterName =
                                  item.renter?.name ??
                                      'Locatário não encontrado';

                              return Card(
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () {
                                    _openRentalDetails(item);
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
                                                BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.key_outlined,
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
                                                vehicleName,
                                                style: const TextStyle(
                                                  fontSize: 17,
                                                  fontWeight:
                                                      FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                '$plate • $renterName',
                                              ),
                                              const SizedBox(height: 10),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: [
                                                  _InfoChip(
                                                    icon: Icons
                                                        .payments_outlined,
                                                    label:
                                                        '${_currencyFormatter.format(rental.discountedValue)} com desconto',
                                                  ),
                                                  _InfoChip(
                                                    icon: Icons
                                                        .calendar_month_outlined,
                                                    label: _weekdayName(
                                                      rental
                                                          .paymentWeekday,
                                                    ),
                                                  ),
                                                  _InfoChip(
                                                    icon: Icons.speed,
                                                    label:
                                                        '${rental.currentKm} km',
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
                                                    rental.status,
                                                  ).withValues(
                                                    alpha: 0.14,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    20,
                                                  ),
                                                ),
                                                child: Text(
                                                  rental.status,
                                                  style: TextStyle(
                                                    color: _statusColor(
                                                      context,
                                                      rental.status,
                                                    ),
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.chevron_right,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RentalListItem {
  final RentalModel rental;
  final VehicleModel? vehicle;
  final RenterModel? renter;

  const _RentalListItem({
    required this.rental,
    required this.vehicle,
    required this.renter,
  });
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

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRentals extends StatelessWidget {
  final String selectedFilter;
  final VoidCallback onAdd;

  const _EmptyRentals({
    required this.selectedFilter,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final message = selectedFilter == 'Ativas'
        ? 'Nenhuma locação ativa'
        : selectedFilter == 'Encerradas'
            ? 'Nenhuma locação encerrada'
            : 'Nenhuma locação cadastrada';

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crie uma locação para ligar um veículo a um locatário e definir os valores, vencimentos, caução e controle de KM.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Criar nova locação'),
            ),
          ],
        ),
      ),
    );
  }
}