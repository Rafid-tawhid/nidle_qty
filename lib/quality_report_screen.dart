import 'package:flutter/material.dart';
import 'package:nidle_qty/providers/counting_provider.dart';
import 'package:nidle_qty/service_class/hive_service_class.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'models/local_send_data_model.dart';
import 'models/total_counting_model.dart';

class ProductionReportScreen extends StatelessWidget {
  final TotalCountingModel stats;

  ProductionReportScreen({required this.stats});


  @override
  Widget build(BuildContext context) {
    final chartData = [
      _ChartData('Pass', stats.totalPass ?? 0, Colors.green),
      _ChartData('Alter', stats.totalAlter ?? 0, Colors.orange),
      _ChartData('Alter Check', stats.totalAlterCheck ?? 0, Colors.blue),
      _ChartData('Reject', stats.totalReject ?? 0, Colors.red),
    ];

    final total = chartData.fold(0, (sum, item) => sum + item.value.toInt());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quality Control Dashboard'),
        centerTitle: true,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Consumer<CountingProvider>(
          builder: (context,pro,_)=>Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pie Chart
              _buildVerticalBarChart(chartData),
              const SizedBox(height: 24),

              // Summary Cards
              _buildSummaryCards(total),
              const SizedBox(height: 16),

              // Data Table
              _buildDataTable(chartData, total),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildVerticalBarChart(List<_ChartData> chartData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quality Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 300,
              child: SfCartesianChart(
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: const TextStyle(color: Colors.black54),
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  edgeLabelPlacement: EdgeLabelPlacement.shift,
                  numberFormat: NumberFormat.compact(),
                  labelStyle: const TextStyle(color: Colors.black54),
                  axisLine: const AxisLine(width: 0),
                  majorTickLines: const MajorTickLines(size: 0),
                  minimum: 0,
                ),
                series: <CartesianSeries<_ChartData, String>>[
                  ColumnSeries<_ChartData, String>(
                    dataSource: chartData,
                    xValueMapper: (data, _) => data.category,
                    yValueMapper: (data, _) => data.value,
                    pointColorMapper: (data, _) => data.color, // Use color from data
                    dataLabelSettings: const DataLabelSettings(
                      isVisible: true,
                      labelAlignment: ChartDataLabelAlignment.outer,
                      textStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    width: 0.6,
                    spacing: 0.2,
                    borderRadius: BorderRadius.circular(4), // Rounded bar corners
                  )
                ],
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  header: 'Category',
                  format: 'point.x : point.y',
                ),
                palette: [
                  Colors.blue.shade400,
                  Colors.green.shade400,
                  Colors.orange.shade400,
                  Colors.red.shade400,
                  Colors.purple.shade400,
                ], // Fallback colors if colorMapper not provided
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(num total) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total Items',
            value: total,
            icon: Icons.inventory_2_outlined,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Pass Rate',
            value: total > 0
                ? (stats.totalPass ?? 0) / total * 100
                : 0,
            icon: Icons.percent,
            color: Colors.green,
            isPercentage: true,
          ),
        ),
      ],
    );
  }

  Widget _buildDataTable(List<_ChartData> data, num total) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Detailed Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            DataTable(
              columnSpacing: 12,
              columns: const [
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Count')),
                DataColumn(label: Text('Percentage')),
              ],
              rows: data.map((item) {
                final percentage = total > 0 ? (item.value / total * 100) : 0;
                return DataRow(cells: [
                  DataCell(
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: item.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item.category),
                      ],
                    ),
                  ),
                  DataCell(Text(item.value.toString())),
                  DataCell(Text('${percentage.toStringAsFixed(1)}%')),
                ]);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final num value;
  final IconData icon;
  final Color color;
  final bool isPercentage;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.isPercentage = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isPercentage
                  ? '${value.toStringAsFixed(1)}%'
                  : value.toString(),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartData {
  final String category;
  final num value;
  final Color color;
  late num sum;

  _ChartData(this.category, this.value, this.color);
}