include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  -- 传感器配置
  use_odometry = false,  -- 关闭外部里程计输入[5](@ref)
  use_nav_sat = false,
  use_landmarks = false,
  num_point_clouds = 1,
  imu_sampling_ratio = 1.0,  -- 全量使用IMU数据[8](@ref)

  -- 坐标系设置
  tracking_frame = "imu_base",  -- 确保与IMU硬件坐标系一致
  provide_odom_frame = false,   -- 禁用虚拟里程计坐标系[5](@ref)
}

--######################--
--### 前端参数深度优化 ###--
--######################--
TRAJECTORY_BUILDER_3D = {
  -- 运动去抖配置
  motion_filter = {
    max_time_seconds = 0.03,    -- 比常规四足机器人缩短3倍（默认0.1）
    max_distance_meters = 0.03, -- 距离阈值缩减至3cm（默认0.1）
    max_angle_radians = math.rad(0.5)
  },
  
  -- IMU融合增强
  imu_gravity_time_constant = 1.5,  -- 加速重力矢量收敛（默认10）[6](@ref)
  ceres_scan_matcher = {
    rotation_weight = 8.0,       -- 提高旋转约束权重（默认1）[8](@ref)
    translation_weight = 15.0    -- 提高平移约束权重（默认1）
  }
}

--######################--
--### 后端参数重构 ###--
--######################--
POSE_GRAPH = {
  optimization_problem = {
    -- 提升局部SLAM权重以补偿无里程计
    local_slam_pose_translation_weight = 5e3,  -- 原值1e3[5](@ref)
    local_slam_pose_rotation_weight = 5e3,
    
    -- 关闭里程计相关权重
    odometry_translation_weight = 0,  -- 原值1e3[5](@ref)
    odometry_rotation_weight = 0
  }
}