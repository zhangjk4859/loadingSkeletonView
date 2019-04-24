# loadingSkeletonView 简介
效果：
![Preview](http://g.recordit.co/xAV7KP5lCz.gif)

此代码是 [loader.swift](https://github.com/samhann/Loader.swift) 的OC版

#使用方法
- JKSkeletonLoader类拖进工程
- import "JKSkeletonLoader.h"
- 调用
```
//加载视图
[JKSkeletonLoader addLoaderToTargetView:self.tableView];
//移除视图
[JKSkeletonLoader removeLoaderFromTargetView:self.tableView];
```

后续还有待继续改进...
