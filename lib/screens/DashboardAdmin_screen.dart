import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:collection/collection.dart';
import '../provider/AdminProvider.dart';


class DashboardAdmin extends StatefulWidget {
  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  @override
  void initState() {
    super.initState();
    Provider.of<AdminProvider>(context, listen: false).fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(title: Text("Tableau de Bord Administrateur")),
          body: provider.projectStats.isEmpty
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Statistiques des projets", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 16),
                _buildBarChart(provider),
                SizedBox(height: 16),
                Text("Taux de complétion : ${provider.projectCompletion.toStringAsFixed(1)}%"),
                SizedBox(height: 32),
                Text("Utilisateurs", style: Theme.of(context).textTheme.titleLarge),
                SizedBox(height: 16),
                _buildPieChart(provider),
                SizedBox(height: 32),
                _buildUserTable(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(AdminProvider provider) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final titles = provider.projectStats.keys.toList();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(titles[value.toInt()]),
                );
              },
              reservedSize: 30,
            ),
          )),
          barGroups: provider.projectStats.entries.mapIndexed((index, e) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(toY: e.value.toDouble(), color: Colors.blue),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPieChart(AdminProvider provider) {
    final data = provider.userStats;
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: data.entries.map((entry) {
            final color = entry.key == "Actifs" ? Colors.green : Colors.red;
            return PieChartSectionData(
              color: color,
              value: entry.value.toDouble(),
              title: '${entry.value}',
              radius: 60,
              titleStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildUserTable(AdminProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: provider.userStats.entries.map((entry) {
        return ListTile(
          leading: Icon(Icons.person),
          title: Text(entry.key),
          trailing: Text('${entry.value} utilisateurs'),
        );
      }).toList(),
    );
  }
}
