# System Design Notes

## 领域驱动设计

关键词：领域划分，业务身份，流程编排

一套比较抽象的方法论

- 领域驱动设计之领域模型

  加一个导航，关于如何设计聚合的详细思考，见[这篇](SubItems/https://link.zhihu.com/?target=http%3A//www.cnblogs.com/netfocus/p/3307971.html)文章。

  2004年Eric Evans 发表Domain-Driven Design –Tackling Complexity in the Heart of Software （领域驱动设计），简称Evans DDD。领域驱动设计分为两个阶段：

  以一种领域专家、设计人员、开发人员都能理解的通用语言作为相互交流的工具，在交流的过程中发现领域概念，然后将这些概念设计成一个领域模型；
  由领域模型驱动软件设计，用代码来实现该领域模型；

  由此可见，领域驱动设计的核心是建立正确的领域模型。

- Akka可能是这个方法论落地的一个方案

## 面相对象设计

开闭原则

接口隔离

依赖倒置

最小职责

迪米特法则

里氏替换原则：重写破坏该种原则