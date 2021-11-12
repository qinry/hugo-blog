---
title: "Mybatis Generator 快速开始"
date: 2021-11-12T23:44:27+08:00
description: "Mybatis 代码生成插件，加快开发"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- mybatis
- orm
- gradle
categories:
- java
---


## 创建Gradle项目

```gradle:build.gradle
plugins {
    id 'org.springframework.boot' version '2.5.6'
    id "com.thinkimi.gradle.MybatisGenerator" version "2.4"
}

apply plugin: 'java'
apply plugin: 'io.spring.dependency-management'

group 'io.github.qinry'
version '1.0-SNAPSHOT'
sourceCompatibility = JavaVersion.VERSION_11

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.mybatis.spring.boot:mybatis-spring-boot-starter:2.2.0'
    runtimeOnly 'mysql:mysql-connector-java'
    testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
    useJUnitPlatform()
}
```


## 编写 generatorConfig.xml

在项目根路径下创建generatorConfig.xml文件

```xml:generatorConfig.xml
<!DOCTYPE generatorConfiguration PUBLIC
        "-//mybatis.org//DTD MyBatis Generator Configuration 1.0//EN"
        "http://mybatis.org/dtd/mybatis-generator-config_1_0.dtd">
<generatorConfiguration>
    <context id="Mysql" targetRuntime="Mybatis3">
        <plugin type="org.mybatis.generator.plugins.SerializablePlugin"></plugin>
        <plugin type="org.mybatis.generator.plugins.UnmergeableXmlMappersPlugin"></plugin>
        <plugin type="org.mybatis.generator.plugins.FluentBuilderMethodsPlugin"></plugin>
        <plugin type="org.mybatis.generator.plugins.ToStringPlugin"></plugin>

        <!-- 生成的代码没有注释       -->
        <commentGenerator>
            <property name="suppressAllComments" value="true" />
        </commentGenerator>

        <jdbcConnection driverClass="com.mysql.cj.jdbc.Driver"
                        connectionURL="jdbc:mysql://localhost:3306/testdb"
                        userId="springuser"
                        password="123456"/>

        <!--  不强制使用BigDecimal字段，使数据库为NUMBERIC或DECIMAL字段被整型类型替换，会更易于使用      -->
        <javaTypeResolver>
            <property name="forceBigDecimals" value="false" />
        </javaTypeResolver>

        <javaModelGenerator targetPackage="com.owk.domain" targetProject="src/main/java">
            <property name="trimStrings" value="true" />
        </javaModelGenerator>

        <sqlMapGenerator targetPackage="com.owk.mapper" targetProject="src/main/resources"/>

        <javaClientGenerator type="XMLMAPPER" targetPackage="com.owk.mapper" targetProject="src/main/java"/>

        <table tableName="student" domainObjectName="Student" >
            <generatedKey column="ID" sqlStatement="MySql" identity="true" />
        </table>
        <table tableName="grade" domainObjectName="Grade">
            <generatedKey column="ID" sqlStatement="MySql" identity="true"/>
        </table>
    </context>
</generatorConfiguration>
```

1. `org.mybatis.generator.plugins.SerializablePlugin` 生成的模型类实现`Serializable`接口
2. `org.mybatis.generator.plugins.UnmergeableXmlMappersPlugin` 产生的影响是，如果生成xml映射文件的文件名已存在，则不会合并已存在的内容。这个插件按需要添加。总之就是会覆盖之前的内容
3. `org.mybatis.generator.plugins.FluentBuilderMethodsPlugin` 生成的模型类准备流畅建造者模式，在测试用例可查看到使用
4. `org.mybatis.generator.plugins.ToStringPlugin` 为模型创建 `toString()` 方法
5. `<jdbcConnection>` 用于连接数据库，代码生成插件是按照数据库表生成模型、映射器和 xml
6. `<javaModelGenerator>` 决定生成Java模型类的位置，String类型字段使不实用 `trim()` 方法
7. `<sqlMapGenerator>` 决定生成映射器xml文件的位置
8. `<javaClientGenerator>` 决定生成映射器接口的位置


## 创建数据库表

这个插件是依赖于数据库生成代码的。所以要提前建好表格

```sql
create table student(
    id bigint not null auto_increment,
    stu_name varchar(32) default null,
    grade_id bigint default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;

create table grade(
    id bigint not null auto_increment,
    grade_name varchar(32) default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;
```

## 执行生成任务

```bash
gradle mbGenerator
```

保证包 `com.owk` 提前创建好，这个插件默认配置不会创建层级超过一的目录。有IDE支持就更加方便。
生成代码如下：

```
src/main
├── java
│   └── com
│       └── owk
│           ├── mapper
│           │   ├── GradeMapper.java
│           │   └── StudentMapper.java
│           └── domain
│               ├── Grade.java
│               ├── GradeExample.java
│               ├── Student.java
│               └── StudentExample.java
└── resources
    ├── com
    │   └── owk
    │       └── mapper
    │           ├── GradeMapper.xml
    │           └── StudentMapper.xml
```

## 设置项目属性

```yml:application.yml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
    driver-class-name: com.mysql.cj.jdbc.Driver
    username: springuser
    password: 123456
mybatis:
  config-location: classpath:mybatis-config.xml
logging:
  level:
    com.owk.mapper: trace
```

设置数据源还有设置mybatis配置文件位置。

## 编写mybatis-config.xml

```xml:mybatis-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false" />
        <setting name="logImpl" value="SLF4J" />
    </settings>
</configuration>
```

设置mybatis，开启数据库字段的下划线写法映射为驼峰写法。开启延迟加载，取消积极加载。指定映射器路径。

## 使用生成的代码

```java:StudentMapperTests.java

/**
 * 测试前请先清空表数据 <code>truncate student</code>
 */

@SpringBootTest
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
public class StudentMapperTests {

    @Resource
    private StudentMapper studentMapper;

    private List<Long> ids;

    @BeforeEach
    void setUp() {
        System.out.println("\033[0;92m****************测试开始******************\033[0m");
        System.out.println("\033[0;92m***************填充三行数据**************\033[0m");
        studentMapper.insert(new Student().withStuName("张三").withGradeId(1L));
        studentMapper.insert(new Student().withStuName("李四").withGradeId(2L));
        studentMapper.insert(new Student().withStuName("王五").withGradeId(3L));
        ids = studentMapper.selectByExample(null).stream().map(Student::getId).collect(Collectors.toList());
    }

    /**
     * 增
     */
    @Test
    @Order(1)
    void create() {
        System.out.println("\033[0;92m***************插入两行行数据**************\033[0m");
        // 使用流畅建造者，动态插入字段值
        studentMapper.insertSelective(new Student().withStuName("赵六").withGradeId(1L)); // [1]
        // 除了主键外，所有字段值插入
        studentMapper.insert(new Student().withStuName("武七").withGradeId(2L)); // [2]
        StudentExample example = new StudentExample();
        StudentExample.Criteria criteria = example.createCriteria();
        criteria.andStuNameIn(List.of("赵六", "武七"));
        System.out.println("\033[0;92m*****************查询刚插入的数据****************\033[0m");
        studentMapper.selectByExample(example);
    }

    /**
     * 查
     */
    @Test
    @Order(2)
    void read() {
        System.out.println("\033[0;92m*************查询学生姓名包含李*************\033[0m");
        StudentExample example = new StudentExample();
        StudentExample.Criteria criteria = example.createCriteria();
        criteria.andStuNameLike("%李%");
        List<Student> students = studentMapper.selectByExample(example); // [3]
        List<Long> ids = students.stream().map(Student::getId).collect(Collectors.toList());
        ids.forEach(id -> {
            System.out.println("\033[0;92m********查询主键"+id+"的数据********\033[0m");
            studentMapper.selectByPrimaryKey(id); // [4]
        });
    }

    /**
     * 改
     */

    @Test
    @Order(3)
    void update() {
        System.out.println("\033[0;92m*******************更新id为"+ids.get(0)+"********************\033[0m");
        // 动态更新字段值
        studentMapper.updateByPrimaryKeySelective(new Student().withId(ids.get(0)).withStuName("杨开").withGradeId(2L)); // [5]
        // 更新所有字段值
        studentMapper.updateByPrimaryKey(new Student().withId(ids.get(1)).withStuName("苏颜").withGradeId(3L)); // [6]
 
        StudentExample example = new StudentExample();
        StudentExample.Criteria criteria = example.createCriteria(); // 
        criteria.andStuNameLike("%王%");
        studentMapper.updateByExampleSelective(new Student().withGradeId(1L), example); // [7]

        Student student = studentMapper.selectByPrimaryKey(ids.get(2));
        studentMapper.updateByExample(student.withStuName("夏霓裳"), example); // [8]

        System.out.println("\033[0;92m*****************查询更新后的数据****************\033[0m");
        studentMapper.selectByExample(null);
    }

    /**
     * 删
     */
    @Test
    @Order(4)
    void delete() {
        List<Student> students = studentMapper.selectByExample(null);
        List<Long> ids = students.stream().map(Student::getId).collect(Collectors.toList());
        System.out.println("\033[0;92m*******************删除主键"+ids.get(0)+"********************\033[0m");
        studentMapper.deleteByPrimaryKey(ids.get(0)); // [9]
        System.out.println("\033[0;92m*******************删除年级id为3********************\033[0m");
        StudentExample example = new StudentExample();
        StudentExample.Criteria criteria = example.createCriteria();
        criteria.andGradeIdEqualTo(3L);
        studentMapper.deleteByExample(example); // [10]

        System.out.println("\033[0;92m*****************查询删除后的数据****************\033[0m");
        studentMapper.selectByExample(null);
    }

    @AfterEach
    void tearDown() {
        System.out.println("\033[0;92m*******************测试结束********************\033[0m");
        studentMapper.deleteByExample(null);
    }
}

```

这个测试用例，展示了增删改查的使用，条件查询如何创建动态的条件。更多的用法细节可以查看生成映射器接口和xml映射文件。

更多参见[官方文档](https://mybatis.org/generator/)