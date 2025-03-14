import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class MeditationChart extends StatelessWidget {
  final List<charts.Series<MeditationData, String>> seriesList;
  final bool animate;

  MeditationChart({required this.seriesList, this.animate = true});

  // Aggiungi un costruttore predefinito che utilizza dati di esempio
  MeditationChart.withSampleData()
      : seriesList = createSampleData(),
        animate = true;

  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      seriesList,
      animate: animate,
      barGroupingType: charts.BarGroupingType.grouped,
      behaviors: [charts.SeriesLegend()],
    );
  }

  static List<charts.Series<MeditationData, String>> createSampleData() {
    final data = [
      MeditationData('Mon', 30),
      MeditationData('Tue', 45),
      MeditationData('Wed', 60),
      MeditationData('Thu', 20),
      MeditationData('Fri', 50),
      MeditationData('Sat', 70),
      MeditationData('Sun', 40),
    ];

    return [
      charts.Series<MeditationData, String>(
        id: 'Meditation',
        colorFn: (_, __) => charts.MaterialPalette.purple.shadeDefault,
        domainFn: (MeditationData data, _) => data.day,
        measureFn: (MeditationData data, _) => data.minutes,
        data: data,
      )
    ];
  }
}

class MeditationData {
  final String day;
  final int minutes;

  MeditationData(this.day, this.minutes);
}