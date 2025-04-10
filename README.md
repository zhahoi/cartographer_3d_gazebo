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

```sh
# 安装依赖（供参考）
$ sudo apt-get update
$ sudo apt-get install -y python3-wstool python3-rosdep ninja-build stow
# 进入到工作空间目录
$ cd ..
$ sudo rosdep init
$ sudo update
$ rosdep install --from-paths src --ignore-src --rosdistro=noetic -y
$ catkin_make_isolated # 编译
```

 由于cartographer3d建图必须需要3d激光雷达和imu，必须得选择一个包含以上两种传感器的模型，在网上搜寻一番后，这篇博客[gazebo中给机器人添加16线激光雷达跑LIO-SAM](https://blog.csdn.net/weixin_40599145/article/details/126929222)里使用的机器人描述文件符合我的要求。该博客给出的机器人描述文件中还包含相机传感器，由于使用cartographer进行建图不需要相机，所以我在机器人描述文件中去除了该部分。



### Cartographer 3D建图

经过上述“基础配置”步骤，本仓库所依赖的环境便配置好了。如果希望实现Cartographer3D建图的话，在cartographer3d_ws工作空间下，需要分别开启不同的窗口界面，运行以下脚本文件：

- 打开gazebo仿真平台

```shell
$ source devel_isolated/setup.sh
$ roslaunch scout_gazebo scout_gazebo.launch
```

运行完launch文件之后，出现以下的界面：

![Gazebo建模](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/Gazebo%E5%BB%BA%E6%A8%A1.png)

![机器人模型](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E6%9C%BA%E5%99%A8%E4%BA%BA%E6%A8%A1%E5%9E%8B.png)



- 打开Cartographer 3D建图程序(需新建一个控制台窗口)

```sh
$ source devel_isolated/setup.sh
$ roslaunch cartographer_ros demo_revo_lds_3d.launch # 建图launch文件，实际执行的话可能需要执行两次才可以正确在rviz载入（暂时不知道原因）
```

![建图](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E5%BB%BA%E5%9B%BE.png)



- 启动控制机器人移动节点(需新建一个控制台窗口)

```sh
$ sudo apt install ros-noetic-teleop-twist-keyboard # 确保已安装ros包
$ rosrun teleop_twist_keyboard teleop_twist_keyboard.py
```

![进行建图](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E8%BF%9B%E8%A1%8C%E5%BB%BA%E5%9B%BE.png)

![建好的地图](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E5%BB%BA%E5%A5%BD%E7%9A%84%E5%9C%B0%E5%9B%BE.png)



- 保存建好的地图（新建一个控制台窗口）

  ```sh
  $ source devel_isolated/setup.bash
  $ rosservice call /finish_trajectory 0
  $ rosservice call /write_state "{filename: '${HOME}/Maps/0408.pbstream'}" # 提前在用户目录下新建一个"Maps"文件夹
  $ rosrun cartographer_ros cartographer_pbstream_to_ros_map -map_filestem=${HOME}/Maps/0408 -pbstream_filename=${HOME}//Maps/0408.pbstream -resolution=0.05  # 对建好的地图进行格式转换
  ```

  ![保存的地图](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E4%BF%9D%E5%AD%98%E7%9A%84%E5%9C%B0%E5%9B%BE.png)

为了方便后续进行定位导航，建议将建好的地图拷贝到*”/home/xxx/cartographer_ws/src/cartographer_ros/cartographer_ros/maps“*路径下。



### Cartographer 3D定位与导航

- 打开gazebo仿真平台

  ```sh
  $ source devel_isolated/setup.sh
  $ roslaunch scout_gazebo scout_gazebo.launch
  ```

- 打开Cartographer 3D定位程序（已修改为纯定位模式）（需新建一个控制台窗口）

  ```sh
  $ source devel_isolated/setup.sh
  $ roslaunch cartographer_ros demo_3d_localization.launch # 定位launch文件，实际执行的话可能需要执行两次才可以正确在rviz载入（暂时不知道原因）
  ```

  ![定位](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E5%AE%9A%E4%BD%8D.png)

- 打开move_base程序，用于进行机器人导航（需新建一个控制台窗口）

  ```sh
  $ source devel_isolated/setup.sh
  $ roslaunch cartographer_ros move_base.launch
  ```

  发布一个目标点，机器人会运行到该位置，完成导航。

![导航](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E5%AF%BC%E8%88%AA.png)

![机器人导航](https://github.com/zhahoi/cartographer_3d_gazebo/blob/main/docs/%E6%9C%BA%E5%99%A8%E4%BA%BA%E5%AF%BC%E8%88%AA.png)



### 补充说明

（1）建图相关

本仓库仿真的机器人包含Velodyne 16线激光雷达和imu传感器，其传感器的**frame_id**分别为***"velodyne"***和***"imu_base"***。为了能够进行3D建图，需要修改的配置文件为“**(find cartographer_ros)/urdf/my_backpack_3d.urdf**”，新建的my_backpack_3d.urdf文件是为了将不同的传感器和机器人主体联系在一起。

此外，新建了”revo_lds_3d.lua“文件，为了获得更好的建图效果，参考网上的资料和deepseek生成的内容。

（2）定位相关

参考了网上的教程，针对Cartographer设置了纯定位模式。如果需要使用自己新建的地图，需要修改“demo_3d_localization.launch”下的地图路径。



### 写在最后

创作不易，如果觉得这个仓库还可以的话，麻烦给一个star，这就是对我最大的鼓励。
