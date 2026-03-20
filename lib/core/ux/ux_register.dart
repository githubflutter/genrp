class UxRegister {
  UxRegister._();

  static const int _tierBase = 1000;
  static const int _paperScale = _tierBase * _tierBase;

  static const Map<int, String> papers = <int, String>{
    0: 'paperzero',
    1: 'paperone',
    2: 'papertwo',
    3: 'paperthree',
    4: 'paperfour',
  };

  static const Map<int, String> templates = <int, String>{
    1: 'tcrud',
    2: 'tsheet',
    3: 'treport',
    4: 'tdboard',
    5: 'twizard',
    6: 'tform',
  };

  static const Map<int, String> views = <int, String>{
    1: 'listview',
    2: 'gridview',
    3: 'datatableview',
    4: 'toolbarview',
    5: 'fromview',
    6: 'plistview',
    7: 'cardview',
    8: 'itemvew',
    9: 'emptyview',
    10: 'chooseview',
    11: 'alertview',
    12: 'collectionview',
    13: 'tabview',
  };

  static String paperId(int pid) => '$pid';

  static String templateId({required int pid, required int tid}) => '$pid.$tid';

  static String viewId({
    required int pid,
    required int tid,
    required int vid,
  }) => '$pid.$tid.$vid';

  // Packed structural code rule:
  // pid, tid, and vid each use 3 digits.
  // paper    -> pid * 1,000,000
  // template -> pid * 1,000,000 + tid * 1,000
  // view     -> pid * 1,000,000 + tid * 1,000 + vid
  static int paperCode(int pid) {
    _validateTier('pid', pid);
    return pid * _paperScale;
  }

  static int templateCode({required int pid, required int tid}) {
    _validateTier('pid', pid);
    _validateTier('tid', tid);
    return pid * _paperScale + tid * _tierBase;
  }

  static int viewCode({required int pid, required int tid, required int vid}) {
    _validateTier('pid', pid);
    _validateTier('tid', tid);
    _validateTier('vid', vid);
    return pid * _paperScale + tid * _tierBase + vid;
  }

  static ({int pid, int tid, int vid}) decodeCode(int code) {
    if (code < 0) {
      throw RangeError.value(code, 'code', 'UX code must be non-negative');
    }
    final pid = code ~/ _paperScale;
    final remainder = code % _paperScale;
    final tid = remainder ~/ _tierBase;
    final vid = remainder % _tierBase;
    return (pid: pid, tid: tid, vid: vid);
  }

  static void _validateTier(String name, int value) {
    if (value < 0 || value >= _tierBase) {
      throw RangeError.value(
        value,
        name,
        'UX tier values must be between 0 and 999',
      );
    }
  }
}

mixin Ux {
  int get i;
  String get n;
  int get s;

  // Shared experimental metadata bag for UX nodes.
  Map<String, dynamic> get m;
}
