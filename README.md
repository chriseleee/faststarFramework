# faststarFramework
faststarVideoFramework
前面写到[iOS实现边下边播](https://www.jianshu.com/p/fa69aae05417)，有个被偏方取代的问题，就是部分mp4中moov位于末尾无法实现边下边播的问题。
先找到了解决方案，并写了个库供大家使用:
```
//  mp4的moov置前

#import <Foundation/Foundation.h>

@interface FaststarVideoTool : NSObject

/*
 from: 视频原始目录
 toPath: 处理后视频位置
*/
+(void)makeVideoFasterFrom:(NSString*)from toPath:(NSString*)toPath;
/*
 path: 视频目录
 */
+(void)makeVideoFasterWithPath:(NSString*)path;

@end
```
使用方法：
导入`faststarVideo.framework`库
```
#import <faststarVideo/faststarVideo.h>
/*
 from: 视频原始目录
 toPath: 处理后视频位置
*/
[FaststarVideoTool makeVideoFasterFrom:self.path toPath:toPath];
```
toPath就是我们处理后的数据。
更多关于播放器的内容可以参考:[iOS实现边下边播](https://www.jianshu.com/p/fa69aae05417)
