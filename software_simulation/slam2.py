import math

import matplotlib.pyplot as plt
import numpy as np
from numpy import append, pi, sin, cos, tan
from PIL import Image, ImageDraw, ImageColor

ENV_MAP_SCALE = 5

class GridMap:
    def __init__(self, size=[1600, 1600], resolution=1.):
        self.size = np.array(size, dtype=np.int32)
        self.resolution = resolution
        self.ori_point = np.array([size[0]//2, size[1]//2])
        self.map = np.zeros(size)
        ## prob = exp(map) / (1 + exp(map))
        self.prob = np.ones(size) * 0.5
    
    def world2map(self, w_pts):
        return w_pts * self.resolution + self.ori_point

    def map2world(self, m_pts):
        return (m_pts - self.ori_point) / self.resolution

    ## return [M(p), dM(p)/dx, dM(p)/dy]
    def interpMapValueWithDerivatives(self, p):
        factx = p[0] - float(int(p[0])) # p[0] = 3.4 -> 0.4
        facty = p[1] - float(int(p[1]))
        p0 = self.prob[int(p[0]), int(p[1])]
        p1 = self.prob[int(p[0]) + 1, int(p[1])]
        p2 = self.prob[int(p[0]), int(p[1]) + 1]
        p3 = self.prob[int(p[0]) + 1, int(p[1]) + 1]

        M_p = (p0*(1-factx) + p1*factx) * (1-facty)+ \
            (p2*(1-factx) + p3*factx) * facty
        dx = (p1 - p0) * (1-facty) + (p3 - p2) * facty
        dy = (p2 - p0) * (1-factx) + (p3 - p1) * factx

        return [M_p, dx, dy]

    ## get all points in the line
    def get_line(self, start, end):
        x1 = int(start[0] + 0.5)
        y1 = int(start[1] + 0.5)
        x2 = int(end[0] + 0.5)
        y2 = int(end[1] + 0.5)
        dx = x2 - x1
        dy = y2 - y1
        k = -x1*y2 + x2*y1

        if dx == 0 and dy == 0:
            return np.array([[x1, y1]])

        pts = []
        if abs(dx) > abs(dy):
            if dx < 0:
                x1, y1, x2, y2 = x2, y2, x1, y1
                dx, dy = -dx, -dy
                k = -k
            for x in range(x1, x2 + 1):
                pts.append([x, int((x*dy + k)/dx + 0.5)])
        else: 
            if dy < 0:
                x1, y1, x2, y2 = x2, y2, x1, y1
                dx, dy = -dx, -dy
                k = -k
            for y in range(y1, y2 + 1):
                pts.append([int((y*dx - k)/dy + 0.5), y])
        
        return np.array(pts)

    ## update all points in the line
    def update_line(self, start, end, add):
        pts = self.get_line(start, end)

        for p in pts[:-1]:
            self.update(p, add)
        self.update(pts[-1], 1-add)

    ## update a single point
    def update(self, p, add):
        val = self.map[p[0], p[1]] + add
        ## avoid large float after exp
        if val > 50 or val < -50:
            return
        self.map[p[0], p[1]] = val
        exp_val = np.exp(val)
        self.prob[p[0], p[1]] = exp_val / (1 + exp_val)




## main class
class SLAM():
    def __init__(self, gridmap, gui):
        self.gridmap = GridMap()
        self.dimx = int(self.gridmap.size[1])

        radar_pos = np.array([0, 0, 0])
        self.scan_base = radar_pos

    ## correct pose with radar data
    def scan_match(self, map_idx, scan_world):
        pose = self.pose
        n = len(map_idx)
        sinRot = np.sin(pose[2])
        cosRot = np.cos(pose[2])
        H = np.zeros((3, 3))
        dTr = np.zeros((3, 1))
        for i in range(n):
            M_p, dx, dy = self.gridmap.interpMapValueWithDerivatives(map_idx[i, :])
            curPoint = scan_world[i,:] * self.gridmap.resolution
            funVal = 1. - M_p
            dTr[0] += dx * funVal
            dTr[1] += dy * funVal
            dphi = (-sinRot*curPoint[0] - cosRot*curPoint[1]) * dx + \
                (cosRot*curPoint[0] - sinRot*curPoint[1]) * dy
            dTr[2] += dphi * funVal
            H[0, 0] += dx**2
            H[0, 1] += dx * dy
            H[0, 2] += dx * dphi
            H[1, 1] += dy**2
            H[1, 2] += dy * dphi
            H[2, 2] += dphi**2
        
        H[1, 0] = H[0, 1]
        H[2, 0] = H[0, 2]
        H[2, 1] = H[1, 2]

        if H[0, 0] != 0. and H[1, 1] != 0. and H[2, 2] != 0.:
            delta_pose = np.matmul(np.linalg.inv(H), dTr)
            r = self.gridmap.resolution
            delta_pose[2, 0] = min(delta_pose[2, 0], 0.2)
            delta_pose[2, 0] = max(delta_pose[2, 0], -0.2)
            return np.array([delta_pose[0,0] / r, delta_pose[1,0] / r, delta_pose[2, 0]])
        else:
            return np.zeros(3)


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
                rho-=1
                measure = np.array([rho*cos(theta), rho*sin(theta)])
                break
        acc.append(measure)
    return acc

def prob2logodds(prob):
    return np.log(prob / (1 - prob))

def logodds2prob(logodds):
    odds = np.exp(logodds)
    return odds/(odds+1.0)

def imshow(arr, vmin=None, vmax=None):
    if vmin is None:
        vmin = np.min(arr)
    if vmax is None:
        np.max(arr)
    return plt.imshow(arr, cmap='gray', vmin=vmin, vmax=vmax)

def main():
    env_img = plt.imread("software_simulation/'-'.png")
    env_img = env_img[:, :, :3] # remove alpha channel
    env = 0.9 < np.linalg.norm(env_img, axis=2)
    env_shape = env.shape
    M = GridMap()

    xi = np.array([256, 256, 0.0]) # pos_x, pos_y, θ
    xi_moves = [np.array([15, 5, 0]),
                np.array([5, 10, 0]),
                np.array([10, -5, 0]),
                np.array([20, 10, 0]),
                ]

    xi_map = np.array([M.world2map(xi[0]), M.world2map(xi[1]), xi[2]])
    S_map = [M.world2map(si) for si in lidar(xi, env, 720, use_inf=False)]
    for si_map in S_map:
        absolute_si = si_map + xi[:2]
        M.update_line(xi[:2], absolute_si, 0.4)
    imshow(M.prob, 0, 1)
    plt.show()
    # xi_estimation = np.copy(xi)
    # for move in xi_moves:
    #     xi += move
    #     S = lidar(xi, env, 720, use_inf=False)
    #     for _ in range(10):
    #         delta_xi_estimation = scan_match(xi_estimation, S, M).reshape(-1)
    #         xi_estimation += delta_xi_estimation
    #     print(move/delta_xi_estimation)
    #     update_map(xi_estimation, S, M)
    #     # draw_lidar(xi, S, env, draw_env=False)
    #     draw_map(M)
    #     # plt.show()

if __name__ == '__main__':
    main()