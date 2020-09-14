package samples

import (
	"gray/figure"
	"gray/multid"
	"gray/oned"
	"math"
	"testing"
)

func Test_plane_scene_sample(t *testing.T) {
	floor := figure.MakePlaneTM(
		multid.IdentityMatrix,
		figure.MakeMaterialBuilder().
			SetColor(oned.Color{0.7, 0.9, 0.8}).
			Build())

	back := figure.MakePlaneTM(
		multid.Translation(0, 0, 3).
			Multiply(multid.RotationX(-math.Pi/2)),
		figure.MakeMaterialBuilder().
			SetColor(oned.Color{0.6, 0.1, 0.2}).
			Build())

	left := figure.MakeSphereTM(
		multid.Translation(-1.5, 0.33, -0.75).
			Multiply(multid.Scaling(1, 0.33, 0.33)),
		figure.MakeMaterialBuilder().
			SetColor(oned.Color{1, 0.8, 0.1}).
			SetDiffuse(0.7).
			SetSpecular(0.3).Build())

	middle := figure.MakeSphereTM(
		multid.Translation(-0.5, 1, 0.2),
		figure.MakeMaterialBuilder().
			SetColor(oned.Color{0.1, 1, 0.5}).
			SetDiffuse(0.7).
			SetSpecular(0.3).Build())

	right := figure.MakeSphereTM(
		multid.Translation(1.5, 0.5, -0.5).
			Multiply(multid.Scaling(0.5, 0.8, 0.5)),
		figure.MakeMaterialBuilder().
			SetColor(oned.Color{0.5, 1, 0.1}).
			SetDiffuse(0.7).
			SetSpecular(0.3).Build())

	light := figure.PointLight{oned.Point{-10, 10, -10}, oned.White}
	world := figure.World{light, []figure.Shape{floor, back, left, middle, right}}
	camera := figure.MakeCamera(500, 250, math.Pi/3,
		figure.ViewTransform(oned.Point{0, 3, -6}, oned.Point{0, 1, 0}, oned.Vector{0, 1, 0}))

	canvas := camera.Render(world)

	canvas.MustToPNG("plane_scene_sample_test.png")
}
