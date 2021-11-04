---
title: "Java 压缩文件的IO流"
date: 2020-04-28T14:50:00+08:00
description: "压缩和解压文件的IO"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- jar
- zip
- io
categories:
- java
---

Java I/O库提供压缩功能输入、输出流，这些类是按字节方式处理，常用的压缩类有DeflaterOutputStream和它的子类ZipOutputStream、GZIPOutputStream、CheckedOutputStream，这些是用于压缩的，相应地，有解压的的InflaterInputStream和它的子类ZipInputStrea、GZIPInputStream、CheckedInputStream。

## 对单个数据流进行压缩

GZIP接口简单，一般用于单个数据流的压缩,用例如下:

```java
import java.util.zip.*; // 导入压缩格式的数据流类
import java.io.*;

public class GZIPcompress {
    public static void main(String[] args)
    throws IOException {
        if(args.length == 0) {
            System.out.println(
            "Usage: \nGZIPcompress file\n" +
            "\tUses GZIP compression to compress " +
            "the file to test.gz");
            System.exit(1);
        }
        // 读取要压缩的文件数据
        BufferedReader in = new BufferedReader(
        new FileReader(args[0]));
        // 创建压缩文件
        BufferedOutputStream out = new BufferedOutputStream(
            new GZIPOutputStream(
                new FileOutputStream("test.gz")));

        System.out.println("Writing file");
        int c;
        while((c = in.read()) != -1)
            out.write(c);
        in.close();
        out.close();

        System.out.println("Reading file");
        BufferedReader in2 = new BufferedReader(
            new InputStreamReader(new GZIPInputStream(
                new FileInputStream("test.gz"))));
        String s;
        while((s = in2.readLine()) != null)
        System.out.println(s);
    }
}
```

`GZIPOutputStream`的构造器的参数类型是`FileOutputStream`，还可用`BufferedOutputStream`类包装。`GZIPOutputStream`的构造器只能接受`OutputStream`对象，不接受`Writer`对象。打开文件时,`GZIPInputStream`会转换为`Reader`。

## 多文件压缩保存

Java压缩库使用标准的zip格式，用Checksum类进行计算和校验文件的校验和(Adler32和CRC32两种格式，前者速度快，后者慢但准确)。用例如下：

```java
import java.util.zip.*;
import java.io.*;
import java.util.*;
public class ZipCompress {
    public static void main(String[] args) {
        // 压缩:
        //1 创建压缩输出流，输出流套四层 T_T
        FileOutputStream f = new FileOutputStream("test.zip");
        CheckedOutputStream csum =
            new CheckedOutputStream(f, new Adler32())
        ZipOutputStream zos = new ZipOutputStream(csum);
        BufferedOutputStream out =
            new BufferedOutputStream(zos);
        // 为文件设置注释
        zos.setComment("测试Java压缩文件");

        int ch;
        BufferedReader in = new BufferedReader(new FileReader("a.txt"));
        //2 压缩条目添加到压缩输出流
        zos.putNextEntry(new ZipEntry("a.txt"));
        //3 往缓冲输出流写入压缩文件数据
        while((ch = in.read()) != -1) {
            out.write(ch);
        }
        in.close();
        out.flush(); // 注意读完一个文件刷新缓冲区

        //4 重复2，3步骤，添加第二个文件，如果压缩更多文件采用循环
        in = new BufferedReader(new FileReader("b.txt"));
        //2 压缩条目添加到压缩输出流
        zos.putNextEntry(new ZipEntry("b.txt"));
        //3 往缓冲输出流写入压缩文件数据
        while((ch = in.read()) != -1) {
            out.write(ch);
        }
        in.close();
        out.flush();
        out.close();

        // 读取压缩文件
        //1 创建解压缩输入流，又套四层 T_T
        FileInputStream fi = new FileInputStream("test.zip");
        CheckedInputStream csumi =
            new CheckedInputStream(f, new Adler32())
        ZipInputStream zi = new ZipInputStream(csum);
        BufferedInputStream bis =
            new BufferedInputStream(zos);

        ZipEntry ze;
        while((ze = zi.getNextEntry()) != null) {
            System.out.println("File: " + ze);
            while((ch = bis.read()) != -1)
                System.out.write(ch);
        }
        bis.close();
        /* 另一种读取压缩文件
        ZipFile zf = new ZipFile("test.zip");
        Enumeration e = zf.entries();
        while(e.hasMoreElement()) {
            ZipEntry ze2 = (ZipEntry)e.nextElement();
            System.out.println("File: " + ze2);
            while((ch = bis.read()) != -1)
                System.out.write(ch);
        }
        */
    }
}
```

## jar工具打包和解压

Java项目常常要打包成文件名后缀为`.jar`的压缩格式，类似于zip格式。
jar常用命令:

1.类文件简单打包

```bash
jar cf myJar.jar *.class
```

2.类文件，用户自建清单文件打包

```bash
jar cfm myJar.jar *.class MANIFEST.MF
```

3.多目录打包

```bash
jar cf myApp.jar audio classes image
```

4.jar文件解压

```bash
jar xf myApp.jar
```
