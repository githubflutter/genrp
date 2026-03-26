class NodeMeta {
  const NodeMeta({
    this.parentruntimeid,
    this.parentspecid,
    this.parentspectype,
    required this.routeid,
    required this.routetitle,
    required this.specid,
    required this.spectype,
  });

  final int? parentruntimeid;
  final int? parentspecid;
  final int? parentspectype;

  final int routeid;
  final String routetitle;

  final int specid;
  final int spectype;
}
