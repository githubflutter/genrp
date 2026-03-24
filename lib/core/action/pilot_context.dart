class DataSet {
  // Represents the data model pool
}

class DataSource {
  // Represents the list of data / table rows
}

class PilotContext {
  PilotContext({
    required this.dataSet,
    required this.dataSource,
    Map<String, dynamic>? uxContext,
  }) : uxContext = uxContext ?? <String, dynamic>{};

  final DataSet dataSet;
  final DataSource dataSource;
  final Map<String, dynamic> uxContext;
}
