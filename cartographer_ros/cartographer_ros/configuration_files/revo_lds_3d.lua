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
  provide_odom_frame = false,
  publish_frame_projected_to_2d = false,
  use_pose_extrapolator = true,    --zhushi

  use_odometry = false,
  use_nav_sat = false,
  use_landmarks = false,
  num_laser_scans = 0,
  num_multi_echo_laser_scans = 0,
  num_subdivisions_per_laser_scan = 1,
  num_point_clouds = 1,

  lookup_transform_timeout_sec = 0.1,
  submap_publish_period_sec = 0.3,
  pose_publish_period_sec = 5e-3,
  trajectory_publish_period_sec = 30e-3,
  rangefinder_sampling_ratio = 1.,
  odometry_sampling_ratio = 1.,
  fixed_frame_pose_sampling_ratio = 1.,
  imu_sampling_ratio = 1.,
  landmarks_sampling_ratio = 1.,
}
  -- 启用3D建图
  MAP_BUILDER.use_trajectory_builder_3d = true

  TRAJECTORY_BUILDER_3D.num_accumulated_range_data = 2   --1

  -- 对激光雷达数据过滤设置（基于Velydone16特点）
  TRAJECTORY_BUILDER_3D.min_range = 0.5
  TRAJECTORY_BUILDER_3D.max_range = 20.0
  TRAJECTORY_BUILDER_3D.voxel_filter_size = 0.1

  -- 设置在线扫描匹配的使用策略
  TRAJECTORY_BUILDER_3D.use_online_correlative_scan_matching = false
  TRAJECTORY_BUILDER_3D.ceres_scan_matcher.translation_weight = 5
  TRAJECTORY_BUILDER_3D.ceres_scan_matcher.rotation_weight = 4

  -- 针对IMU快速变化情况（震荡）调整估计参数
  TRAJECTORY_BUILDER_3D.imu_gravity_time_constant = 0.5

  -- 后端优化参数调整：更频繁进行全局优化
  MAP_BUILDER.num_background_threads = 5  -- 可根据平台性能设置
  POSE_GRAPH.optimization_problem.huber_scale = 5e2
  POSE_GRAPH.optimize_every_n_nodes = 45   -- 优化节点数降低，频率更高

  POSE_GRAPH.constraint_builder.sampling_ratio = 0.03  
  POSE_GRAPH.optimization_problem.ceres_solver_options.max_num_iterations = 16
  POSE_GRAPH.constraint_builder.min_score = 0.6
  POSE_GRAPH.constraint_builder.global_localization_min_score = 0.60

  -- 根据实际震荡情况增强对IMU数据的依赖：
  POSE_GRAPH.optimization_problem.odometry_translation_weight = 1e3
  POSE_GRAPH.optimization_problem.odometry_rotation_weight = 1e3
  POSE_GRAPH.optimization_problem.acceleration_weight = 1e3
  POSE_GRAPH.optimization_problem.rotation_weight = 1e5

return options