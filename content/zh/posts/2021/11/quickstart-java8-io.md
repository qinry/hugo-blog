---
title: "快速开始 Java8 文件IO"
date: 2021-11-04T21:37:57+08:00
description: "快速开始 Java8 文件IO"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- io
categories:
- java
---

## Files和Paths快速使用

演示用的文本：

```txt:~/demo.txt
Hi, I'm qinry!
I am learning java8.
Files and Paths are new untilty classes for input/output.
```
创建demo.txt的符号链接demo.link
```bash
ln -s demo.txt demo.link
```

以上命令在MacOS运行，Windows可通过创建快捷方式，效果类似。

查看三种路径的常用信息：这里所遇到方法，都能见名知意，就不解释了，获取路径的惯用静态方法`Paths.get("demo.txt")`。

重点是toRealPath()和toAbsolutePath()的不同。

{{< codes 相对路径 绝对路径 真实路径 >}}
{{< code >}}
```java
Path path = Paths.get("demo.txt");
System.out.println("toString: " + path); 
System.out.println("Exists: " + Files.exists(path));
System.out.println("RegularFile: " + Files.isRegularFile(path));
System.out.println("Directory: " + Files.isDirectory(path));
System.out.println("Absolute: " + path.isAbsolute());
System.out.println("FileName: " + path.getFileName());
System.out.println("Parent: " + path.getParent()); // [1] 父路径
System.out.println("Root: " + path.getRoot()); // [2 ]根路径
```
{{< /code >}}
{{< code >}}
```java
Path path = Paths.get("demo.txt");
Path absPath = path.toAbsolutePath(); // [1]
System.out.println("toString: " + absPath);
System.out.println("Exists: " + Files.exists(absPath));
System.out.println("RegularFile: " + Files.isRegularFile(absPath));
System.out.println("Directory: " + Files.isDirectory(absPath));
System.out.println("Absolute: " + absPath.isAbsolute());
System.out.println("FileName: " + absPath.getFileName());
System.out.println("Parent: " + absPath.getParent());
System.out.println("Root: " + absPath.getRoot());
```
{{< /code >}}
{{< code >}}
```java
Path path = Paths.get("demo.link"); // [1]
Path realPath = null;
try {
    realPath = path.toRealPath(); // [2]
    System.out.println("toString: " + realPath);
    System.out.println("Exists: " + Files.exists(realPath));
    System.out.println("RegularFile: " + Files.isRegularFile(realPath));
    System.out.println("Directory: " + Files.isDirectory(realPath));
    System.out.println("Absolute: " + realPath.isAbsolute());
    System.out.println("FileName: " + realPath.getFileName());
    System.out.println("Parent: " + realPath.getParent());
    System.out.println("Root: " + realPath.getRoot());
} catch(IOException e) {
    System.out.println(e);
}

```
{{< /code >}}
{{< /codes>}}

输出：
{{< codes 相对路径 绝对路径 真实路径 >}}
{{< code >}}
```txt
toString: demo.txt
Exists: true
RegularFile: true
Directory: false
Absolute: false
FileName: demo.txt
Parent: null
Root: null
```
{{< /code >}}
{{< code >}}
```txt
toString: /Users/qinry/demo.txt
Exists: true
RegularFile: true
Directory: false
Absolute: true
FileName: demo.txt
Parent: /Users/qinry
Root: /
```
{{< /code >}}
{{< code >}}
```txt
toString: /Users/qinry/demo.txt
Exists: true
RegularFile: true
Directory: false
Absolute: true
FileName: demo.txt
Parent: /Users/qinry
Root: /
```
{{< /code >}}
{{< /codes >}}

由于是在MacOS运行，文件系统的根路径是`“/”`


所指的三种路径：

* 相对路径：指相对于当前工作目录的路径，这里工作目录是`/Users/qinry`，所以文件的相对路径为`demo.txt`
* 绝对路径：指相对于根路径的路径，等于工作目录路径加上相对路径，即`/Users/qinry/demo.txt`
* 真实路径：符号链接所指向文件真正路径，如果不是符号链接，就是本身的绝对路径，`demo.link`是`demo.txt`的软链接，它的真实路径是`/Users/qinry/demo.txt`

{{< notice warning >}}
`toRealPath()`方法可以解析符号链接，如果符号链接对应的真实文件不存在时，则会抛出异常。
{{< /notice >}}

## 查看路径的各部分片段

`getNameCount()`获取路径片段的数量。`getName(int)`获取指定的片段

```java
Path p = Paths.get("demo.txt").toAbsolutePath();
System.out.println(p);
for (int i = 0; i < p.getNameCount(); i++) {
    System.out.println(p.getName(i));
}
```

输出：
```txt
/Users/qinry/demo.txt
Users
qinry
demo.txt
```

## 路径分析

其实就是查看文件属性
```java
try {
    System.out.println(System.getProperty("os.name"));
    Path p = Paths.get("demo.txt").toAbsolutePath();
    System.out.println("存在："+Files.exists(p));
    System.out.println("目录："+Files.isDirectory(p));
    System.out.println("可执行："+Files.isExecutable(p));
    System.out.println("可读："+Files.isReadable(p));
    System.out.println("普通文件："+Files.isRegularFile(p));
    System.out.println("可写"+Files.isWritable(p));
    System.out.println("不存在"+Files.notExists(p));
    System.out.println("隐藏："+Files.isHidden(p));
    System.out.println("大小："+Files.size(p));
    System.out.println("文件存储："+Files.getFileStore(p));
    System.out.println("上次修改时间："+Files.getLastModifiedTime(p));
    System.out.println("拥有者："+Files.getOwner(p));
    System.out.println("内容类型："+Files.probeContentType(p));
    System.out.println("符号链接："+Files.isSymbolicLink(p));
    if (Files.isSymbolicLink(p)) {
        System.out.println("符号链接："+Files.readSymbolicLink(p)); // 读取链接的目标
    }
    if (FileSystems.getDefault().supportedFileAttributeViews().contains("posix")) {
        System.out.println("Posix文件权限："+Files.getPosixFilePermissions(p));
    }
} catch(IOException e) {
    System.out.println(e);
}
```

输出：

```txt
Mac OS X
存在：true
目录：false
可执行：false
可读：true
普通文件：true
可写true
不存在false
隐藏：false
大小：94
文件存储：/System/Volumes/Data (/dev/disk2s1)
上次修改时间：2021-11-04T13:50:51.559655Z
拥有者：qinry
内容类型：text/plain
符号链接：false
Posix文件权限：[OWNER_READ, GROUP_READ, OTHERS_READ, OWNER_WRITE]
```

## 路径的增删修改

`resolve()`添加尾路径，`normalize()`可以去除冗余的路径片段。
```java
Path base = Paths.get(".").toAbsolutePath().normalize();
Path p = base.resolve("files").resolve("demo.txt");
System.out.println(p);
```

输出：
```txt
/Users/qinry/files/demo.txt
```

`"."`表示当前的工作目录，`".."`表示当前的工作目录的父路目录

`relativize(()`去除基部路径

```java
Path base = Paths.get("files");
Path p = Paths.get("files/demo.txt");
System.out.println(base.relativize(p));
```

输出：
```txt
demo.txt
```

## 目录和文件增删

### 删除目录和文件

假如工作目录下有目录`test`，删除目录有两个方法：`delete(path)`和`deleteIfExists(path)`。第一个如果路径不存在这个目录，则抛出异常；第二个只有存在该路径才删除

{{< codes delete deleteIfExists >}}
{{< code >}}
```java
Path dir = Paths.get("test");
try {
    Files.delete(dir);
} catch(IOException) {
    e.printStackTrace();
}
```
{{< /code >}}

{{< code >}}
```java
Path dir = Paths.get("test");
try {
    Files.deleteIfExists(dir);
} catch(IOException) {
    e.printStackTrace();
}
```
{{< /code >}}
{{< /codes >}}


文件删除与目录同理。把路径该为文件的路径即可
比如：
```java
Path file = Paths.get("readme.txt");
try {
    Files.deleteIfExists(file);
} catch(IOException) {
    e.printStackTrack();
}
```

{{< notice warning >}}
如果目录的内容不为空，则删除目录是会抛出异常的。意味着Java标准库没有删除目录树的方法，需要自己实现。见下！
{{< /notice >}}

```java
public static void rmdir(Path dir) throws IOException {
    Files.walkFileTree(dir, new SimpleFileVisitor<Path>(){
        @Override
        public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
            Files.delete(file);
            return FileVisitResult.CONTINUE;
        }
        @Override
        public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
            Files.delete(dir);
            return FileVisitResult.CONTINUE;
        }
    });
}
```

`Files.walkFileTree`访问目录下的文件树，即遍历该目录下所有的文件及其子目录。在遍历过程中，提供一个访问者的机制对访问的文件和目录执行操作。

`FileVistor`有四个抽象方法：
* `preVisitDirectory()`：在访问目录项之前运行
* `visitFile()`：访问文件时运行
* `visitFileFailed()`：访问文件失败时运行
* `postVisitDirectory`：访问目录项后运行

### 创建目录和文件

要在工作目录下创建目录：
```java
Path dir = Paths.get("test","a");
try {
    //Files.createDirectory(dir);
    Files.createDirectories(dir);
} catch(Exception e) {
    System.out.println("不能正常工作");
}
```
createDirectory(dir)不能创建多级目录，只可单级目录，故会抛出异常；createDirectories(dir)可以创建完整的目录。

创建文件：

```java
Path dir = Paths.get("test");
Path file = dir.resolve("hello.txt");
try {
    if (Files.exists(dir)) {
        Files.delete(dir);
    }
    if (!Files.exists(dir)) {
        Files.createDirectory(dir);
    }
    Files.createFile(file);
} catch(IOException e) {
    e.printStackTrace();
}
```

### 创建临时的文件和目录

```java
Path test = Paths.get("test");
try {
    if (Files.exists(test)) {
        Files.delete(test);
    }
    if (!Files.exists(test)) {
        Files.createDirectory(test);
    }
    Path tempDir = Files.createTempDirectory(test, "DIR_");
    Files.createTempFile(tempDir, "pre", ".non");
} catch(IOException e) {
    e.printStackTrace();
}
```

创建前缀为`DIR_`的临时目录，创建前缀为`pre`，后缀为`.non`的临时文件。

## 文件系统

查看文件系统相关信息：

```java
 System.out.println(System.getProperty("os.name"));
FileSystem fsys = FileSystems.getDefault();
for (FileStore fileStore : fsys.getFileStores()) {
    System.out.println("File Store:"+fileStore);
}
for (Path rd : fsys.getRootDirectories()) {
    System.out.println("Root Directory:"+rd);
}
System.out.println("Separator:"+fsys.getSeparator());
System.out.println("UserPrincipalLookupService:"+fsys.getUserPrincipalLookupService());
System.out.println("isOpen:"+fsys.isOpen());
System.out.println("isReadOnly:"+fsys.isReadOnly());
System.out.println("FileSystemProvider:"+fsys.provider());
System.out.println("File Attribute Views:"+fsys.supportedFileAttributeViews());
```

输出：
```txt
Mac OS X
File Store:/ (/dev/disk2s5)
File Store:/dev (devfs)
File Store:/System/Volumes/Data (/dev/disk2s1)
File Store:/private/var/vm (/dev/disk2s4)
File Store:/System/Volumes/Data/home (map auto_home)
File Store:/Volumes/share (/dev/disk0s1)
Root Directory:/
Separator:/
UserPrincipalLookupService:sun.nio.fs.UnixFileSystem$LookupService$1@7852e922
isOpen:true
isReadOnly:false
FileSystemProvider:sun.nio.fs.MacOSXFileSystemProvider@4e25154f
File Attribute Views:[owner, basic, posix, unix]
```

## 文件查找

```
Path dir = Paths.get("test");
PathMatcher matcher = FileSystems.getDefault().getPathMatcher("glob:**/*.{tmp,txt}");
try {
    Files.walk(dir)
            .filter(matcher::matches)
            .forEach(System.out::println);
} catch (IOException e) {
    e.printStackTrace();
}
```

`Files.walk(dir)`获取目录树的全部内容的流。通过在 `FileSystem` 对象上调用 `getPathMatcher()` 获得一个 `PathMatcher`，然后传入您感兴趣的模式。这里使用glob，简化正则表达式的一种匹配模式。`**`表示“当前目录及所有子目录”不包含`.`和`..`开头的，`*`代表除了分割符的任意字符。`{}`表示一系列的可能性。这里表示可能使 `tmp` 结尾 或 `txt`

## 文件读写

### 读文件

`Files.readAllLines(path)`得到所有行组成的字符串列表。可以创建为流进行操作：

```txt:cheese.txt
// cheese.txt
Not much of a cheese shop really, is it?
Finest in the district, sir.
And what leads you to that conclusion?
Well, it's so clean.
It's certainly uncontaminated by cheese.
```
```java
try {
    Files.readAllLines(
                    Paths.get("cheese.txt"))
            .stream()
            .filter(s -> !s.startsWith("//"))
            .forEach(System.out::println);
} catch (IOException e) {
    e.printStackTrace();
}
```
输出：
```txt
Not much of a cheese shop really, is it?
Finest in the district, sir.
And what leads you to that conclusion?
Well, it's so clean.
It's certainly uncontaminated by cheese.
```

### 写文件

`Files.write(path, bytes)`或`Files.write(path, lines)`。写完文件可写入byte数组或String列表的内容。
{{< codes bytes lines>}}
{{< code >}}
```java
Path path = Paths.get("bytes.dat");
byte[] bytes = new byte[1024];
new Random(47).nextBytes(bytes);
try {
    Files.write(path, bytes);
    System.out.println("bytes.dat: " + Files.size(path));
} catch (IOException e) {
    e.printStackTrace();
}
```
{{< /code >}}
{{< code >}}
```java
Path path = Paths.get("cheese.txt");
try {
    List<String> lines = Files.lines(path).filter(s -> !s.startsWith("//")).collect(Collectors.toList());
    Files.write(Paths.get("hello.txt"), lines);
} catch (IOException e) {
    e.printStackTrace();
}
```
{{< /code >}}
{{< /codes >}}

## 路径监听

```java
public class TreeWatcher {
    static void watchDir(Path dir) {
        try {
            WatchService watcher =
            FileSystems.getDefault().newWatchService();
            dir.register(watcher, ENTRY_DELETE);
            Executors.newSingleThreadExecutor().submit(() -> {
                try {
                    WatchKey key = watcher.take();
                    for(WatchEvent evt : key.pollEvents()) {
                        System.out.println(
                        "evt.context(): " + evt.context() +
                        "\nevt.count(): " + evt.count() +
                        "\nevt.kind(): " + evt.kind());
                        System.exit(0);
                    }
                } catch(InterruptedException e) {
                    return;
                }
            });
        } catch(IOException e) {
            throw new RuntimeException(e);
        }
    }
    public static void main(String[] args) {
       try {
            Files.walk(Paths.get("test"))
                    .filter(Files::isDirectory)
                    .forEach(TreeWatcher::watchDir);
            
            Files.walk(Paths.get("test"))
                    .filter(f ->
                            f.toString()
                                    .endsWith(".txt"))
                    .forEach(f -> {
                        try {
                            System.out.println("deleting " + f);
                            Files.delete(f);
                        } catch(IOException e) {
                            throw new RuntimeException(e);
                        }
                    });
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

在 watchDir() 方法中给 WatchSevice 提供参数 ENTRY_DELETE，并启动一个独立的线程来监视该WatchService。这里是监听删除事件。还有其他的：ENTRY_CREATE，ENTRY_MODIFY(其中创建和删除不属于修改)。