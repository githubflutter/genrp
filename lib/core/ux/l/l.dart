mixin L {
  // Layout layer owns panel and tab arrangement and hosts template variants.
  // lid -> 0:Lsingle, 1:Ldual, 2:Ltriple, 3:Lquad, 4:Ltabs
  // n -> lsingle, ldual, ltriple, lquad, ltabs
  int get lid;
  int get s;
  int get i;
  String get n;
}
