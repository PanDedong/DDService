# DDService
基于过程化的设计，将所有操作抽象为“过程”（每一个过程其实都是一个类方法），并提供同步／异步的执行方式。其中定义一个标准的数据模型 DDService 来承载该“过程”所需参数以及该“过程”的状态：

type 是 service 的唯一标识（字符串类型），是由类的字符串名称＋类方法的字符串名称组成。e.g. @"DDService.sendURLRequest:"

parameters 用来存储 service 启动的时候传入的参数（字典类型）

result 用来存储 service 完成的时候的结果 （字典类型）

status 用来表示 service 的状态（枚举类型，成功 or 失败）

statusMsg 用来描述 service 的状态 （字符串类型）

## Demo介绍

模拟通过经纬度获取当前天气状况的过程，其中又分两个过程：通过经纬度反GEO获取当前城市、通过城市获取天气。

Demo中模拟三种场景：

Concurrent
	
	1.同时根据三个经纬度来获取对应的城市以及天气状况。
	2.运行过程中有三个并发线程来处理该任务。
	3.每一个线程中会有两个串行的网络请求来反GEO当前城市并获取天气。

Serial

	1.根据经纬度获取对应城市以及天气状况。
	2.运行过程中有一个线程来处理该任务。
	3.线程中会有两个串行的网络请求来反GEO当前城市并获取天气。
	
Normal
	
	根据经纬度反GEO当前城市的名称。
	
	
## 注意事项

ARC

Custom Complier Flag: -fobjc-arc-exceptions 