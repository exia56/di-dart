import 'di.dart';

class A {}

class B {}

class C {
  final A a;
  final B b;
  C(this.a, this.b);
}

class D extends C {
  D({A a, B b}) : super(a, b);
}

class E extends C {
  E(A a, {B b}) : super(a, b);
}

void main() {
  DI.insatnce.register('A', () => A());
  DI.insatnce.register('B', () => B());
  DI.insatnce.register('C', (A a, B b) => C(a, b), dependencyKeys: ['A', 'B']);
  DI.insatnce.register('D', ({A a, B b}) => D(a: a, b: b),
      namedParameter: {'a': 'A', 'b': 'B'});
  DI.insatnce.register('E', (A a, {B b}) => E(a, b: b),
      dependencyKeys: ['A'], namedParameter: {'b': 'B'});
  final a = DI.insatnce.get<A>(('A'));
  final asd = DI.insatnce.get<A>(('A'));
  final c = DI.insatnce.get<C>(('C'));
  final d = DI.insatnce.get<C>(('D'));
  final e = DI.insatnce.get<C>(('E'));

  assert(a is A);
  assert(asd is A);
  assert(asd == a);
  assert(c is C);
  assert(d is C);
  assert(d is D);
  assert(e is! D);
  assert(e is C);
  print(d);
}
