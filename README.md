# cartographer_3d_gazebo
在Gazebo仿真平台进行Cartographer 3D的建图和导航仿真。（Velodyne 16 + IMU)



### 写在前面

创建本仓库的目的是为了帮助那些希望学习使用Cartographer进行3D建图，随后可以进一步用于进行机器人定位和导航的朋友。网上针对Cartographer算法进行2D和3D建图的博客和资料有很多，但是往往只涉及建图、或者定位等一小部分，本仓库的配置可以让你打通整个从**建图->定位->导航**整个流程，可以避免让大家踩很多坑。毕竟我自己先淋过雨，希望给大家撑起一把伞。另外，梳理该篇文档的内容，也为了加深对算法的理解。



### 测试环境

- 测试系统：ubuntu 20.04
- ros版本： noetic

1. 仓库文件描述：

```sh
hit@ubuntu:~/cartographer_ws/src$ tree -L 1
.
├── cartographer  -- cartographer算法库
├── cartographer_ros  --cartographer ros包，建图和定位的设置均在该文件夹下
├── CMakeLists.txt -> /opt/ros/noetic/share/catkin/cmake/toplevel.cmake
├── scout_gazebo -- 用于进行机器人仿真
└── velodyne_simulator -- 用于仿真velodyne16线激光雷达的描述文件

```



### 基础配置

1. 先创建一个工作空间，将本仓库的代码拷贝到src文件夹下

```sh
$ mkdir -p cartographer3d_ws/src
$ cd cartographer3d_ws/src/
$ catkin_init_workspace
$ git clone https://github.com/zhahoi/cartographer_3d_gazebo.git
```

   2.配置本工程的运行环境

”cartographer"具体的配置细节，这里不再赘述，大家可以参考该篇博客文章[Ubuntu20.04+ros-noetic配置Cartographer](https://blog.csdn.net/GFCLJY/article/details/141992799)，我是根据该篇文章的设置，配置成功的。(因为本仓库已经包含了cartographer和cartographer_ros，大家仅需要参考该篇博客将依赖装好就行)

 由于cartographer3d建图必须需要3d激光雷达和imu，必须得选择一个包含以上两种传感器的模型，在网上搜寻一番后，这篇博客[gazebo中给机器人添加16线激光雷达跑LIO-SAM](https://blog.csdn.net/weixin_40599145/article/details/126929222)里使用的机器人描述文件符合我的要求。该博客给出的机器人描述文件中还包含相机传感器，由于使用cartographer进行建图不需要相机，所以我在机器人描述文件中去除了该部分。



