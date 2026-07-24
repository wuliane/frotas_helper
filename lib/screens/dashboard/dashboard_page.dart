import 'package:flutter/material.dart';
import 'package:frotas_helper/screens/vehicles/vehicles_page.dart';

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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
                          builder: (_) => VehiclesPage(),
                        ),
                      );
                    },
                  ),
                  _QuickActionCard(
                    title: 'Locatários',
                    subtitle: 'Cadastro de clientes',
                    icon: Icons.person_outline,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'Aluguéis',
                    subtitle: 'Contratos e pagamentos',
                    icon: Icons.assignment_outlined,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'Manutenções',
                    subtitle: 'Custos e revisões',
                    icon: Icons.car_repair_outlined,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'Vistorias',
                    subtitle: 'Fotos e assinaturas',
                    icon: Icons.fact_check_outlined,
                    onTap: () {},
                  ),
                  _QuickActionCard(
                    title: 'Relatórios',
                    subtitle: 'Receitas e despesas',
                    icon: Icons.bar_chart_outlined,
                    onTap: () {},
                  ),
                ],
              ),
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
          Text(
            'Receitas: R\$ 0,00   •   Despesas: R\$ 0,00',
            style: TextStyle(
              color: colorScheme.onPrimary,
            ),
          ),
        ],
      ),
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
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
                color: Theme.of(context).colorScheme.primary,
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