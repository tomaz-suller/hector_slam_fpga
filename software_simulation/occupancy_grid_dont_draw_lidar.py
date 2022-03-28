import math
from typing import Iterable, Any

import matplotlib.pyplot as plt
import numpy as np

from fixed_point import BinaryFixedPoint

# Parameters
RIGHT_SHIFTS_WORLD_TO_MAP = 0
LEFT_SHIFTS_MAP_TO_WORLD = RIGHT_SHIFTS_WORLD_TO_MAP
MAP_CELLS_PER_WORLD_CELL = 2**RIGHT_SHIFTS_WORLD_TO_MAP
PROBABILITY_UPDATE_FACTOR = 0.6
# Constants
BINARY_PI = BinaryFixedPoint.from_numeric(np.pi)
ZERO = BinaryFixedPoint.from_numeric(0)

# TODO Implement
# @dataclass
# class 3dPoint:
#     x: BinaryFixedPoint
#     y: BinaryFixedPoint
#     theta: BinaryFixedPoint
# @dataclass
# class 2dPoint:
#     x: BinaryFixedPoint
#     y: BinaryFixedPoint

def main():
    environment_img = plt.imread("software_simulation/maze.png")
    environment_img = environment_img[:, :, :3] # Remove alpha channel
    environment = 0.9 < np.linalg.norm(environment_img, axis=2)
    environment_shape = environment.shape

    occupancy_grid = np.zeros((environment_shape[0]//MAP_CELLS_PER_WORLD_CELL,
                               environment_shape[1]//MAP_CELLS_PER_WORLD_CELL))
    current_position = numeric_iter_to_binary([256, 256, 0.0])
    movements = [numeric_iter_to_binary([0, 0, 0.0]),
                 numeric_iter_to_binary([15, 5, 0.0]),
                 numeric_iter_to_binary([5, 10, 0.0]),
                 numeric_iter_to_binary([10, -5, 0.0]),
                 numeric_iter_to_binary([20, 10, 0.0])]

    try:
        for movement in movements:
            for i, movement_coordinate in enumerate(movement):
                current_position[i] = current_position[i] + movement_coordinate
            relative_lidar_scans = lidar(current_position, environment, 720)
            current_map_position = world_to_map(current_position)
            update_grid(current_map_position, relative_lidar_scans, occupancy_grid)
        draw_grid(occupancy_grid,
                  fix_scale=True,
                  xlim=[150, 385],
                  ylim=[140, 325])
        plt.show()
    except KeyboardInterrupt:
        return

def lidar(current_position: list[BinaryFixedPoint],
          environment: np.ndarray,
          n_measures: int = 360) -> list[list[BinaryFixedPoint, BinaryFixedPoint]]:
    sensor_px, sensor_py, psi = [coordinate.to_int() for coordinate in current_position]
    size_x, size_y = environment.T.shape
    size_max = max(size_x, size_y)
    acc = []
    for theta in np.linspace(0, 2*np.pi, n_measures):
        theta = theta + psi
        measure = (size_max, theta)
        for rho in range(1, size_max+1):
            check_px = math.ceil(sensor_px + rho*np.cos(theta))
            check_py = math.ceil(sensor_py + rho*np.sin(theta))
            if (0 < check_px <= size_x and
                    0 < check_py <= size_y and
                    not environment[check_py, check_px]):
                measure = numeric_iter_to_binary([rho-1, theta])
                break
        acc.append(measure)
    return acc

def update_grid(current_position: list[BinaryFixedPoint],
                relative_lidar_scans: list[list[BinaryFixedPoint]],
                grid: np.ndarray) -> None:

    origin_x = current_position[0]
    origin_y = current_position[1]
    for scan in relative_lidar_scans:
        relative_cells = bresenham_polar(*scan)
        for i, (relative_x, relative_y) in enumerate(relative_cells): # TODO continue from here
            x_index = (origin_x + relative_x).to_int()
            y_index = (origin_y + relative_y).to_int()
            if i == len(relative_cells)-1: # Only the last cell is occupied
                grid[y_index, x_index] += 1
            else:
                grid[y_index, x_index] -= 1

def bresenham_polar(rho: BinaryFixedPoint, theta:BinaryFixedPoint) -> list[list[BinaryFixedPoint]]:
    reduced_theta, y_flip, x_flip, id_flip = reduce_octant_angle(theta)
    reduced_theta = max(reduced_theta, ZERO)
    reduced_theta_float = reduced_theta.to_float()
    tan_reduced_theta = BinaryFixedPoint.from_numeric(np.tan(reduced_theta_float))
    cos_reduced_theta = BinaryFixedPoint.from_numeric(np.cos(reduced_theta_float))

    cells = []
    final_cell_index = world_coordinate_to_map(rho*cos_reduced_theta).to_int()
    # TODO Check whether adding one to the end of the range makes a difference
    for i in range(0, final_cell_index):
        binary_i = BinaryFixedPoint.from_numeric(i)
        raw_cell = [binary_i,
                    world_coordinate_to_map(binary_i*tan_reduced_theta)]
        cells.append(unreduce_cell(raw_cell, y_flip, x_flip, id_flip))

    return cells

def reduce_octant_angle(theta: BinaryFixedPoint) -> tuple[BinaryFixedPoint, bool, bool, bool]:
    y_flip = False
    x_flip = False
    identity_flip = False # Reflection around the identity line

    reduced_theta = theta
    if reduced_theta >= BINARY_PI:
        reduced_theta = (BINARY_PI<<1) - reduced_theta # 2° metade pra 1° metade
        y_flip = True
    if reduced_theta >= (BINARY_PI>>1): # pi/2
        reduced_theta = BINARY_PI - reduced_theta # 2° quadrante pro 1° quadrante
        x_flip = True
    if reduced_theta > (BINARY_PI>>2):
        reduced_theta = (BINARY_PI>>1) - reduced_theta # 2° octante pro 1° octante
        identity_flip = True

    return reduced_theta, y_flip, x_flip, identity_flip

def unreduce_cell(cell: list[BinaryFixedPoint],
                  y_flip: bool,
                  x_flip: bool,
                  identity_flip: bool) -> list[BinaryFixedPoint]:
    x, y = cell

    if identity_flip:
        x, y = y, x
    if x_flip:
        x = -x
    if y_flip:
        y = -y

    return [x, y]

def draw_grid(grid: np.ndarray,
              fix_scale: bool = False,
              xlim: list[int] = None,
              ylim: list[int] = None,) -> None:
    vmin, vmax = None, None
    if fix_scale:
        vmin, vmax = -1, 1
    cell_to_probability = lambda x: prob_to_logodds(PROBABILITY_UPDATE_FACTOR) * x
    grid_to_probability = np.vectorize(cell_to_probability)
    probability_grid = grid_to_probability(grid)
    # pylint: disable=invalid-unary-operand-type
    cropped_probability_grid = crop_array(probability_grid, xlim, ylim)
    imshow(-cropped_probability_grid, vmin, vmax)

def crop_array(array: np.ndarray,
               xlim: list[int],
               ylim: list[int]) -> np.ndarray:
    return array[ylim[0]:ylim[1], xlim[0]:xlim[1]]

def imshow(arr: np.ndarray,
           vmin: int | float = None,
           vmax: int | float = None) -> None:

    if vmin is None:
        vmin = np.min(arr)
    if vmax is None:
        np.max(arr)
    return plt.imshow(arr, cmap='gray', vmin=vmin, vmax=vmax)

def world_to_map(point: list[BinaryFixedPoint]) -> list[BinaryFixedPoint]:
    return [
        world_coordinate_to_map(point[0]),
        world_coordinate_to_map(point[1]),
        point[2], # Angular coordinate is not affected
    ]

def world_coordinate_to_map(coordinate: BinaryFixedPoint) -> BinaryFixedPoint:
    return BinaryFixedPoint.from_numeric(
        (coordinate>>RIGHT_SHIFTS_WORLD_TO_MAP).to_int())

def map_to_world(point: list[BinaryFixedPoint]) -> list[BinaryFixedPoint]:
    return [
        point[0] << LEFT_SHIFTS_MAP_TO_WORLD,
        point[1] << LEFT_SHIFTS_MAP_TO_WORLD,
        point[2], # Angular coordinate is not affected
    ]

def prob_to_logodds(prob):
    return np.log(prob / (1 - prob))

def logodds_to_prob(logodds):
    odds = np.exp(logodds)
    return odds/(odds+1.0)

def numeric_iter_to_binary(numeric_iterable: Iterable[Any]) -> list[BinaryFixedPoint]:
    return [numeric_to_binary(numeric) for numeric in numeric_iterable]

def numeric_to_binary(numeric) -> BinaryFixedPoint:
    return BinaryFixedPoint.from_numeric(numeric)

if __name__ == '__main__':
    main()
