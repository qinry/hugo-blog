---
title: "Mybatis 快速入门"
date: 2021-11-09T09:46:00+08:00
description: "Mybatis 快速入门"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
tags:
- mybatis
- orm
categories:
- java
---

## 为Mybatis创建Gradle项目

使用idea创建gradle项目

项目结构：

```txt
├── build.gradle
├── gradle
│   └── wrapper
│       ├── gradle-wrapper.jar
│       └── gradle-wrapper.properties
├── gradlew
├── gradlew.bat
├── settings.gradle
└── src
    ├── main
    │   ├── java
    │   └── resources
    └── test
        ├── java
        └── resources

9 directories, 6 files
```

### 编写build.gradle

```gradle:build.gradle
plugins {
    id 'java'
}

group 'io.github.qinry'
version '1.0-SNAPSHOT'

jar {
    archivesBaseName = 'mybatis-sample'
}

repositories {
    mavenCentral()
}

dependencies {
    implementation 'org.mybatis:mybatis:3.5.7'
    runtimeOnly 'mysql:mysql-connector-java:8.0.27'
    testImplementation 'org.junit.jupiter:junit-jupiter-api:5.7.0'
    testRuntimeOnly 'org.junit.jupiter:junit-jupiter-engine:5.7.0'
}

test {
    useJUnitPlatform()
}

```

添加依赖`org.mybatis:mybatis:3.5.7`和`mysql:mysql-connector-java:8.0.27`，mybatis编译和运行都使用，作用域设置为`implement`，mysql-connector-java在运行时有效设置为`runtimeOnly`。设置打包的jar的文档基名为`mybatis-sample`。

### 编写settings.gradle

```gradle:settings.gradle
rootProject.name = 'mybatis-sample'
```

根项目名为 `mybatis-sample`，如果有子项目，要使用`include`后跟子项目的名称，把子项目声明在这里让gradle知道。

## Mybatis配置

编写mybatis的xml配置

```xml:src/main/resources/mybatis/mybatis-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <properties resource="/db.properties">
    </properties>
     <settings>
        <setting name="mapUnderscoreToCamelCase" value="true"/>
        <setting name="lazyLoadingEnabled" value="true"/>
        <setting name="aggressiveLazyLoading" value="false" />
    </settings>
    <environments default="development">
        <environment id="development">
            <transactionManager type="JDBC"/>
            <dataSource type="POOLED">
                <property name="driver" value="${driver}"/>
                <property name="url" value="${url}"/>
                <property name="username" value="${username}"/>
                <property name="password" value="${password}"/>
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="io/github/qinry/mapper/StudentMapper.xml" />
        <mapper resource="io/github/qinry/mapper/GradeMapper.xml" />
    </mappers>
</configuration>
```

```
# src/main/resources/db.properties
driver=com.mysql.jdbc.Driver
url=jdbc:mysql://localhost:3306/testdb?serverTimezone=UTC&useUnicode=true&characterEncoding=UTF-8
username=springuser
password=123456
```
配置最重要的两项，分别是`environment`和`mappers`。`environment`里最重要的是配置`transactionManger`和`dataSource`。
`transactionManager`事务管理器一般用`JDBC`。`dataSource`数据源的类型是Mybatis的`POOLED`，设置数据源的`url`、`username`、`password`还有`driver`。`mappers`配置的xml映射文件的位置。

## 创建数据库表

在mysql建库`testdb`还有创建两张表。

```sql
create table student(
    id bigint not null auto_increment,
    stu_name varchar(32) default null,
    grade_id bigint default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;
```
```sql
create table grade(
    id bigint not null auto_increment,
    grade_name varchar(32) default null,
    primary key (id)
)engine=innodb  default charset=utf8mb4;
```

测试数据：
为grade表插入三条数据
```sql
insert into grade(grade_name) values
('一年级'),
('二年级'),
('三年级');
```
为student表插入三条数据
```sql
insert into student(stu_name, grade_id) values
('王二', 1),
('张三', 2),
('李四', 3);
```
## 创建实体pojo

创建Student类

```java:src/main/java/io/github/qinry/pojo/Student.java
package io.github.qinry.pojo;

public class Student implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long id;
    private String stuName;
    private Long gradeId;

    private Grade grade;

    public Student() {
    }

    public Student(Long id, String stuName, Long gradeId) {
        this.id = id;
        this.stuName = stuName;
        this.gradeId = gradeId;
    }

    public Student(String stuName, Long gradeId) {
        this.stuName = stuName;
        this.gradeId = gradeId;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getStuName() {
        return stuName;
    }

    public void setStuName(String stuName) {
        this.stuName = stuName;
    }

    public Long getGradeId() {
        return gradeId;
    }

    public void setGradeId(Long gradeId) {
        this.gradeId = gradeId;
    }

    public Grade getGrade() {
        return grade;
    }

    public void setGrade(Grade grade) {
        this.grade = grade;
    }

    @Override
    public String toString() {
        return "Student{" +
                "id=" + id +
                ", stuName='" + stuName + '\'' +
                ", gradeId=" + gradeId +
                ", grade=" + grade +
                '}';
    }
}
```

Student类属性为id、stuName、gradeId，还有关联属性grade。

创建Grade类

```java:src/main/java/io/github/qinry/pojo/Grade.java
package io.github.qinry.pojo;

import java.util.List;

public class Grade implements Serializable {
    private static final long serialVersionUID = 2L;

    private Long id;
    private String gradeName;

    private List<Student> students;

    public Grade() {
    }

    public Grade(String gradeName) {
        this.gradeName = gradeName;
    }

    public Grade(Long id, String gradeName) {
        this.id = id;
        this.gradeName = gradeName;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getGradeName() {
        return gradeName;
    }

    public void setGradeName(String gradeName) {
        this.gradeName = gradeName;
    }

    public List<Student> getStudents() {
        return students;
    }

    public void setStudents(List<Student> students) {
        this.students = students;
    }

    @Override
    public String toString() {
        return "Grade{" +
                "id=" + id +
                ", gradeName='" + gradeName + '\'' +
                ", students=" + students +
                '}';
    }
}

```

Grade类的属性id、gradeName，还有关联属性grades。

Student和Grade两表之间关系是一对多。

## 编写xml映射文件

改写mybatis-config.xml，在`environments`标签前添加`typeAliases`标签。

```xml:mybatis/mybatis-config.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration
        PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    ...
    <typeAliases>
        <package name="io.github.qinry.pojo"/>
    </typeAliases>
    <environments default="development">
        ...
    </environments>
    <mappers>
        ...
    </mappers>
</configuration>
```

在编写xml映射文件时，使用pojo类型时可以直接使用类名（如`Student`），无须完全限定名（如`io.github.qinry.pojo.Student`）。

编写StudentMapper.xml

```xml:src/main/resources/io/github/qinry/mapper/StudentMapper.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.qinry.mapper.StudentMapper">
    <cache></cache>

    <sql id="column_list">
        id,stu_name,grade_id
    </sql>
    <select id="findAll" >
        select
        <include refid="column_list" />
        from student
    </select>
</mapper>
```

编写GradeMapper.xml

```xml:src/main/resources/io/github/qinry/mapper/GradeMapper.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="io.github.qinry.mapper.GradeMapper">
    <cache></cache>

    <sql id="column_list">
        id,grade_name
    </sql>
    <select id="findAll" resultType="Grade">
        select
        <include refid="column_list" />
        from grade
    </select>
</mapper>
```

update、insert、delete的编写类似，就不重复描述。

## 编写测试

测试StudentMapper

```java:src/test/java/io/github/qinry/mapper/StudentMapperTests.java
public class StudentMapperTests {
    private SqlSessionFactory sqlSessionFactory;
    @BeforeEach
    void setUp() throws IOException {
        InputStream inputStream = Resources.getResourceAsStream("mybatis/mybatis-config.xml");
        sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
    }

    @Test
    void findAll() throws IOException {
        try (SqlSession session = sqlSessionFactory.openSession()) {
            List<Student> students = session.selectList("io.github.qinry.mapper.StudentMapper.findAll");
            students.forEach(System.out::println);
        }


    }
}
```

输出：

```txt
Student{id=1, stuName='王二', gradeId=1, grade=null}
Student{id=2, stuName='张三', gradeId=2, grade=null}
Student{id=3, stuName='李四', gradeId=3, grade=null}
```

测试GradeMapper

```java:src/test/java/io/github/qinry/mapper/GradeMapper.java
public class GradeMapperTests {
    private SqlSessionFactory sqlSessionFactory;
    @BeforeEach
    void setUp() throws IOException {
        InputStream inputStream = Resources.getResourceAsStream("mybatis/mybatis-config.xml");
        sqlSessionFactory = new SqlSessionFactoryBuilder().build(inputStream);
    }

    @Test
    void findAll() throws IOException {
        try (SqlSession session = sqlSessionFactory.openSession()) {
            List<Grade> grades = session.selectList("io.github.qinry.mapper.GradeMapper.findAll");
            grades.forEach(System.out::println);
        }
    }
}
```

输出：

```txt
Grade{id=1, gradeName='一年级', students=null}
Grade{id=2, gradeName='二年级', students=null}
Grade{id=3, gradeName='三年级', students=null}
```

## 添加映射器接口

接口名与xml映射文件命名空间一致，方法名与映射文件的与sql相关标签的id一致，比如`select`标签

添加接口StudentMapper
```java:src/main/java/io/github/qinry/mapper/StudentMapper.java
public interface StudentMapper {
    List<Student> findAll();
}
```

添加接口与GradeMapper
```java:src/main/java/io/github/qinry/mapper/GradeMapper.java
public interface GradeMapper {
    List<Grade> findAll();
}
```

修改`mybatis-config.xml`的`mappers`标签

```xml
<mappers>
    <package name="io.github.qinry.mapper"/>
</mappers>
```

修改测试用例

```java:StudentMapperTests.java
 @Test
void findAll() throws IOException {
    try (SqlSession session = sqlSessionFactory.openSession()) {
        StudentMapper mapper = session.getMapper(StudentMapper.class);
        mapper.findAll().forEach(System.out::println);
    }
}
```

```java:GradeMapperTests.java
@Test
void findAll() throws IOException {
    try (SqlSession session = sqlSessionFactory.openSession()) {
        GradeMapper mapper = session.getMapper(GradeMapper.class);
        mapper.findAll().forEach(System.out::println);
    }
}
```

得到输出结果与未修改一样，不这种方式（getMapper），使用SqlSession相对简洁。

## 编写高级结果集映射

修改StudentMapper.xml
```xml
<resultMap id="studentResult" type="Student">
    <id property="id" column="stu_id"/>
    <result property="stuName" column="stu_name" />
    <result property="gradeId" column="grade_id"></result>
    <association property="grade" column="grade_id" resultMap="gradeResult"/>
</resultMap>
<resultMap id="gradeResult" type="Grade">
    <id property="id" column="grade_id" />
    <result property="gradeName" column="grade_name" />
</resultMap>
<select id="findAll" resultMap="studentResult">
    select
    s.id as stu_id,
    s.stu_name as stu_name,
    g.id as grade_id,
    g.grade_name as grade_name
    from student s
    left outer join grade g on s.grade_id = g.id
</select>
```

测试用例输出：
```txt
Student{id=1, stuName='王二', gradeId=1, grade=Grade{id=1, gradeName='一年级', students=null}}
Student{id=2, stuName='张三', gradeId=2, grade=Grade{id=2, gradeName='二年级', students=null}}
Student{id=3, stuName='李四', gradeId=3, grade=Grade{id=3, gradeName='三年级', students=null}}
```

修改GradeMapper.xml

```xml
<resultMap id="gradeResult" type="Grade">
    <id property="id" column="grade_id" />
    <result property="gradeName" column="grade_name" />
    <collection property="students" ofType="Student"  resultMap="studentResult" />
</resultMap>
<resultMap id="studentResult" type="Student">
    <id property="id" column="stu_id" />
    <result property="stuName" column="stu_name" />
</resultMap>
<select id="findAll" resultMap="gradeResult">
    select
    g.id as grade_id,
    g.grade_name as grade_name,
    s.id as stu_id,
    s.stu_name as stu_name
    from grade g
    left outer join student s on g.id = s.grade_id
</select>
```

测试用例输出：
```txt
Grade{id=1, gradeName='一年级', students=[Student{id=1, stuName='王二', gradeId=null, grade=null}]}
Grade{id=2, gradeName='二年级', students=[Student{id=2, stuName='张三', gradeId=null, grade=null}]}
Grade{id=3, gradeName='三年级', students=[Student{id=3, stuName='李四', gradeId=null, grade=null}]}
```

{{< notice warning >}}
高级结果集映射，使用级联查询（联表查询），实体必须实现Serializable接口。
{{< /notice>}}

## 了解更多

* [更多的高级结果集映射信息](https://mybatis.org/mybatis-3/zh/sqlmap-xml.html#Result_Maps)
* [mybatis3-动态sql](https://mybatis.org/mybatis-3/zh/dynamic-sql.html)
* [mybatis3官方文档](https://mybatis.org/mybatis-3/zh/index.html)