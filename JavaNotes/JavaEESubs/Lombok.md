# Lombok注解

文章来源：

1. [Lombok 注解详解](https://juejin.cn/post/6844904062962368525)
2. [lombok @Accessors用法](https://www.cnblogs.com/luchangjiang/p/10596604.html)
3. [Lombok注解笔记](https://segmentfault.com/a/1190000016111422)

## 简介

lombok是一个编译级别的插件，它可以在项目编译的时候生成一些代码。通俗的说，lombok可以通过注解来标示生成`getter` `settter`等代码。

## 引入

创建gradle项目

```groovy
compile group: 'org.projectlombok', name: 'lombok', version: '1.16.20'
```

```xml
<!-- https://mvnrepository.com/artifact/org.projectlombok/lombok -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.16.20</version>
</dependency>
```

## 注解

### lombok包

#### @NonNull

> 标记字段不可为null

```java
@Setter
public class Person {
    @NonNull
    private String name;
    @NonNull
    private Integer age;
}
```

对应的字节码文件：

```java
public class Person {
    @NonNull
    private String name;
    @NonNull
    private Integer age;

    public Person() {
    }

    public void setName(@NonNull String name) {
        if (name == null) {
            throw new NullPointerException("name");
        } else {
            this.name = name;
        }
    }

    public void setAge(@NonNull Integer age) {
        if (age == null) {
            throw new NullPointerException("age");
        } else {
            this.age = age;
        }
    }
}
```

#### @Getter

> 自动生成getter方法

参数

- onMethod：把需要添加的注解写在这

> 例子

```java
public class Example {
    @Getter(onMethod_={@Deprecated}) // JDK7写法 @Getter(onMethod=@__({@Deprecated}))
    private int foo;
    private final String bar  = "";
}
```

生成：

```java
public class Example {
    private int foo;
    private final String bar = "";

    public Example() {
    }

    /** @deprecated */
    @Deprecated
    public int getFoo() {
        return this.foo;
    }
}
```

- value：访问权限修饰符

#### @Setter

生成Setter

> 参数

- onMethod：在方法上添加中注解，见@Getter#onMethod
- onParam：在方法的参数上添加注解，见@Getter#onMethod
- value：访问权限修饰符

#### @Data

> 作用

生成所有字段的getter、toString()、hashCode()、equals()、所有非final字段的setter、构造器，相当于设置了 @Getter @Setter @RequiredArgsConstructor @ToString @EqualsAndHashCode

> 例子

```java
@Data
public class Example {

    private int foo;
    private final String bar;
}
```

生成：

```java
public class Example {
    private int foo;
    private final String bar;

    public Example(String bar) {
        this.bar = bar;
    }

    public int getFoo() {
        return this.foo;
    }

    public String getBar() {
        return this.bar;
    }

    public void setFoo(int foo) {
        this.foo = foo;
    }

    public boolean equals(Object o) {
        if (o == this) {
            return true;
        } else if (!(o instanceof Example)) {
            return false;
        } else {
            Example other = (Example)o;
            if (!other.canEqual(this)) {
                return false;
            } else if (this.getFoo() != other.getFoo()) {
                return false;
            } else {
                Object this$bar = this.getBar();
                Object other$bar = other.getBar();
                if (this$bar == null) {
                    if (other$bar != null) {
                        return false;
                    }
                } else if (!this$bar.equals(other$bar)) {
                    return false;
                }

                return true;
            }
        }
    }

    protected boolean canEqual(Object other) {
        return other instanceof Example;
    }

    public int hashCode() {
        int PRIME = true;
        int result = 1;
        int result = result * 59 + this.getFoo();
        Object $bar = this.getBar();
        result = result * 59 + ($bar == null ? 43 : $bar.hashCode());
        return result;
    }

    public String toString() {
        return "Example(foo=" + this.getFoo() + ", bar=" + this.getBar() + ")";
    }
}
```

#### @Cleanup

> 自动关闭流代码

```java
@Cleanup
InputStream in = new FileInputStream(args[0]);
```

对应的字节码文件：

```java
InputStream in = new FileInputStream(args[0]);
if (Collections.singletonList(in).get(0) != null) {
    in.close();
}
```

- value：被在finally块中调用的方法名，方法体不能带有参数，默认为close

#### @XxxConstructor

@AllArgsConstructor/@NoArgsConstructor

> 自动生成全参构造函数和无参构造函数

```java
@AllArgsConstructor
@NoArgsConstructor
public class Person {
    private String name;
    private Integer age;
}
```

对应的字节码文件

```java
public class Person {
    private String name;
    private Integer age;

    public Person(String name, Integer age) {
        this.name = name;
        this.age = age;
    }

    public Person() {
    }
}
```

- staticName : 不为空的话，生成一个静态方法返回实例，并把构造器设置为private

```java
@AllArgsConstructor(staticName = "create")
public class Example {

    private int foo;
    private final String bar;
}
```

对应的字节码文件

```java
public class Example {
    private int foo;
    private final String bar;

    private Example(int foo, String bar) {
        this.foo = foo;
        this.bar = bar;
    }

    public static Example create(int foo, String bar) {
        return new Example(foo, bar);
    }
}
```

- access : 构造器访问权限修饰符，默认public
- @NoArgsConstructor.force：为true时，强制生成构造器，final字段初始化为null
- @NoArgsConstructor.onConstructor：添加注解，参考@Getter#onMethod

#### @RequiredArgsConstructor

```java
@RequiredArgsConstructor
public class Example {

    @NonNull
    private Integer foo;
    private final String bar;
}
```

生成后：

```java
public class Example {
    @NonNull
    private Integer foo;
    private final String bar;

    public Example(@NonNull Integer foo, String bar) {
        if (foo == null) {
            throw new NullPointerException("foo is marked @NonNull but is null");
        } else {
            this.foo = foo;
            this.bar = bar;
        }
    }
}
```

#### @Builder

> 自动生成建造者模式的bean

```java
@Builder
public class Person {
    private String name;
    private Integer age;
}
```

对应的字节码文件

```java
public class Person {
    private String name;
    private Integer age;

    Person(String name, Integer age) {
        this.name = name;
        this.age = age;
    }

    public static Person.PersonBuilder builder() {
        return new Person.PersonBuilder();
    }

    public static class PersonBuilder {
        private String name;
        private Integer age;

        PersonBuilder() {
        }

        public Person.PersonBuilder name(String name) {
            this.name = name;
            return this;
        }

        public Person.PersonBuilder age(Integer age) {
            this.age = age;
            return this;
        }

        public Person build() {
            return new Person(this.name, this.age);
        }

        public String toString() {
            return "Person.PersonBuilder(name=" + this.name + ", age=" + this.age + ")";
        }
    }
}
```

- builderMethodName : 创建构建器实例的方法名称
- buildMethodName：构建器类中创建构造器实例的方法名称
- builderClassName：构造器类名
- toBuilder：生成toBuilder方法

> 例子

```java
public Example.ExampleBuilder toBuilder() {
    return (new Example.ExampleBuilder()).foo(this.foo).bar(this.bar);
}
```

#### @Singular

> 作用

这个注解和@Builder一起使用，为Builder生成字段是集合类型的add方法，字段名不能是单数形式，否则需要指定value值

> 例子

```java
@Builder
public class Example {

    @Singular
    @Setter
    private List<Integer> foos;
}
```

生成：

```java
public class Example {
    private List<Integer> foos;

    Example(List<Integer> foos) {
        this.foos = foos;
    }

    public static Example.ExampleBuilder builder() {
        return new Example.ExampleBuilder();
    }

    public void setFoos(List<Integer> foos) {
        this.foos = foos;
    }

    public static class ExampleBuilder {
        private ArrayList<Integer> foos;

        ExampleBuilder() {
        }
        
        // 这方法是@Singular作用生成的
        public Example.ExampleBuilder foo(Integer foo) {
            if (this.foos == null) {
                this.foos = new ArrayList();
            }

            this.foos.add(foo);
            return this;
        }

        public Example.ExampleBuilder foos(Collection<? extends Integer> foos) {
            if (this.foos == null) {
                this.foos = new ArrayList();
            }

            this.foos.addAll(foos);
            return this;
        }

        public Example.ExampleBuilder clearFoos() {
            if (this.foos != null) {
                this.foos.clear();
            }

            return this;
        }

        public Example build() {
            List foos;
            switch(this.foos == null ? 0 : this.foos.size()) {
            case 0:
                foos = Collections.emptyList();
                break;
            case 1:
                foos = Collections.singletonList(this.foos.get(0));
                break;
            default:
                foos = Collections.unmodifiableList(new ArrayList(this.foos));
            }

            return new Example(foos);
        }

        public String toString() {
            return "Example.ExampleBuilder(foos=" + this.foos + ")";
        }
    }
}
```

#### @EqualsAndHashCode

> 自动生成equals和hashcode方法

```java
@EqualsAndHashCode
public class Person {
    private String name;
    private Integer age;
}
```

对应的字节码文件

```java
public class Person {
 private String name;
 private Integer age;

 public Person() {
 }

 public boolean equals(Object o) {
     if (o == this) {
         return true;
     } else if (!(o instanceof Person)) {
         return false;
     } else {
         Person other = (Person)o;
         if (!other.canEqual(this)) {
             return false;
         } else {
             Object this$name = this.name;
             Object other$name = other.name;
             if (this$name == null) {
                 if (other$name != null) {
                     return false;
                 }
             } else if (!this$name.equals(other$name)) {
                 return false;
             }

             Object this$age = this.age;
             Object other$age = other.age;
             if (this$age == null) {
                 if (other$age != null) {
                     return false;
                 }
             } else if (!this$age.equals(other$age)) {
                 return false;
             }

             return true;
         }
     }
 }

 protected boolean canEqual(Object other) {
     return other instanceof Person;
 }

 public int hashCode() {
     int PRIME = true;
     int result = 1;
     Object $name = this.name;
     int result = result * 59 + ($name == null ? 43 : $name.hashCode());
     Object $age = this.age;
     result = result * 59 + ($age == null ? 43 : $age.hashCode());
     return result;
 }
}
```

- callSuper：是否调用父类的hashCode()，默认：false
- doNotUseGetters：是否不调用字段的getter，默认如果有getter会调用。设置为true，直接访问字段，不调用getter
- exclude：此处列出的任何字段都不会在生成的equals和hashCode中使用。
- of：与exclude相反，设置of，exclude失效
- onParam：添加注解，参考@Getter#onMethod

#### @ToString

> 自动生成toString()方法

```java
@ToString
public class Person {
    private String name;
    private Integer age;
}
```

对应的字节码文件

```java
public class Person {
    private String name;
    private Integer age;

    public Person() {
    }

    public String toString() {
        return "Person(name=" + this.name + ", age=" + this.age + ")";
    }
}
```

#### @Value

> 自动生成全参构造函数、Getter方法、equals方法、hashCode法、toString方法
>
> 把类声明为final，并添加toString()、hashCode()等方法，相当于以下组合：
>
> @Getter 
>
> @FieldDefaults(makeFinal=true, level=AccessLevel.PRIVATE)
>
> @AllArgsConstructor 
>
> @ToString 
>
> @EqualsAndHashCode.

```java
@Value
public class Person {
    private String name;
    private Integer age;
}
```

注意：@Value不会生成Setter方法

#### @Synchronized

> 自动为被标记的方法添加synchronized锁

```java
public class SynchronizedExample {
  private final Object readLock = new Object();
  
  @Synchronized
  public static void hello() {
    System.out.println("world");
  }
  
  @Synchronized
  public int answerToLife() {
    return 42;
  }
  
  @Synchronized("readLock")
  public void foo() {
    System.out.println("bar");
  }
}
```

对应的字节码文件

```java
public class SynchronizedExample {
    private static final Object $LOCK = new Object[0];
    private final Object $lock = new Object[0];
    private final Object readLock = new Object();

    public static void hello() {
        synchronized($LOCK) {
            System.out.println("world");
        }
    }

    public int answerToLife() {
        synchronized($lock) {
            return 42;
        }
    }

    public void foo() {
        synchronized(readLock) {
            System.out.println("bar");
        }
    }
}
```

#### @Delegate

> 为标记属性生成委托方法

```java
public class DelegateExample {
    public void show() {
        System.out.println("show...");
    }
}
@AllArgsConstructor
public class Demo {
    @Delegate
    private final DelegateExample delegateExample;
}
```

对应的字节码文件

```java
public class DelegateExample {
    public DelegateExample() {
    }

    public void show() {
        System.out.println("show...");
    }
}
public class Demo {
    private final DelegateExample delegateExample;

    public Demo(DelegateExample delegateExample) {
        this.delegateExample = delegateExample;
    }

    // 委托方法
    public void show() {
        this.delegateExample.show();
    }
}
```

#### @Generated

这个注解似乎没有实在的作用，就是标记这个类、字段、方法是自动生成的

#### @SneakyThrows

> 作用

用try{}catch{}捕捉异常

> 例子

```java
public class Example {

    @SneakyThrows(UnsupportedEncodingException.class)
    public String utf8ToString(byte[] bytes) {
        return new String(bytes, "UTF-8");
    }
}
```

生成后：

```java
public class Example {
    public Example() {
    }

    public String utf8ToString(byte[] bytes) {
        try {
            return new String(bytes, "UTF-8");
        } catch (UnsupportedEncodingException var3) {
            throw var3;
        }
    }
}
```

#### @Synchronized

> 作用

生成Synchronized(){}包围代码

> 例子

```java
public class Example {

    @Synchronized
    public String utf8ToString(byte[] bytes) {
        return new String(bytes, Charset.defaultCharset());
    }
}
```

生成后：

```java
public class Example {
    private final Object $lock = new Object[0];

    public Example() {
    }

    public String utf8ToString(byte[] bytes) {
        Object var2 = this.$lock;
        synchronized(this.$lock) {
            return new String(bytes, Charset.defaultCharset());
        }
    }
}
```

#### @val

> 作用

变量声明类型推断

> 例子

```java
public class ValExample {
    public String example() {
        val example = new ArrayList<String>();
        example.add("Hello, World!");
        val foo = example.get(0);
        return foo.toLowerCase();
    }

    public void example2() {
        val map = new HashMap<Integer, String>();
        map.put(0, "zero");
        map.put(5, "five");
        for (val entry : map.entrySet()) {
            System.out.printf("%d: %s\n", entry.getKey(), entry.getValue());
        }
    }
}
```

生成后：

```java
public class ValExample {
    public ValExample() {
    }

    public String example() {
        ArrayList<String> example = new ArrayList();
        example.add("Hello, World!");
        String foo = (String)example.get(0);
        return foo.toLowerCase();
    }

    public void example2() {
        HashMap<Integer, String> map = new HashMap();
        map.put(0, "zero");
        map.put(5, "five");
        Iterator var2 = map.entrySet().iterator();

        while(var2.hasNext()) {
            Entry<Integer, String> entry = (Entry)var2.next();
            System.out.printf("%d: %s\n", entry.getKey(), entry.getValue());
        }

    }
}
```

### lombok.experimental包

#### @Accessors

> 翻译是存取器。通过该注解可以控制getter和setter方法的形式。

- 参数 fluent 若为true，则getter和setter方法的方法名都是属性名，且setter方法返回当前对象。

  ```java
  @Data
  @Accessors(fluent = true)
  class User {
      private Integer id;
      private String name;
      
      // 生成的getter和setter方法如下，方法体略
      public Integer id(){}
      public User id(Integer id){}
      public String name(){}
      public User name(String name){}
  }
  
  ```

- 参数 chain 若为true，则setter方法返回当前对象，即为true时，setter链式返回，即setter的返回值为this

  ```java
  @Data
  @Accessors(chain = true)
  class User {
      private Integer id;
      private String name;
      
      // 生成的setter方法如下，方法体略
      public User setId(Integer id){}
      public User setName(String name){}
  }
  ```

- 参数 prefix 若为true，则getter和setter方法会忽视属性名的指定前缀（遵守驼峰命名）

  ```java
  @Data
  @Accessors(prefix = "f")
  class User {
      private Integer fId;
      private String fName;
      
      // 生成的getter和setter方法如下，方法体略
      public Integer id(){}
      public void id(Integer id){}
      public String name(){}
      public void name(String name){}
  }
  ```

#### @Delegate

> 作用

代理模式，把字段的方法代理给类，默认代理所有方法

> 参数

- types：指定代理的方法
- excludes：和types相反

> 例子

```java
public class Example {

    private interface Add {
        boolean add(String x);
        boolean addAll(Collection<? extends String> x);
    }

    private @Delegate(types = Add.class) List<String> strings;
}
```

生成后：

```java
public class Example {
    private List<String> strings;

    public Example() {
    }

    public boolean add(String x) {
        return this.strings.add(x);
    }

    public boolean addAll(Collection<? extends String> x) {
        return this.strings.addAll(x);
    }

    private interface Add {
        boolean add(String var1);

        boolean addAll(Collection<? extends String> var1);
    }
}
```

#### @ExtensionMethod

> 作用

拓展方法，向现有类型“添加”方法，而无需创建新的派生类型。有点像kotlin的扩展函数。

> 例子

```java
@ExtensionMethod({Arrays.class, Extensions.class})
public class Example {

    public static void main(String[] args) {
        int[] intArray = {5, 3, 8, 2};
        intArray.sort();
        int num = 1;
        num = num.increase();

        Arrays.stream(intArray).forEach(System.out::println);
        System.out.println("num = " + num);
    }
}

class Extensions {
    public static int increase(int num) {
        return ++num;
    }
}
```

生成后：

```java
public class Example {
    public Example() {
    }

    public static void main(String[] args) {
        int[] intArray = new int[]{5, 3, 8, 2};
        Arrays.sort(intArray);
        int num = 1;
        int num = Extensions.increase(num);
        IntStream var10000 = Arrays.stream(intArray);
        PrintStream var10001 = System.out;
        System.out.getClass();
        var10000.forEach(var10001::println);
        System.out.println("num = " + num);
    }
}
```

输出：

```abnf
2
3
5
8
num = 2
```

#### @FieldDefaults

> 作用

定义类、字段的修饰符

> 参数

- AccessLevel：访问权限修饰符
- makeFinal：是否加final

#### @FieldNameConstants

> 作用

默认生成一个常量，名称为大写字段名，值为字段名

> 参数

- prefix：前缀
- suffix：后缀

> 例子

```java
public class Example {

    @FieldNameConstants(prefix = "PREFIX_", suffix = "_SUFFIX")
    private String foo;
}
```

生成后：

```java
public class Example {
    public static final String PREFIX_FOO_SUFFIX = "foo";
    private String foo;

    public Example() {
    }
}
```

#### @Helper

> 作用

方法内部的类方法暴露给方法使用

> 测试时，maven编译不通过。

#### @NonFinal

> 作用

设置不为Final，@FieldDefaults和@Value也有这功能

#### @PackagePrivate

> 作用

设置为private，@FieldDefaults和@Value也有这功能

#### @SuperBuilder

#### @Tolerate

#### @UtilityClass

#### @Wither

> 作用

生成withXXX方法，返回类实例

> 例子

```java
@RequiredArgsConstructor
public class Example {
    private @Wither final int foo;
}
```

生成后：

```java
public class Example {
    private final int foo;

    public Example(int foo) {
        this.foo = foo;
    }

    public Example withFoo(int foo) {
        return this.foo == foo ? this : new Example(foo);
    }
}
```

