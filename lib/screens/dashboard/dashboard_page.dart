import 'package:flutter/material.dart';

import '../renters/renters_page.dart';
import '../vehicles/vehicles_page.dart';
import '../rentals/rentals_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frotas Helper',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Controle da sua frota',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: 'Notificações',
            icon: const Icon(
              Icons.notifications_outlined,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _FinancialCard(),
              const SizedBox(height: 24),
              const Text(
                'Resumo da frota',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: 'Alugados',
                      value: '0',
                      icon: Icons.key_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      title: 'Disponíveis',
                      value: '0',
                      icon: Icons.directions_car_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Expanded(
                    child: _StatusCard(
                      title: 'Manutenção',
                      value: '0',
                      icon: Icons.build_outlined,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _StatusCard(
                      title: 'Locatários',
                      value: '0',
                      icon: Icons.people_outline,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Acesso rápido',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.45,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _QuickActionCard(
                    title: 'Veículos',
                    subtitle: 'Cadastrar e consultar',
                    icon: Icons.directions_car_filled_outlined,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const VehiclesPage(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Locatários',
                    subtitle: 'Cadastro de clientes',
                    icon: Icons.person_outline,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RentersPage(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Locações',
                    subtitle: 'Contratos e pagamentos',
                    icon: Icons.assignment_outlined,
                    onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RentalsPage(),
                      ),
                    );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Manutenções',
                    subtitle: 'Custos e revisões',
                    icon: Icons.car_repair_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'O módulo de manutenções ainda será criado.',
                          ),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Vistorias',
                    subtitle: 'Fotos e assinaturas',
                    icon: Icons.fact_check_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'O módulo de vistorias ainda será criado.',
                          ),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Relatórios',
                    subtitle: 'Receitas e despesas',
                    icon: Icons.bar_chart_outlined,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'O módulo de relatórios ainda será criado.',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                'Próximos alertas',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const _EmptyAlertsCard(),
            ],
          ),
        ),
      ),
    );
  }
}

class _FinancialCard extends StatelessWidget {
  const _FinancialCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primaryContainer,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultado do mês',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'R\$ 0,00',
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FinancialItem(
                  title: 'Receitas',
                  value: 'R\$ 0,00',
                  icon: Icons.arrow_upward,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
              Container(
                width: 1,
                height: 42,
                color: colorScheme.onPrimary.withValues(
                  alpha: 0.35,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _FinancialItem(
                  title: 'Despesas',
                  value: 'R\$ 0,00',
                  icon: Icons.arrow_downward,
                  foregroundColor: colorScheme.onPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FinancialItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color foregroundColor;

  const _FinancialItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: foregroundColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: foregroundColor.withValues(
                    alpha: 0.8,
                  ),
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: foregroundColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyAlertsCard extends StatelessWidget {
  const _EmptyAlertsCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 22,
        ),
        child: Row(
          children: [
            Icon(
              Icons.notifications_none,
              size: 34,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nenhum alerta pendente',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Os lembretes de quilometragem, pagamentos e manutenção aparecerão aqui.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}