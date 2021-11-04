---
title: "快速开始Java8流式编程"
date: 2021-11-02T11:01:21+08:00
description: "快速开始Java8流式编程"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
categories:
- java
---

## 流是什么
流（Streams）是与任何特定存储机制无关的元素序列——实际上，我们说流是 “没有存储 “的。

> 集合优化了对象的存储，而流（Streams）则是关于一组组对象的处理。

取代了在集合中迭代元素的做法，使用流即可从管道中提取元素并对其操作。这些管道通常被串联在一起形成一整套的管线，来对流进行操作,它使得程序更加短小并且更易理解。

## 快速开始的入门示例

```java
public class Randoms {
    public static void main(String[] args) {
        new Random(47)
            .ints(5, 20) // 流的创建
            .distinct() // 3个中间操作
            .limit(7)
            .sorted()
            .forEach(System.out::println); // 终结操作
    }
}
```

5到20的随机数不重复，限制7个后排序，再打印输出。

> 这里只描述了流的行为，并未明确指明具体的操作。这是声明式编程风格，而非命令式编程风格，语义更加清晰，语法更加简洁。

> 流有一个重要特征，就是懒加载，只有在必要时进行计算，又称惰性求值。由于计算延迟，流使我们能够表示非常大（甚至无限）的序列，而不需要考虑内存问题。

将上方的声明式编程风格的代码用命令式编程风格重写如下：

```java
public class Randoms {
    public static void main(String[] args) {
        Random rand = new Random(47);
        SortedSet<Integer> rints = new TreeSet<>(); // distinct sorted
        while(rints.size() < 7) { // limit
            int r = rand.nextInt(20); // < 20
            if(r < 5) continue; // >= 5
            rints.add(r);
        }
        System.out.println(rints);
    }
}
```

流式编程有三个部分：流创建、中间操作、终端操作。中间操作可以更改流，终端操作会等到某种结果。

## 流的创建

* 流的简单工厂（of/stream）
* 随机数流
* int类型的范围（range/rangeClosed）
* 生成（generate）
* 迭代（iterate）
* 流的建造者（builder）
* 数组转换流 （stream）
* 正则表达式（splitAsStream）

### 流的简单工厂

#### of方法

Stream.of有两个重载方法，一个是单参数的，另一个是可变参数，参数类型是泛型。
```java
Stream.of("a", "b", "c");
Stream.of(1, 2, 3, 4,);
```

泛型的重载方法，实际委托给Arrays.stream方法来创建流

```java
@SafeVarargs
@SuppressWarnings("varargs") // Creating a stream from an array is safe
public static<T> Stream<T> of(T... values) {
    return Arrays.stream(values);
}
```

### stream方法

Collection接口默认实现了stream方法来创建，这个方法实际工作最终委托给StreamSupport这个底层工具类来完成。Arrays.stream方法与Stream.of单参数版本也是如此。

```java
default Stream<E> stream() {
    return StreamSupport.stream(spliterator(), false);
}
```

Java的集合框架中实现Collection及其子接口的类都可以使用stream方法创建流
```java
List<String> list = new ArrayList<>();
list.add("a");
list.add("b");
list.add("c");
list.stream();
Map<String, String> map = new HashMap<>();
map.put("a", "apple");
map.put("b", "banana");
map.put("c", "cookie");
map.entrySet().stream();
```

### 随机数流

ints、longs和doubles得到是原始数据类型的流，boxed将原始数据类型转化为包装类型流。

```java
public class RandomGenerators {
    public static <T> void show(Stream<T> stream) {
        stream
        .limit(4)
        .forEach(System.out::println);
        System.out.println("++++++++");
    }
    public static void main(String[] args) {
        Random rand = new Random(47);
        show(rand.ints().boxed());
        show(rand.longs().boxed());
        show(rand.doubles().boxed());
        // 控制上限和下限：
        show(rand.ints(10, 20).boxed());
        show(rand.longs(50, 100).boxed());
        show(rand.doubles(20, 30).boxed());
        // 控制流大小：
        show(rand.ints(2).boxed());
        show(rand.longs(2).boxed());
        show(rand.doubles(2).boxed());
        // 控制流的大小和界限
        show(rand.ints(3, 3, 9).boxed());
        show(rand.longs(3, 12, 22).boxed());
        show(rand.doubles(3, 11.5, 12.3).boxed());
    }
}
```

输出：
```txt
-1172028779
1717241110
-2014573909
229403722
++++++++
2955289354441303771
3476817843704654257
-8917117694134521474
4941259272818818752
++++++++
0.2613610344283964
0.0508673570556899
0.8037155449603999
0.7620665811558285
++++++++
16
10
11
12
++++++++
65
99
54
58
++++++++
29.86777681078574
24.83968447804611
20.09247112332014
24.046793846338723
++++++++
1169976606
1947946283
++++++++
2970202997824602425
-2325326920272830366
++++++++
0.7024254510631527
0.6648552384607359
++++++++
6
7
7
++++++++
17
12
20
++++++++
12.27872414236691
11.732085449736195
12.196509449817267
++++++++
```

### 流的生成

Stream.generate方法的方法签名，接受一个Supplier类型。

```java
public static<T> Stream<T> generate(Supplier<T> s) {
    Objects.requireNonNull(s);
    return StreamSupport.stream(
            new StreamSpliterators.InfiniteSupplyingSpliterator.OfRef<>(Long.MAX_VALUE, s), false);
}
```

可以实现Supplier接口，传入generate方法，也可以使用lambda表达式以及方法引用形式
```java
public class Generator implements Supplier<String> {
    Random rand = new Random(47);
    char[] letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
    public String get() {
        return "" + letters[rand.nextInt(letters.length)];
    }
    public static void main(String[] args) {
        String word = Stream.generate(new Generator())
                            .limit(30)
                            .collect(Collectors.joining());
        System.out.println(word);
    }
}
```

输出：
```txt
YNZBRNYGCFOWZNTCQRGSEGZMMJMROE
```

### 流的迭代

Stream.iterate的方法签名，接受一个泛型种子（初始值），还有一个UnaryOperator类型

```java
public static<T> Stream<T> iterate(final T seed, final UnaryOperator<T> f) {
    Objects.requireNonNull(f);
    final Iterator<T> iterator = new Iterator<T>() {
        @SuppressWarnings("unchecked")
        T t = (T) Streams.NONE;

        @Override
        public boolean hasNext() {
            return true;
        }

        @Override
        public T next() {
            return t = (t == Streams.NONE) ? seed : f.apply(t);
        }
    };
    return StreamSupport.stream(Spliterators.spliteratorUnknownSize(
            iterator,
            Spliterator.ORDERED | Spliterator.IMMUTABLE), false);
}
```


与generate类似，可以实现接口，或者使用函数式编程来传入第二参数。
```java
public class Fibonacci {
    int x = 1;
    Stream<Integer> numbers() {
        return Stream.iterate(0, i -> {
            int result = x + i;
            x = i;
            return result;
        });
    }
    public static void main(String[] args) {
        new Fibonacci().numbers()
                       .skip(20) // 过滤前 20 个
                       .limit(10) // 然后取 10 个
                       .forEach(System.out::println);
    }
}
```
输出：
```txt
6765
10946
17711
28657
46368
75025
121393
196418
317811
514229
```

### 流的建造者

Stream.builder方法的返回值是一个Builder类型，实际上是Streams.StreamBuilderImpl对象
```java
public static<T> Builder<T> builder() {
    return new Streams.StreamBuilderImpl<>();
}
```

Streams.StreamBuilderImpl有两个重要的方法一个是add，还有一个是build。add用来链式添加流中的元素，build则是完成构建流。
```java
static final class StreamBuilderImpl<T>
            extends AbstractStreamBuilderImpl<T, Spliterator<T>>
            implements Stream.Builder<T> {
    public Stream.Builder<T> add(T t) {
        accept(t);
        return this;
    }
    @Override
    public Stream<T> build() {
        int c = count;
        if (c >= 0) {
            // Switch count to negative value signalling the builder is built
            count = -count - 1;
            // Use this spliterator if 0 or 1 elements, otherwise use
            // the spliterator of the spined buffer
            return (c < 2) ? StreamSupport.stream(this, false) : StreamSupport.stream(buffer.spliterator(), false);
        }

        throw new IllegalStateException();
    }
}
```

add委托给accpet方法将元素添加到buffer中
```java
// The first element in the stream
// valid if count == 1
T first;

// The first and subsequent elements in the stream
// non-null if count == 2
SpinedBuffer<T> buffer;


@Override
public void accept(T t) {
    if (count == 0) {
        first = t;
        count++;
    }
    else if (count > 0) {
        if (buffer == null) {
            buffer = new SpinedBuffer<>();
            buffer.accept(first);
            count++;
        }

        buffer.accept(t);
    }
    else {
        throw new IllegalStateException();
    }
}
```

一旦调用build后，count会变成负数，再调用add/accept方法，就会抛出IllegalStateException。所以，Stream.Builder调用builder()后不可再添加元素。

```java
Stream.Builder<String> builder = Stream.builder();
Stream<String> stream = builder.add("I").add("Love").add("Java8").build();
```

### 数组转换成流

```java
String[] stringArray = new String[4];
stringArray[0] = "I";
stringArray[1] = "Love";
stringArray[2] = "Java";
stringArray[3] = "!";
Arrays.stream(stringArray).forEach(System.out::println);    
```

输出：

```txt
I
Love
Java
!
```


stream()的调用有两个额外的参数。第一个参数告诉 stream() 从数组的哪个位置开始选择元素，第二个参数用于告知在哪里停止（不包含）。

```java
Arrays.stream(new double[] { 3.14159, 2.718, 1.618 })
            .forEach(n -> System.out.format("%f ", n));
System.out.println();
Arrays.stream(new int[] { 1, 3, 5 })
    .forEach(n -> System.out.format("%d ", n));
System.out.println();
Arrays.stream(new long[] { 11, 22, 44, 66 })
    .forEach(n -> System.out.format("%d ", n));
System.out.println();
// 选择一个子域:
Arrays.stream(new int[] { 1, 3, 5, 7, 15, 28, 37 }, 3, 6)
    .forEach(n -> System.out.format("%d ", n));
```

输出：
```txt
3.141590 2.718000 1.618000
1 3 5
11 22 44 66
7 15 28
```

### 正则表达式

Java 8 在 java.util.regex.Pattern 中增加了一个新的方法 splitAsStream()。这个方法可以根据传入的公式将字符序列转化为流。但是有一个限制，输入只能是 CharSequence，因此不能将流作为 splitAsStream() 的参数。

cheese.txt文件内容：

```txt
// cheese.txt
Not much of a cheese shop really, is it?
Finest in the district, sir.
And what leads you to that conclusion?
Well, it's so clean.
It's certainly uncontaminated by cheese.
```

读取cheese.txt文件的每一行，然后跳过第一行，每一行用空格连接成一个字符串。接着使用正则表达式将字符串转化为单词流。
```java
public class FileToWordsRegexp {
    private String all;
    public FileToWordsRegexp(String filePath) throws Exception {
        all = Files.lines(Paths.get(filePath))
        .skip(1) // First (comment) line
        .collect(Collectors.joining(" "));
    }
    public Stream<String> stream() {
        return Pattern
        .compile("[ .,?]+").splitAsStream(all);
    }
    public static void
    main(String[] args) throws Exception {
        FileToWordsRegexp fw = new FileToWordsRegexp("Cheese.txt");
        fw.stream()
          .limit(7)
          .map(w -> w + " ")
          .forEach(System.out::print);
        fw.stream()
          .skip(7)
          .limit(2)
          .map(w -> w + " ")
          .forEach(System.out::print);
    }
}
```

输出：
```txt
Not much of a cheese shop really is it
```

## 中间操作

* 帮助调试（peek）
* 给流排序（sorted）
* 去除元素（distinct/filter）
* 映射（map/flatmap）

### 帮助调试

peek()它允许你无修改地查看流中的元素。

```java
Stream<String> stream = Files.lines(Paths.get("cheese.txt")).skip(1).flatMap(line -> Pattern.compile("\\W+").splitAsStream(line));
stream.skip(21)
    .limit(4)
    .map(w -> w+" ")
    .peek(System.out::print)
    .map(String::toUpperCase)
    .peek(System.out::print)
    .map(String::toLowerCase)
    .forEach(System.out::print);
```

输出：
```txt
Well WELL well it IT it s S s so SO so
```

### 元素排序


sorted() 预设了一些默认的比较器。但也可以自提供比较器

```java
Stream<String> stream = Files.lines(Paths.get("cheese.txt")).skip(1).flatMap(line -> Pattern.compile("\\W+").splitAsStream(line));
stream.skip(10)
        .limit(10)
        .sorted(Comparator.reverseOrder())
        .map(w -> w + " ")
        .forEach(System.out::print);
```

输出：
```txt
you what to the that sir leads in district And
```

### 去除元素

* distinct():distinct() 可用于消除流中的重复元素。

* filter(Predicate):过滤操作，保留如下元素：若元素传递给过滤函数产生的结果为true 。

```java
Stream.iterate(2, i -> i + 1)
    .filter(n -> LongStream.rangeClosed(2, (long)Math.sqrt(n)).noneMatch(i -> n % i == 0))
    .limit(10)
    .forEach(n -> System.out.format("%d ", n));
System.out.println();
Stream.iterate(2, i -> i + 1)
    .filter(n -> LongStream.rangeClosed(2, (long)Math.sqrt(n)).noneMatch(i -> n % i == 0))
    .skip(90)
    .limit(10)
    .forEach(n -> System.out.format("%d ", n));
```

输出：

```txt
2 3 5 7 11 13 17 19 23 29
467 479 487 491 499 503 509 521 523 541
```

### 映射

* map(Function)：将函数操作应用在输入流的元素中，并将返回值传递到输出流中。

* mapToInt(ToIntFunction)：操作同上，但结果是 IntStream。

* mapToLong(ToLongFunction)：操作同上，但结果是 LongStream。

* mapToDouble(ToDoubleFunction)：操作同上，但结果是 DoubleStream。


```java
System.out.println("add brackets");
Arrays.stream(new String[]{"12", "", "23", "45"})
    .map( s -> "[" + s + "]")
    .forEach(System.out::println);

System.out.println("Increment");
Arrays.stream(new String[]{"12", "", "23", "45"})
    .map( s -> {
            try {
                return Integer.parseInt(s) + 1 + "";
            }
            catch(NumberFormatException e) {
                return s;
            }
        })
    .forEach(System.out::println);

System.out.println("Replace");
Arrays.stream(new String[]{"12", "", "23", "45"})
    .map( s -> s.replace("2", "9"))
    .forEach(System.out::println);

System.out.println("Take last digit");
Arrays.stream(new String[]{"12", "", "23", "45"})
    .map( s -> s.length() > 0 ?
        s.charAt(s.length() - 1) + "" : s)
    .forEach(System.out::println);
```
输出：
```txt
add brackets
[12]
[]
[23]
[45]
Increment
13

24
46
Replace
19

93
45
Take last digit
2

3
5
```

如果Function的返回值类型是Stream类型时使用。flatMap() 做了两件事：将产生流的函数应用在每个元素上（与 map() 所做的相同），然后将每个流都扁平化为元素，因而最终产生的仅仅是元素。

* flatMap(Function)：当 Function 产生流时使用。

* flatMapToInt(Function)：当 Function 产生 IntStream 时使用。

* flatMapToLong(Function)：当 Function 产生 LongStream 时使用。

* flatMapToDouble(Function)：当 Function 产生 DoubleStream 时使用。

```java
Stream.of(1, 2, 3)
        .flatMap(i -> Stream.of("Gonzo", "Fozzie", "Beaker"))
        .forEach(System.out::println);
```

输出：
```txt
Gonzo
Fozzie
Beaker
Gonzo
Fozzie
Beaker
Gonzo
Fozzie
Beaker
```

## Optional类

以下几种流的终端操作的方法返回值类型为Optional对象，所以要了解Optional对象的使用。

* findFirst() 返回一个包含第一个元素的 Optional 对象，如果流为空则返回 Optional.empty
* findAny() 返回包含任意元素的 Optional 对象，如果流为空则返回 Optional.empty
* max()和mix() 返回一个包含最大值或者最小值的 Optional 对象，如果流为空则返回 Optional.empty
* reduce(BinaryOperator) 返回包含调用BinaryOperator的apply方法结果的Optional对象。
* 对于数字流 IntStream、LongStream 和 DoubleStream，average() 会将结果包装在 Optional 以防止流为空。


注意，空流是通过 Stream.<String>empty() 创建的。

```java
 System.out.println(Stream.<String>empty()
         .findFirst());
System.out.println(Stream.<String>empty()
        .findAny());
System.out.println(Stream.<String>empty()
        .max(String.CASE_INSENSITIVE_ORDER));
System.out.println(Stream.<String>empty()
        .min(String.CASE_INSENSITIVE_ORDER));
System.out.println(Stream.<String>empty()
        .reduce((s1, s2) -> s1 + s2));
System.out.println(IntStream.empty()
        .average());
```
输出：

```txt
Optional.empty
Optional.empty
Optional.empty
Optional.empty
Optional.empty
OptionalDouble.empty
```

### Optional基本用法

```txt
// opt是Optional对象
if (opt.isPresent()) {
    // 如果不为空进行的行为
} else {
    // 如果为空进行的行为
}
```

有许多便利函数可以解包 Optional ，这简化了上述“对所包含的对象的检查和执行操作”的过程：
* ifPresent(Consumer)：当值存在时调用 Consumer，否则什么也不做。
* orElse(otherObject)：如果值存在则直接返回，否则生成 otherObject。
* orElseGet(Supplier)：如果值存在则直接返回，否则使用 Supplier 函数生成一个可替代对象。
* orElseThrow(Supplier)：如果值存在直接返回，否则使用 Supplier 函数生成一个异常。

```
Optional<String> opt = Optional.ofNullable("Hello Optional");
opt.ifPresent(System.out::println);
opt = Optional.ofNullable(null);
System.out.println(opt.orElse("Hello"));
System.out.println(opt.orElseGet(() -> "Hello"));
try {
    opt.orElseThrow(() -> new Exception("Supplied"));
} catch(Exception e) {
   System.out.println("Caught "+e);
}
```

输出：
```txt
Hello Optional
Hello
Hello
Caught java.lang.Exception: Supplied
```

Optional的创建方法：

* empty() 生成一个空 Optional。
* of(value) 将一个非空值包装到 Optional 里。
* ofNullable(value) 针对一个可能为空的值，为空时自动生成 Optional.empty，否则将值包装在 Optional 中。

Optional对象操作：

* filter(Predicate)：对 Optional 中的内容应用Predicate 并将结果返回。如果 Optional 不满足 Predicate ，将 Optional 转化为空 Optional 。如果 Optional 已经为空，则直接返回空Optional 。

* map(Function)：如果 Optional 不为空，应用 Function 于 Optional 中的内容，并返回结果。否则直接返回 Optional.empty。

* flatMap(Function)：同 map()，但是提供的映射函数将结果包装在 Optional 对象中，因此 flatMap() 不会在最后进行任何包装。

```java
String[] elements = {
    "Foo", "", "Bar", "Baz", "Bingo"
};
System.out.println("true");
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().filter(str -> true));      
});

System.out.println("false");
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().filter(str -> false));      
});

System.out.println("str != \"\"");
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().filter(str -> str != ""));      
});

System.out.println("str.length() == 3");
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().filter(str -> str.length() == 3));      
});

System.out.println("startsWith(\"B\")");
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().filter(str -> str.startsWith("B")));      
});
```

输出：
```txt
true
Optional[Foo]
Optional[]
Optional[Bar]
Optional[Baz]
Optional[Bingo]
Optional.empty
false
Optional.empty
Optional.empty
Optional.empty
Optional.empty
Optional.empty
Optional.empty
str != ""
Optional[Foo]
Optional.empty
Optional[Bar]
Optional[Baz]
Optional[Bingo]
Optional.empty
str.length() == 3
Optional[Foo]
Optional.empty
Optional[Bar]
Optional[Baz]
Optional.empty
Optional.empty
startsWith("B")
Optional.empty
Optional.empty
Optional[Bar]
Optional[Baz]
Optional[Bingo]
Optional.empty
```

map()
```java
String[] elements = {
    "Foo", "", "Bar", "Baz", "Bingo"
};
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().map(s -> "["+s+"]"));      
});
```

输出：
```txt
Optional[[Foo]]
Optional[[]]
Optional[[Bar]]
Optional[[Baz]]
Optional[[Bingo]]
Optional.empty
```

flatMap()
```java
String[] elements = {
    "Foo", "", "Bar", "Baz", "Bingo"
};
IntStream.rangeClosed(0, elements.length).forEach(i -> {
    System.out.println(Arrays.stream(elements).skip(i).findFirst().flatMap(s -> Optional.of("["+s+"]")));      
});
```

## 终端操作

终端操作可以等到结果：
* 数组
* 循环
* 集合
* 组合
* 匹配
* 查找
* 信息
* 数字流信息

### 数组

* toArray()：将流转换成适当类型的数组。
* toArray(generator)：在特殊情况下，生成自定义类型的数组。 例如：toArray(Person[]::new)

```java
int[] arr = new Random(48).ints(0, 1000).limit(10).toArray();
System.out.println(Arrays.toString(arr));
```

输出：

```txt
[368, 316, 831, 244, 877, 911, 522, 100, 987, 794]
```

### 循环

* forEach(Consumer)常见如 System.out::println 作为 Consumer 函数。
* forEachOrdered(Consumer)： 保证 forEach 按照原始流顺序操作。

```java
Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .limit(14).forEach(n -> System.out.format("%d ", n));
Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .limit(14).parallel().forEach(n -> System.out.format("%d ", n));
Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .limit(14).parallel().forEachOrdered(n -> System.out.format("%d ", n));
```
输出：
```txt
258 555 693 861 961 429 868 200 522 207 288 128 551 589 
551 589 200 522 868 288 128 207 555 693 258 861 961 429
258 555 693 861 961 429 868 200 522 207 288 128 551 589
```

对于并行流，forEach是无序的，forEachOrder确保有序

### 集合

* collect(Collector)：使用 Collector 收集流元素到结果集合中。
* collect(Supplier, BiConsumer, BiConsumer)：同上，第一个参数 Supplier 创建了一个新的结果集合，第二个参数 BiConsumer 将下一个元素收集到结果集合中，第三个参数 BiConsumer 用于将两个结果集合合并起来。

```txt
Set<String> words = Files.lines(Paths.get("cheese.txt"))
    .flatMap(s -> Pattern.compile("\\W+").splitAsStream(s))
    .filter(s -> !s.matches("\\d+"))
    .map(String::trim)
    .filter(s -> s.length() > 2)
    .limit(100)
    .collect(Collectors.toCollection(TreeSet::new));
System.out.println(words);
```

输出：
```txt
[And, Finest, Not, Well, certainly, cheese, clean, conclusion, 
district, leads, much, really, shop, sir, that, the, txt, uncontaminated, what, you]
```

### 组合

reduce(BinaryOperator)：使用 BinaryOperator 来组合所有流中的元素。因为流可能为空，其返回值为 Optional。
reduce(identity, BinaryOperator)：功能同上，但是使用 identity 作为其组合的初始值。因此如果流为空，identity 就是结果。

```java
IntStream.rangeClosed(0, 100).reduce((s1,s2) -> s1 + s2).ifPresent(System.out::println);
```

输出：
```txt
5050
```

### 匹配

* allMatch(Predicate) ：如果流的每个元素提供给 Predicate 都返回 true ，结果返回为 true。在第一个 false 时，则停止执行计算。
* anyMatch(Predicate)：如果流的任意一个元素提供给 Predicate 返回 true ，结果返回为 true。在第一个 true 是停止执行计算。
* noneMatch(Predicate)：如果流的每个元素提供给 Predicate 都返回 false 时，结果返回为 true。在第一个 true 时停止执行计算。

```java
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).allMatch(n -> n < 10));
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).allMatch(n -> n < 4));
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).anyMatch(n -> n < 2));
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).anyMatch(n -> n < 0));
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).noneMatch(n -> n < 5));
System.out.println(IntStream.rangeClosed(1, 9).boxed().peek(n -> System.out.format("%d ", n)).noneMatch(n -> n < 0));
```

输出：
```txt
1 2 3 4 5 6 7 8 9 true
1 2 3 4 false
1 true
1 2 3 4 5 6 7 8 9 false
1 false
1 2 3 4 5 6 7 8 9 true
```

### 查找

* findFirst()：返回第一个流元素的 Optional，如果流为空返回 Optional.empty。
* findAny(：返回含有任意流元素的 Optional，如果流为空返回 Optional.empty。

```java
System.out.println(
    Arrays.stream(new Random(47).ints(0, 1000)
    .limit(100).toArray()).findFirst().getAsInt());
System.out.println(
    Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .parallel().findFirst().getAsInt());
System.out.println(
    Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .findAny().getAsInt());
System.out.println(
    Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .parallel().findAny().getAsInt());
```

输出：
```txt
258
258
258
402
```

### 信息

* count()：流中的元素个数。
* max(Comparator)：根据所传入的 Comparator 所决定的“最大”元素。
* min(Comparator)：根据所传入的 Comparator 所决定的“最小”元素。

```java
System.out.println(
    Files.lines(Paths.get("Cheese.txt")).skip(1).flatMap(s -> Pattern.compile("\\W+").splitAsStream(s))
    .count());
System.out.println(
    Files.lines(Paths.get("Cheese.txt")).skip(1).flatMap(s -> Pattern.compile("\\W+").splitAsStream(s))
        .min(String.CASE_INSENSITIVE_ORDER)
        .orElse("NONE"));
System.out.println(
    Files.lines(Paths.get("Cheese.txt")).skip(1).flatMap(s -> Pattern.compile("\\W+").splitAsStream(s))
        .max(String.CASE_INSENSITIVE_ORDER)
        .orElse("NONE"));
```
输出：
```txt
32
a
you
```

### 数字流信息

* average() ：求取流元素平均值。
* max() 和 min()：数值流操作无需 Comparator。
* sum()：对所有流元素进行求和。
* summaryStatistics()：生成可能有用的数据。目前并不太清楚这个方法存在的必要性，因为我们其实可以用更直接的方法获得需要的数据。

```java
System.out.println(Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .average().getAsDouble());
System.out.println(Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .max().getAsInt());
System.out.println(Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .min().getAsInt());
System.out.println(Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .sum());
System.out.println(Arrays.stream(new Random(47).ints(0, 1000).limit(100).toArray())
    .summaryStatistics());
```
输出：
```txt
507.94
998
8
50794
IntSummaryStatistics{count=100, sum=50794, min=8, average=507.940000, max=998}
```

上例操作对于 LongStream 和 DoubleStream 同样适用