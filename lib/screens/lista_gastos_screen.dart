import 'package:flutter/material.dart';
import '../models/gasto.dart';
import '../utils/categorias.dart';
import 'formulario_gasto_screen.dart';
import 'resumen_mensual_screen.dart';

class ListaGastosScreen extends StatefulWidget {
  const ListaGastosScreen({super.key});

  @override
  State<ListaGastosScreen> createState() => _ListaGastosScreenState();
}

class _ListaGastosScreenState extends State<ListaGastosScreen> {
  final List<Gasto> _gastos = [];
  String _filtroCategoria = 'Todas';

  void _guardarGasto(Gasto gasto) {
    final index = _gastos.indexWhere((g) => g.id == gasto.id);
    
    if (index >= 0) {
      setState(() {
        _gastos[index] = gasto;
      });
    } else {
      setState(() {
        _gastos.add(gasto);
      });
    }
  }

  void _eliminarGasto(String id) {
    setState(() {
      _gastos.removeWhere((g) => g.id == id);
    });
  }

  void _navegarAFormulario(Gasto? gasto) async {
    final Gasto? gastoGuardado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormularioGastoScreen(
          gasto: gasto, // Si es nulo, es 'agregar', si no, es 'editar'
        ),
      ),
    );

    if (gastoGuardado != null) {
      _guardarGasto(gastoGuardado);
    }
  }

  void _navegarAResumen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResumenMensualScreen(
          gastos: _gastos, 
        ),
      ),
    );
  }

  double get _totalMesActual {
    final ahora = DateTime.now();
    double total = 0.0;
    for (var gasto in _gastos) {
      if (gasto.fecha.month == ahora.month && gasto.fecha.year == ahora.year) {
        total += gasto.monto;
      }
    }
    return total;
  }

  List<Gasto> get _gastosMostrados {
    List<Gasto> gastosFiltrados;
    if (_filtroCategoria == 'Todas') {
      gastosFiltrados = _gastos;
    } else {
      gastosFiltrados =
          _gastos.where((g) => g.categoria == _filtroCategoria).toList();
    }
    gastosFiltrados.sort((a, b) => b.fecha.compareTo(a.fecha));
    return gastosFiltrados;
  }

  String _formatCurrency(double monto) {
    return 'Bs. ${monto.toStringAsFixed(2)}';
  }

  String _formatDate(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  Icon _getIconoCategoria(String categoria) {
    IconData icono;
    switch (categoria) {
      case 'Comida':
        icono = Icons.fastfood;
        break;
      case 'Transporte':
        icono = Icons.directions_bus;
        break;
      case 'Entretenimiento':
        icono = Icons.movie;
        break;
      case 'Salud':
        icono = Icons.medical_services;
        break;
      case 'Educación':
        icono = Icons.school;
        break;
      case 'Hogar':
        icono = Icons.home;
        break;
      default:
        icono = Icons.attach_money;
    }
    return Icon(icono, color: Theme.of(context).colorScheme.secondary);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Gastos'),
        actions: [
          // Botón para ir al Resumen
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: _navegarAResumen,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: _filtroCategoria,
                  items: ['Todas', ...categorias]
                      .map((cat) => DropdownMenuItem(
                            value: cat,
                            child: Text(cat),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _filtroCategoria = newValue;
                      });
                    }
                  },
                ),
                Text(
                  _formatCurrency(_totalMesActual),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _gastosMostrados.length,
              itemBuilder: (context, index) {
                final gasto = _gastosMostrados[index];
                
                return Dismissible(
                  key: Key(gasto.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _eliminarGasto(gasto.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Gasto eliminado'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  background: Container(
                    color: Colors.red[700],
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColorLight.withOpacity(0.3),
                        child: _getIconoCategoria(gasto.categoria),
                      ),
                      title: Text(
                        gasto.descripcion,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                          '${gasto.categoria} - ${_formatDate(gasto.fecha)}'),
                      trailing: Text(
                        _formatCurrency(gasto.monto),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      onTap: () {
                        _navegarAFormulario(gasto);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navegarAFormulario(null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}