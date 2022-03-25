using LinearAlgebra: norm, I
using PlutoUI: Slider
using Plots: plot, scatter
using ImageIO, FileIO, ImageDraw, Images, ImageView


# Simulate lidar measure
function lidar(ξ, M; Δθ=π/360, use_inf=false)
	sensor_px, sensor_py, θ0 = ξ
	size_x, size_y = size(M')
	size_max = max(size_x, size_y)
	acc = Tuple{Float64, Float64}[]
	for θ = 0:Δθ:2π
		θ += θ0 
		measure = (use_inf ? Inf : size_max, θ)
		for ρ = 1:size_max
			check_px = trunc(Int, sensor_px + ρ*cos(θ))
			check_py = trunc(Int, sensor_py + ρ*sin(θ))
			if (0 < check_px <= size_x && 
				0 < check_py <= size_y && 
				!M[check_py, check_px])
				measure = (ρ-1, θ)
				break
			end
		end
		push!(acc, measure)
	end
	return acc
end

function bresenham_polar(ρ, θ)
	function reduce_octant_arg(θ)
		y_flip = false
		x_flip = false
		id_flip = false # refleccao em relacao a identidade

		θ_r = θ
		if θ_r >= π
			θ_r = 2π - θ_r # 2° metade pra 1° metade
			y_flip = true
		end
		if θ_r >= π/2
			θ_r = π - θ_r # 2° quadrante pro 1° quadrante
			x_flip = true
		end
		if θ_r >= π/4
			θ_r = π/2 - θ_r # 2° octante pro 1° octante
			id_flip = true
		end
		return θ_r, y_flip, x_flip, id_flip
	end
	
	function unreduce_octan_point(point, y_flip, x_flip, id_flip)
		px, py = point
		if id_flip
			px, py = py, px
		end
		if x_flip
			px = -px
		end if y_flip
			py = -py
		end
		return (px, py)
	end

	θ_r, y_flip, x_flip, id_flip = reduce_octant_arg(θ)
	raw_points = [(x,trunc(Int, x*tan(θ_r))) for x in 1:trunc(Int, ρ*cos(θ_r))]
	points = [unreduce_octan_point(point, y_flip, x_flip, id_flip) for point in raw_points]
	return points
end

polar2rectangular(ρ, θ) = ρ*cos(θ), ρ*sin(θ)
translate(origin, point) = origin .+ point
polar2rectangularTranslated(origin_x, origin_y, ρ, θ) = translate((origin_x, origin_y), polar2rectangular(ρ, θ))

function draw_lidar(ξ, lidar_measures, env; draw_env=true, draw_lines=true, draw_circle=true, draw_points=true)
	px, py, θ0 = ξ
	intersections = [map(x -> trunc(Int, x), polar2rectangularTranslated(px, py, m...)) for m in lidar_measures if m[1] != Inf]
	line_intersecion = [LineSegment(Point(px, py), Point(i)) for i in intersections]
	frame = draw_env ? RGB.(env) : RGB.(trues(size(env)))
	draw_lines && draw!(frame, line_intersecion, RGB(0.5N0f8, 0.5N0f8, 0.5N0f8))
	draw_circle && draw!(frame, CirclePointRadius(Point(px, py), 8), RGB(1, 0, 0))
	draw_points && draw!(frame, [CirclePointRadius(Point(i), 2) for i in intersections], RGB(0, 1, 0))
	return frame
end

prob2logodds(prob) = log(prob / (1 - prob))
FREE_FACTOR = 0.4
OCCUPIED_FACTOR = 0.6

function update_map(ξ, S, M)
	for si in S
		relative_pixeis = bresenham_polar(si...)
		absolute_pixeis = map((p) -> p .+ ξ[1:2], relative_pixeis)
		pixeis = filter((p) -> 0 < p[1] < size(M)[2] && 0 < p[2] < size(M)[2], absolute_pixeis)
		empty_pixeis, occuped_pixel = pixeis[begin:(end-1)], pixeis[end]
		for pixel in empty_pixeis
			M[pixel...] += prob2logodds(FREE_FACTOR)
		end
		M[occuped_pixel...] += prob2logodds(OCCUPIED_FACTOR)
	end
end

function draw_map(ξ,M)
	CHECK_VALUE = 2
	function map2pixel(x)
		if x < 0
			return 0.5 + 0.5*min(abs(x), CHECK_VALUE)/CHECK_VALUE
		elseif x > 0
			return 0.5 - 0.5*min(abs(x), CHECK_VALUE)/CHECK_VALUE
		else
			return 0.5
		end
	end
	Gray.(map2pixel.(M'))
end

function main()
	env_img = load("/home/guiss/Projetos/Comp5/LabDig1/mirabolante/maze.png")
	env = 0.9 .< norm.(env_img)
	M = fill(0.0, size(env))
	Gray.(env)

	ξ1 = (px, py, θ0) # pos_x, pos_y, θ
	s1 = lidar(ξ1, env, Δθ=π/45, use_inf=false)
	update_map(ξ1, s1, M)
	draw_lidar(ξ1, s1, env, draw_env=false)
	imshow(draw_map(ξ1,  M))
end

main()
