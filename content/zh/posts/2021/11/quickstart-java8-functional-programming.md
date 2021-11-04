---
title: "快速开始Java8函数式编程"
date: 2021-11-02T06:12:46+08:00
description: "快速开始Java8函数式编程"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
categories:
- java
---

Java 8 Lambda 表达式和方法引用 (Method References) 允许你以函数式编程。函数式编程抽象行为，通过合并现有代码来生成新功能而不是从头开始编写所有内容，我们可以更快地获得更可靠的代码。可以把函数当作方法入参传递给方法，以来控制方法的行为，类似设计模式的策略模式。

## Lambda表达式

Lambda表达式，从语法上看是一个函数，而非对象。实际上，Java虚拟机会动态生成一个对象，它的方法会包含这个函数描述的行为。

例如：

```
interface Description {
  String brief();
}
interface Body {
  String detailed(String head);
}
interface Multi {
  String twoArg(String head, Double d);
}
```

```
Body bod = h -> h + "No Parens";
Body bod2 = (h) -> h + "More details";
Description desc = () -> "Short info";
Multi mult = (h, n) -> h + n;
Description moreLines = () -> {
    System.out.println("moreLines");
    return "from moreLines";
};
```

lambda表示有三个部分，第一部分就是参数，第二部分是箭头`->`，第三部分就是方法体。

> 当只有一个参数时，可以省略圆括号。
> 当方法体只有一行时，可以省略花括号和return，还有分号。多行时，编写与方法一致。

lambda表达式只能赋值给只有一个抽象方法的接口，或只有一个抽象方法的抽象类。

lambda表达式使用递归

```
interface IntCall {
  int call(int arg);
}

public class RecursiveFibonacci {
  IntCall fib;
  RecursiveFibonacci() {
    fib = n -> n == 0 ? 0 :
               n == 1 ? 1 :
               fib.call(n - 1) + fib.call(n - 2);
  }
  int fibonacci(int n) { return fib.call(n); }
  public static void main(String[] args) {
    RecursiveFibonacci rf = new RecursiveFibonacci();
    for(int i = 0; i <= 10; i++)
      System.out.println(rf.fibonacci(i));
  }
}
```

> 递归方法必须是实例变量或静态变量，否则会出现编译时错误。

## 方法引用

方法引用组成：类名/对象名,后面跟 `::`，然后跟方法名称。

```
interface Callable { // [1]
  void call(String s);
}
class Describe {
  void show(String msg) { // [2]
    System.out.println(msg);
  }
}
public class MethodReferences {
  static void hello(String name) { // [3]
    System.out.println("Hello, " + name);
  }
  static class Description {
    String about;
    Description(String desc) { about = desc; }
    void help(String msg) { // [4]
      System.out.println(about + " " + msg);
    }
  }
  static class Helper {
    static void assist(String msg) { // [5]
      System.out.println(msg);
    }
  }
  public static void main(String[] args) {
    Describe d = new Describe();
    Callable c = d::show; // [6] 实例方法引用
    c.call("call()"); // [7]
    c = MethodReferences::hello; // [8] 外部类的静态方法引用
    c.call("Bob");
    c = new Description("valuable")::help; // [9] 静态内部类对象的实例方法引用
    c.call("information");
    c = Helper::assist; // [10] 静态内部类的静态方法引用
    c.call("Help!");
  }
}
```

方法引用的方法签名符合要赋值的接口方法的方法签名，例如Describe的show()与Callable的call()，对已实例化对象的方法的引用，有时称为绑定方法引用。

未绑定的方法引用是指没有关联对象的普通（非静态）方法。 

```
class X {
  String f() { return "X::f()"; }
}
interface MakeString {
  String make();
}
interface TransformX {
  String transform(X x);
}
public class UnboundMethodReference {
  public static void main(String[] args) {
    // MakeString ms = X::f; // [1]
    TransformX sp = X::f;
    X x = new X();
    System.out.println(sp.transform(x)); // [2]
    System.out.println(x.f()); // 同等效果
  }
}
```

> 未绑定的方法引用的类名与要赋值的接口的方法第一参数类型名要一致。在调用此接口时要传入对象，该对象与方法引用进行绑定。这个用法非常妙

构造器的方法引用，形如：`String::new`，`String[]::new`，构造器有分无参和有参构造器，赋值给参数不同方法的接口，对应使用相应参数数量的构造器。

```
class Dog {
  String name;
  int age = -1; // For "unknown"
  Dog() { name = "stray"; }
  Dog(String nm) { name = nm; }
  Dog(String nm, int yrs) { name = nm; age = yrs; }
}
interface MakeNoArgs {
  Dog make();
}
interface Make1Arg {
  Dog make(String nm);
}
interface Make2Args {
  Dog make(String nm, int age);
}
public class CtorReference {
  public static void main(String[] args) {
    MakeNoArgs mna = Dog::new; // [1]
    Make1Arg m1a = Dog::new;   // [2]
    Make2Args m2a = Dog::new;  // [3]
    Dog dn = mna.make();
    Dog d1 = m1a.make("Comet");
    Dog d2 = m2a.make("Ralph", 4);
  }
}
```

## 函数式接口

由于lambda表达式包含类型推导，要想让编译器能推断出参数和返回值的类型，需要函数式接口。Java有内置的函数接口，不过也可以自定义函数式接口。Java1.8以前的函数式接口有：`Runnable`、`Callable<T>`。
Java1.8引入了`java.util.function`这个包，里面包含大量的函数式接口，它们只包含单独的方法，即函数式方法。查看这些接口的源代码，会发现它们都使用了一个注解`FunctionalInterface`，强制使此接口只能有一个抽象方法。

常用的函数时接口如下：

|接口|函数式方法|
|:-:|:-:|
|Supplier<T>|T get()|
|Consumer<T>|void accept(T t)|
|Function<T,R>|R apply(T t)|
|Predicate<T>|boolean test(T t)|
|UnaryOperator<T>|T apply(T t)|
|BinaryOperator<T>|T apply(T t1, T t2)|

还有其他接口，这里就不列举，都是通过以上接口衍生的。例如：`LongConsumer`，参数类型是Long、`LongSupplier`，返回值类型是Long、IntToLongFunction，参数是Integer，返回值是Long等等。详情请看源代码或Java API Docs。


## 高阶函数
Lambda表达式和方法引用可以充当方法的参数或返回值，也可以理解为消费和产生函数的方法被称为高阶函数。例如：很多的函数式接口都有默认实现的一个方法`andThen`，这个方法的参数after类型与对应接口类型一致，在接口调用函数式方法后再调用参数的函数式方法。

例如：Function接口的andThen方法实现
```
default <V> Function<T, V> andThen(Function<? super R, ? extends V> after) {
    Objects.requireNonNull(after);
    return (t) -> {
        return after.apply(this.apply(t));
    };
}
```

```
class I {
  @Override
  public String toString() { return "I"; }
}
class O {
  @Override
  public String toString() { return "O"; }
}
public class TransformFunction {
  static Function<I,O> transform(Function<I,O> in) {
    return in.andThen(o -> {
      System.out.println(o);
      return o;
    });
  }
  public static void main(String[] args) {
    Function<I,O> f2 = transform(i -> {
      System.out.println(i);
      return new O();
    });
    O o = f2.apply(new I());
  }
}
```

输出：

```
I
O
```

## 闭包

可以简单理解为使用函数作用域之外的变量的lambda表达式作为方法返回值的类。有时称为词法定界（lexically scoped ）或变量捕获（variable capture）

闭包在实现上是一个结构体，它存储了一个函数（通常是其入口地址）和一个关联的环境（相当于一个符号查找表）。环境里是若干对符号和值的对应关系，它既要包括约束变量（该函数内部绑定的符号），也要包括自由变量（在函数外部定义但在函数内被引用），有些函数也可能没有自由变量。（此处见维基百科——闭包）

正面教材1：

```
public class Closure1 {
  int i;
  IntSupplier makeFun(int x) {
    return () -> x + i++;
  }
}
```

```
public class SharedStorage {
  public static void main(String[] args) {
    Closure1 c1 = new Closure1();
    IntSupplier f1 = c1.makeFun(0);
    IntSupplier f2 = c1.makeFun(0);
    IntSupplier f3 = c1.makeFun(0);
    System.out.println(f1.getAsInt());
    System.out.println(f2.getAsInt());
    System.out.println(f3.getAsInt());
  }
}
```

输出：
```
0
1
2
```

最大特征是，Closure1对象调用makeFun方法产生的三个IntSupplier对象都共享了Closure1的属性i的存储。

正面教材2:

```
public class Closure2 {
  IntSupplier makeFun(int x) {
    int i = 0;
    return () -> x + i;
  }
}
```

makeFun返回的IntSupplier会仍然保持i和x的内存不会消失。一般的方法的局部变量在调用完之后将会消失。

> 这里的变量i是等同final效果，lambda表达式引用的局部变量应该是不可变的，即要使用final修饰，但是Java8引入这个特性，可以省略final，在编译的时候编译器会帮我们自动加上。所以反面教材4，举例语法不正确的情况。

正面教材3:

```
public class Closure3 {
  Supplier<List<Integer>> makeFun() {
    final List<Integer> ai = new ArrayList<>();
    ai.add(1);
    return () -> ai;
  }
  public static void main(String[] args) {
    Closure3 c7 = new Closure3();
    List<Integer>
      l1 = c7.makeFun().get(),
      l2 = c7.makeFun().get();
    System.out.println(l1);
    System.out.println(l2);
    l1.add(42);
    l2.add(96);
    System.out.println(l1);
    System.out.println(l2);
  }
}
```
输出：
```
[1]
[1]
[1, 42]
[1, 96]
```
输出的第三和第四行说明，两个makeFun方法返回的Supplier对象持有的ArrayList对象是各自独立的，而非共享。


反面教材4:

```
public class Closure4 {
  IntSupplier makeFun(int x) {
    int i = 0;
    // x++ 和 i++ 都会报错：
    return () -> x++ + i++;
  }
}
```

或

```
public class Closure5 {
  // {无法编译成功}
  IntSupplier makeFun(int x) {
    int i = 0;
    i++;
    x++;
    return () -> x + i;
  }
}
```

如何解决：

```
public class Closure6 {
  IntSupplier makeFun(int x) {
    int i = 0;
    i++;
    x++;
    final int iFinal = i;
    final int xFinal = x;
    return () -> xFinal + iFinal;
  }
}
```

Java8以前的闭包

```
public class AnonymousClosure {
  IntSupplier makeFun(int x) {
    int i = 0;
    // 同样规则的应用:
    // i++; // 非等同 final 效果
    // x++; // 同上
    return new IntSupplier() {
      public int getAsInt() { return x + i; }
    };
  }
}
```

> 实际上只要有内部类，就会有闭包（Java 8 只是简化了闭包操作）。在 Java 8 之前，变量 x 和 i 必须被明确声明为 final。在 Java 8 中，内部类的规则放宽，包括等同 final 效果。

## 函数组合

在高阶函数时使用Function的andThen方法，就是一个将多个函数组合成新函数的方法。

例如；

|组合方法|支持的接口|解释|
|:-:|:-:|:-:|
|andThen(arg)|Function、Consumer、UnaryOperator、BinaryOperator|先执行操作，再执行参数操作|
|compose(arg)|Function、UnaryOperator、IntUnaryOperator|先执行参数操作，再执行原操作|
|negate()|Predicate|该谓词的逻辑非|
|and(arg)|Predicate|原谓词(Predicate)和参数谓词的短路逻辑与|
|or(arg)|Predicate|原谓词和参数谓词的短路逻辑或|

衍生出来的接口就不列举了

Function调用andThen和compose的例子：

```
public class FunctionComposition {
  static Function<String, String>
    f1 = s -> {
      System.out.println(s);
      return s.replace('A', '_');
    },
    f2 = s -> s.substring(3),
    f3 = s -> s.toLowerCase(),
    f4 = f1.compose(f2).andThen(f3);
  public static void main(String[] args) {
    System.out.println(
      f4.apply("GO AFTER ALL AMBULANCES"));
  }
}
```
输出：

```
AFTER ALL AMBULANCES
_fter _ll _mbul_nces
```

Predicate调用negate、and和or的例子：

```
public class PredicateComposition {
  static Predicate<String>
    p1 = s -> s.contains("bar"),
    p2 = s -> s.length() < 5,
    p3 = s -> s.contains("foo"),
    p4 = p1.negate().and(p2).or(p3);
  public static void main(String[] args) {
    Stream.of("bar", "foobar", "foobaz", "fongopuckey")
      .filter(p4)
      .forEach(System.out::println);
  }
}
```
输出：
```
foobar
foobaz
```

p4等价于`s->!s.contains("bar")&&s.length()<5||s.contains("foo")`

> 这里使用流式编程，对于四个字符串组成的流，使用p4这个断言过滤出为出true的结果，最终再打印出来。

## 柯里化和部分求值

> 柯里化意为：将一个多参数的函数，转换为一系列单参数函数。

例如：

```
public class CurryingAndPartials {
   // 未柯里化:
   static String uncurried(String a, String b) {
      return a + b;
   }
   public static void main(String[] args) {
      // 柯里化的函数:
      Function<String, Function<String, String>> sum =
         a -> b -> a + b; // [1]
      System.out.println(uncurried("Hi ", "Ho"));
      Function<String, String>
        hi = sum.apply("Hi "); // [2]
      System.out.println(hi.apply("Ho"));
      // 部分应用:
      Function<String, String> sumHi =
        sum.apply("Hup ");
      System.out.println(sumHi.apply("Ho"));
      System.out.println(sumHi.apply("Hey"));
   }
}
```

输出：
```
Hi Ho
Hi Ho
Hup Ho
Hup Hey
```

注意接口的声明，第二类型参数是一个Function类型。

可以通过继续添加层级来柯里化一个三参数函数：

```
// functional/Curry3Args.java
import java.util.function.*;
public class Curry3Args {
   public static void main(String[] args) {
      Function<String,
        Function<String,
          Function<String, String>>> sum =
            a -> b -> c -> a + b + c;
      Function<String,
        Function<String, String>> hi =
          sum.apply("Hi ");
      Function<String, String> ho =
        hi.apply("Ho ");
      System.out.println(ho.apply("Hup"));
   }
}
```
输出：
```
Hi Ho Hup
```
再来一个例子
```java
public class CurriedIntAdd {
  public static void main(String[] args) {
    IntFunction<IntUnaryOperator>
      curriedIntAdd = a -> b -> a + b;
    IntUnaryOperator add4 = curriedIntAdd.apply(4);
    System.out.println(add4.applyAsInt(5));
      }
}
```
输出：
```
9
```