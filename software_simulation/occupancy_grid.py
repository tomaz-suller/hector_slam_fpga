import math

import matplotlib.pyplot as plt
import numpy as np
from numpy import pi, sin, cos, tan
from PIL import Image, ImageDraw

ENV_MAP_SCALE = 5

def imshow(arr, vmin=None, vmax=None):
    if vmin is None:
        vmin = np.min(arr)
    if vmax is None:
        np.max(arr)
    return plt.imshow(arr, cmap='gray', vmin=vmin, vmax=vmax)

def lidar(xi, env, n_measures=360, use_inf=False):
    sensor_px, sensor_py, psi = xi
    size_x, size_y = env.T.shape
    size_max = max(size_x, size_y)
    acc = []
    for theta in np.linspace(0, 2*pi, n_measures):
        theta += psi
        measure = np.array([np.Inf if use_inf else size_max, theta])
        for rho in range(1, size_max+1):
            check_px = math.ceil(sensor_px + rho*cos(theta))
            check_py = math.ceil(sensor_py + rho*sin(theta))
            if (0 < check_px <= size_x and
                    0 < check_py <= size_y and
                    not env[check_py, check_px]):
                measure = np.array([rho-1, theta])
                break
        acc.append(measure)
    return acc

def reduce_octant_arg(theta):
    y_flip = False
    x_flip = False
    identity_flip = False # refleccao em relacao a identidade

    reduced_theta = theta
    if reduced_theta >= np.pi:
        reduced_theta = 2*np.pi - reduced_theta # 2° metade pra 1° metade
        y_flip = True
    if reduced_theta >= np.pi/2:
        reduced_theta = np.pi - reduced_theta # 2° quadrante pro 1° quadrante
        x_flip = True
    if reduced_theta > np.pi/4:
        reduced_theta = np.pi/2 - reduced_theta # 2° octante pro 1° octante
        identity_flip = True

    return reduced_theta, y_flip, x_flip, identity_flip

def unreduce_octan_cell(cell_pos, y_flip, x_flip, identity_flip):
    px, py = cell_pos

    if identity_flip:
        px, py = py, px
    if x_flip:
        px = -px
    if y_flip:
        py = -py

    return np.array([px, py])

def bresenham_polar(rho, theta):
    reduced_theta, y_flip, x_flip, id_flip = reduce_octant_arg(theta)
    raw_cells = [(x, round(x*tan(reduced_theta)))
                  for x in range(0, round(rho*cos(reduced_theta)) + 1)]
    cells = [unreduce_octan_cell(cell, y_flip, x_flip, id_flip) for cell in raw_cells]

    return cells

def polar2rectangular(rho, theta):
    return rho*cos(theta), rho*sin(theta)

def translate(origin, point):
    return origin + point

def polar2rectangularTranslated(origin_x, origin_y, rho, theta):
    return translate((origin_x, origin_y), polar2rectangular(rho, theta))

def draw_lidar(xi, lidar_measures, env, draw_env=True, draw_scan=True):
    SENSOR_RADIUS = 8
    READING_RADIUS = 2
    px, py, psi = xi
    intersections = [polar2rectangularTranslated(px, py, *m) for m in lidar_measures if not np.isinf(m[1])]
    int_intersections = np.floor(intersections).astype(int)

    if draw_env:
        im = Image.fromarray(env*255)
    else:
        im = Image.fromarray(np.ones_like(env)*255)

    draw = ImageDraw.Draw(im)

    if draw_scan:
        draw.ellipse((px-SENSOR_RADIUS/2, py-SENSOR_RADIUS/2, px+SENSOR_RADIUS/2, py+SENSOR_RADIUS/2),
                      fill=(255, 0, 0))
        for intersection in int_intersections:
            draw.line((px, py, *intersection), fill=(128, 128, 128))
            draw.ellipse((intersection[0]-READING_RADIUS/2, intersection[1]-READING_RADIUS/2, intersection[0]+READING_RADIUS/2, intersection[1]+READING_RADIUS/2),
                          fill=(0, 255, 0))

    return im

def in_matrix(point, matrix):
    shape = matrix.shape
    return (0 <= point[0] < shape[0]) and (0 <= point[1] < shape[1])

def prob2logodds(prob):
    return np.log(prob / (1 - prob))

def logodds2prob(logodds):
    odds = np.exp(logodds)
    return odds/(odds+1.0)

def update_map(xi, S, M):
    FREE_FACTOR = 0.4
    OCCUPIED_FACTOR = 0.6

    absolute_cell = xi[:2].astype(int)
    for si in S:
        cells = []
        relative_cells = bresenham_polar(*si)
        for rcell in relative_cells:
            absolute_cell_pos = absolute_cell + rcell
            if in_matrix(absolute_cell_pos, M):
                cells.append(absolute_cell_pos)
        empty_cells, occuped_cells = cells[:-1], cells[-1]
        for ecell in empty_cells:
            M[ecell[0], ecell[1]] += prob2logodds(FREE_FACTOR)
        M[occuped_cells[0], occuped_cells[1]] += prob2logodds(OCCUPIED_FACTOR)

def draw_map(M):
    CHECK_VALUE = 2
    imshow(-M.T, vmin=-CHECK_VALUE, vmax=CHECK_VALUE)

def world2map(p):
    return p/ENV_MAP_SCALE

def map2world(p):
    return p*ENV_MAP_SCALE

def main():
    env_img = plt.imread("software_simulation/'-'.png")
    env_img = env_img[:, :, :3] # remove alpha channel
    env = 0.9 < np.linalg.norm(env_img, axis=2)
    env_shape = env.shape
    M = np.zeros((env_shape[0]//ENV_MAP_SCALE, env_shape[1]//ENV_MAP_SCALE))
    xi = np.array([256, 256, 0.0]) # pos_x, pos_y, θ
    xi_moves = [np.array([15, 5, 0]),
                np.array([5, 10, 0]),
                np.array([10, -5, 0]),
                np.array([20, 10, 0]),
                ]

    S = lidar(xi, env, 720, use_inf=False)
    S_map = [np.array([world2map(si[0]), si[1]]) for si in S]
    xi_map = np.array([world2map(xi[0]), world2map(xi[1]), xi[2]])
    update_map(xi_map, S_map, M)
    draw_map(M)
    plt.show()

    for move in xi_moves:
        xi += move
        S = lidar(xi, env, 720, use_inf=False)
        S_map = [np.array([world2map(si[0]), si[1]]) for si in S]
        update_map(xi, S_map, M)
        draw_lidar(xi, S, env, draw_env=False)
        draw_map(M)
        plt.show()

if __name__ == '__main__':
    main()
