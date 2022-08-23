module CoherentNoiseViewer

using GLMakie
#GLMakie.activate!()

using Observables

using Revise
using CoherentNoise

const r = -2:0.005:2

let fvals = Observable(zeros(length(r), length(r)))

  global function set_fvals()
    # some hard-coded sampler
    s = opensimplex2s_3d(seed=1)
    println("new fvals")
    # evaluate the noise for each input coordinate and remap the output values to the [0,1] range
    fvals[] = [sample(s, u, v, 0.0) * 0.5 + 0.5 for u in r, v in r]  
    return fvals
  end
end

function viewnoise()
  
  cncb = Revise.add_callback(set_fvals, [], [CoherentNoise])
  fvals = set_fvals()
  
  # make the plot
  fig, ax, pltobj = surface(r, r, fvals, color=fvals,
  colormap=:inferno, colorrange=(0, 1),
  backlight=1.0, highclip=:black,
  figure=(; resolution=(1200, 800), fontsize=20))
  Colorbar(fig[1, 2], pltobj, height=Relative(0.25))
  colsize!(fig.layout, 1, Aspect(1, 16 / 9))
  
  # show the plot
  display(fig)
  
  # optional, animate the 3D sampler by incrementing the Z axis
  # highly inefficient -- allocates a new array each frame. I tried to fix this but Makie wasn't
  # seeing the changes.
  #=z::Float64 = 0.0
  while true
    global z += 0.02
    pltobj[3] = [sample(s, u, v, z) * 0.5 + 0.5 for u in x, v in y]
    sleep(1/60)
  end=#
  cncb
end

end