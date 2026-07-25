import 'package:flutter/material.dart';

import '../../core/database/database_helper.dart';
import '../../models/renter_model.dart';
import 'add_renter_page.dart';

class RentersPage extends StatefulWidget {
  const RentersPage({super.key});

  @override
  State<RentersPage> createState() => _RentersPageState();
}

class _RentersPageState extends State<RentersPage> {
  bool _loading = true;
  List<RenterModel> _renters = [];

  @override
  void initState() {
    super.initState();
    _loadRenters();
  }

  Future<void> _loadRenters() async {
    setState(() {
      _loading = true;
    });

    try {
      final renters = await DatabaseHelper.instance.getRenters();

      if (!mounted) {
        return;
      }

      setState(() {
        _renters = renters;
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openForm({RenterModel? renter}) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddRenterPage(renter: renter),
      ),
    );

    if (saved == true) {
      await _loadRenters();
    }
  }

  Future<void> _deleteRenter(RenterModel renter) async {
    if (renter.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Excluir locatário'),
          content: Text(
            'Deseja excluir o cadastro de ${renter.name}?',
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

    await DatabaseHelper.instance.deleteRenter(renter.id!);
    await _loadRenters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Locatários'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openForm,
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Novo locatário'),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _renters.isEmpty
              ? _EmptyRenters(onAdd: _openForm)
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  itemCount: _renters.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(height: 12);
                  },
                  itemBuilder: (context, index) {
                    final renter = _renters[index];

                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          _openForm(renter: renter);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 27,
                                child: Text(
                                  renter.name.isEmpty
                                      ? '?'
                                      : renter.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      renter.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('CPF: ${renter.cpf}'),
                                    const SizedBox(height: 2),
                                    Text('Telefone: ${renter.phone}'),
                                    if (renter.cnhExpiration.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        'CNH válida até: '
                                        '${renter.cnhExpiration}',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    _openForm(renter: renter);
                                  }

                                  if (value == 'delete') {
                                    _deleteRenter(renter);
                                  }
                                },
                                itemBuilder: (_) {
                                  return const [
                                    PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined),
                                          SizedBox(width: 10),
                                          Text('Editar'),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline),
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
    );
  }
}

class _EmptyRenters extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyRenters({
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
              Icons.people_outline,
              size: 72,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 18),
            const Text(
              'Nenhum locatário cadastrado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cadastre a primeira pessoa que aluga seus veículos.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_outlined),
              label: const Text('Cadastrar locatário'),
            ),
          ],
        ),
      ),
    );
  }
}