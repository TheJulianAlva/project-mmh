import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project_mmh/core/presentation/widgets/app_scaffold.dart';
import 'package:project_mmh/features/notas/presentation/widgets/lista_materiales_list_view.dart';
import 'package:project_mmh/features/notas/presentation/widgets/nota_general_list_view.dart';
import 'package:project_mmh/features/notas/presentation/widgets/prepaciente_list_view.dart';

class NotasScreen extends StatefulWidget {
  const NotasScreen({super.key});

  @override
  State<NotasScreen> createState() => _NotasScreenState();
}

class _NotasScreenState extends State<NotasScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  static const _createRoutes = [
    '/notas/nueva',
    '/notas/prepacientes/nuevo',
    '/notas/materiales/nueva',
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Notas',
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            context.push(_createRoutes[_tabController.index]),
        child: const Icon(Icons.add),
      ),
      slivers: [
        SliverToBoxAdapter(
          child: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            tabs: const [
              Tab(text: 'Generales'),
              Tab(text: 'Prepacientes'),
              Tab(text: 'Materiales'),
            ],
          ),
        ),
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: const [
              NotaGeneralListView(),
              PrepacienteListView(),
              ListaMaterialesListView(),
            ],
          ),
        ),
      ],
    );
  }
}
