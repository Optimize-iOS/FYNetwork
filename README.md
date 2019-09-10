# FYNetworw 是网络及缓存学习

## 网络

**下面分析按照一下内容来进行分析：**

| **分析依据** |
|:--------------------:|:--------------------:|
| **(1)** 当前版本号 |
| **(2)** 简单介绍、历史跨版本修改主要内容 |
| **(3)** 接口设计的易用性 |
| **(4)** 在网络加载过程中多任务并发实现、任务是否提供取消机制以及提供优先级 |
| **(5)** 获取图片后实现缓存形式 |


### **`SDWebImageAnalysis`**

> **(1)** 版本号：`5.1.0`   
> 
> **(2)** `SDWebImage` 一个远古网络开源库，这个库在 `2009` 年创建，也是在 `iOS` 领域下载比较多的开源库。目前在网络请求采用 `NSURLSession` 方式，换言之只支持 `iOS 7.0` 不过在**官网显示最低版本是 `iOS 8.0`**  
> 
> **(3)** `SDWebImage` 在接口设计上采用 `Category` 的形式通过提供 `url`（图片下载地址），占位图就可以实现下载任务然后设置当前图片。    
> **更多参数：**  
> SDWebImageOptions：可以按照具体实际需求来设置展位图和下载图片处理关系，下载图片优先级设置，下载图片后缓存方式等系列参数，详情可以查看注释  
> SDWebImageContext：   
> SDImageLoaderProgressBlock：在图片下载过程中的进度回调 `block`    
> SDExternalCompletionBlock：图片下载完成后回调 `block` 
>   
> **(4)** `SDWebImage`：**多任务并发实现**、**任务取消机制** 和 **优先级**  
>  **多任务并发实现** 依据 `NSOperationQueue` 来设置 `maxConcurrentOperationCount` 来实现，默认下载任务数为：**6**（可以查看 `SDWebImageDownloaderConfig`）。   
> **任务取消机制** 通过继承 `NSOperation` 来实现 `SDWebImageDownloaderOperation` 重写 `start`、`cancel` 管理 `cancelled`、`executing`、`ready` 和 `finished` 来实现提交下载图片提交任务进行管理。**提供了单个任务取消的机制，方法更加灵活。**    
> **优先级** 通过  **`addDependency`** 来实现同一优先级中实现 `LIFO` 和 `FIFO` 两种执行，根据 `queuePriority` 来设置单个任务的执行优先级顺序（`High`，`Default` 和 `Low`）。   
> 
> **(5)** 采用 **`NSCache`** 和 **`File`** 来实现内存缓存和磁盘缓存，只是做简单的保存处理，没有做额外的操作。 


### **`PINRemoteImageAnalysis`**

> **(1)** 版本号：`3.0.0-beta.14`  
> 
> **(2)** 是美国 `Pinterest`（图片社交公司）在 `2015` 开源的一款图片下载库，下面缓存 `PinCache` 也是该公司开源的项目。目前在网络请求采用 `NSURLSession` 方式，支持最低版本 `iOS 7.0`。   
> 
> **(3)** `PINRemoteImage` 在接口设计上同样是采用 `Category` 提供 `url`（图片下载地址），占位图在下载获取图片后来直接替换。同时在 `Server` 支持的情况下可以实现 `JPEG` 图片渐进式加载。[`JPEG`渐进式在线编译工具](https://coding.tools/cn/progressive-jpeg) **支持断点下载。**    
> **更多参数：**    
> processorKey：作为在 `Cache` 缓存字段组合部分   
> processor：图片在下载过程中进度回调 `block`   
> completion：图片下载完成后回调 `block`  
>  
> **(4)** `PINRemoteImage`: **多任务并发实现**、**任务取消机制** 和 **优先级**       
> **多任务并发实现** 通过自定义 `PINRemoteImageDownloadQueue` 队列采用 `Set` 来保存执行设置 `maxNumberOfConcurrentDownloads`（默认是：10）当任务完成就遍历三个优先级任务队列重新开启新任务下载。   
> **任务取消机制** 提供任务取消，但是这个仅仅对于未执行任务。因为保存任务是采用三个具有优先级 `MutableOrderedSet` 集合。  
> **优先级** 设置三个优先级 `High`、`Default` 和 `Low` 三种优先级，只实现一种 `FIFO` 实现方式。 
>   
> **(5)** 在这个开源项目中仅仅采用 `NSCache` 来实现基本 `Memory` 缓存，但是我猜测在正式应该使用自己公司封装的 `PINCache`（下文会做讲解）。    


### **`FYHttpURLProtocol`**

> 小编参考一些博客来实现在 `iOS 10` 版本基础上，可以实现在 `AMP` 中对网络请求中 `DNS`，`SSL` 和 `TCP` 以及数据请求中花费时间统计。   
> 在实际网络请求中 **上行数据** 和 **下行数据** 的流量统计。


### **`FYNetworkMonitor`**

> 基于在 `FYHttpURLProtocol` 只能在 [URL Loading System](https://developer.apple.com/documentation/foundation/url_loading_system) 层面来进行请求处理，在流量统计时不能准确获取在 `Response` 中 `Body` 一些参数，并且也只有在 `iOS 10` 之上才可以使用有一定的局限性。       
> 就采用 `AOP` 编码形式来根据 `NSPorxy` 和 `FaceBook` 开源的项目 [fishhok](https://github.com/facebook/fishhook) 对 `NSURLCollection`、`NSURLSession` 和 `CFNetwork` 来进行 `Hook` 来实现对 `DNS`、`SSL` 和 `TCP`数据请求花费时间和使用流量统计，目前还在完善中ing。


## 缓存

### `YYCacheAnalysis`

> `YYCache` 是 `YY` 大神开源的基于：内存缓存、`File` 和 `Sqlite` 来实现的数据缓存实现，对其实现过程进行分析，具体可以查看代码注释。不过在使用 `Sqlite` 时仅仅是对保存 `maxCount = 20K` 来做为 `File` 和 `Sqlite` 阈值，根据**微信在 `Sqlite` 对源码的优化和数据库索引设计和优化**。在一定的场景下感觉还可以在改进。

### `PINCacheAnalysis`

> `PINCache` 采用在 `Memory` 和 `File` 数据缓存，提供 `byteLimit =  50 * 1024 * 1024`、 `ageLimit =  50 * 1024 * 1024` 磁盘限制。 `Memory` 实际实现是采用 `NSMutableDictionary` 来实现。提供异步加载方式，采用 **信号量** 来实现并发操作。具体实现类 `PINOperationQueue`。


### `FMDBAnalysis`

> 是对 `Sqlite` 操作的 `objc` 的封装，在此基础上实现事物机制。
> 
> 
> 
