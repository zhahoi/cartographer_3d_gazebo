-- Copyright 2016 The Cartographer Authors
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--      http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

include "map_builder.lua"
include "trajectory_builder.lua"

options = {
  map_builder = MAP_BUILDER,
  trajectory_builder = TRAJECTORY_BUILDER,
  map_frame = "map",
  -- 下面两个frame需要修改为雷达的 坐标系，通常为laser
  -- 如果有imu 需要将 tracking_frame 更改为 imu的那个link
  tracking_frame = "imu_base",
  published_frame = "base_link",
  odom_frame = "odom",
  provide_odom_frame = true,
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,    --zhushi

  use_odometry = false,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 0,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 1,

  lookup_transform_timeout_sec = 0.2,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 0.8,
  landmarks_sampling_ratio = 1.,
}
  -- 启用3D建图
  MAP_BUILDER.use_trajectory_builder_3d = true
  MAP_BUILDER.num_background_threads = 5

  TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 1

  -- 保持激光雷达滤波参数与建图时一致，但后续更新不会修改地图
  TRAJECTORY_BUILDER_3D.min_range = 0.5
  TRAJECTORY_BUILDER_3D.max_range = 20.0
  TRAJECTORY_BUILDER_3D.voxel_filter_size = 0.1

  -- 设置在线扫描匹配的使用策略
  TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = true

  -- 针对IMU快速变化情况（震荡）调整估计参数
  TRAJECTORY_BUILDER_3D.imu_gravity_time_constant = 0.5

  -- 禁用新的全局约束构造（不添加新的闭环约束）
  POSE_GRAPH.optimize_every_n_nodes = 30
  POSE_GRAPH.constraint_builder.sampling_ratio = 0.05
  POSE_GRAPH.constraint_builder.min_score = 0.55

  -- 根据实际震荡情况增强对IMU数据的依赖：
  POSE_GRAPH.optimization_problem.odometry_translation_weight = 1e3
  POSE_GRAPH.optimization_problem.huber_scale = 5e2
  POSE_GRAPH.optimization_problem.odometry_rotation_weight = 1e3
  POSE_GRAPH.optimization_problem.acceleration_weight = 1e3
  POSE_GRAPH.optimization_problem.rotation_weight = 1e4

return options


