# 字典翻译

## Spring注解实现数据字典翻译

参考链接：[Spring注解实现数据字典翻译](https://blog.csdn.net/weixin_33549115/article/details/115042734)

### 概述

在开始之前，首先我们要了解一个类：BeanPropertyWriter。

这个类是由SerializerFactory 工厂进行实例化的，其作用是对bean中的每个字段进行jackson操作的封装，其中封装了字段的一些元信息，和对此字段进行jackson序列化的操作。

采用Spring项目进行Web服务开发时，在获取到数据后，Spring会通过BeanPropertyWriter对数据进行jackson封装，将其转换为Json串。

如果我们需要在不影响逻辑的情况下对数据进行字典翻译，重写此类是较好的选择

### 字典翻译实现步骤

1. 实现获取字典的接口

   ```java
   public interface DictService{
       /**
        *key:字典类别
        *value：字典代码值
        *return：字典代码对应的value值
       */
       Object getValueByKey(String key,String value);
   }
   ```

2. 新建注解便于对需要转换的字段进行区分

   ```java
   @Retention(RetentionPolicy.RUNTIME)
   @Target({ElementType.FIELD})
   @Documented
   public @interface DictConverter{
       String key() default "";
   }
   ```

3. 在需要翻译的字段上添加该注解

   ```java
   //数据字典中配有字典项为TEST的字典值
   @DictConverter(key="TEST")
   private String item;
   ```

4. 新建SpringUtil类

   ```java
   @Component
   public class SpringUtil implements ApplicationContextAware {
       
       private static ApplicationContext applicationContext=null;
   
       @Override
       public void setApplicationContext(ApplicationContext applicationContext)throws BeansException{
           if(this.applicationContext=null){
               this.applicationContext=applicationContext;
           }
       }
       //获取applicationContext
       public static ApplicationContext getApplicationContext(){return applicationContext;}
       
       //通过name获取Bean
       public static Object getBean(String name){
           return getApplicationContext().getBean(name);
       }
       
       //通过class获取Bean
       public static T Object getBean(Class clazz){
           return getApplicationContext().getBean(clazz);
       }
       
       //通过name,以及Clazz返回指定的Bean
       public static T Object getBean(String name,Class clazz){
           return getApplicationContext().getBean(name,clazz);
       }
   }
   ```

5. 重写BeanPropertyWriter类(主要实现部分)

   粘出BeanPropertyWriter的包名，在自己的工程下创建这个包

   新建BeanPropertyWriter类，将jackson的源代码copy过来

   声明刚才创建的DictService及注解

   创建getDictService()用于获取service对象

   找到serializeAsField方法

   ```java
   private DictService dictService;
   
   private DictConverter dictConverter;
   
   private DictService getDictService(){
       if(dictService == null){
           dictService = SpringUtil.getBean(DictService.class);
       }
       return dictService;
   }
   
   public void serializeAsField(Object bean, JsonGenerator gen, SerializerProvider prov) throws Exception {
       Object value = this._accessorMethod == null ? this._field.get(bean) : this._accessorMethod.invoke(bean);
       //数据字典翻译
       try{
           if(this._member.hasAnnotation(DictConverter.class)){
               dictConverter=this._member.getAnnotation(DictConverter.class);
               if(dictConverter!=null){
                   value=getDictService.getValueByKey(dictConverter.key(),value.toString());
                   if(value==null){
                       value = this._accessorMethod == null ? this._field.get(bean) : this._accessorMethod.invoke(bean);
   
                   }
               }
           }
       }catch(Exception e){
           //此处可能因字段类型出现报错
           value = this._accessorMethod == null ? this._field.get(bean) : this._accessorMethod.invoke(bean);
       }
       //以下部分不做修改，此处省略
   }
   ```




##   springboot 返回数据字典翻译

https://blog.csdn.net/qq_41497111/article/details/109857636