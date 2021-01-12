package figure

import (
	"github.com/oleg/raytracer-go/ddddf"
	"github.com/oleg/raytracer-go/geom"
	"github.com/oleg/raytracer-go/mat"
	"math"
	"sort"
)

const MaxDepth = 4

type PointLight struct {
	Position  geom.Point
	Intensity geom.Color
}

type World struct {
	Light   PointLight
	Objects []ddddf.Shape
}

func (w *World) ColorAt(r ddddf.Ray, remaining uint8) geom.Color {
	xs := w.Intersect(r)
	if ok, hit := Hit(xs); ok {
		return w.ShadeHit(PrepareComputations(hit, r, xs), remaining)
	}
	return geom.Black
}

func (w *World) Intersect(ray ddddf.Ray) ddddf.Inters {
	r := make([]ddddf.Inter, 0, 10)
	for _, shape := range w.Objects {
		r = append(r, ddddf.Intersect(shape, ray)...)
	}
	sort.Slice(r, func(i, j int) bool {
		return r[i].Distance < r[j].Distance
	})
	return r
}

func (w *World) ShadeHit(comps Computations, remaining uint8) geom.Color {
	shadowed := w.IsShadowed(comps.OverPoint)
	surface := Lighting(
		comps.Object.Material(),
		comps.Object,
		w.Light,
		comps.OverPoint,
		comps.EyeV,
		comps.NormalV,
		shadowed)
	reflected := w.ReflectedColor(comps, remaining)
	refracted := w.RefractedColor(comps, remaining)
	material := comps.Object.Material()
	if material.Reflective > 0 && material.Transparency > 0 {
		reflectance := Schlick(comps)
		return surface.
			Add(reflected.MultiplyByScalar(reflectance)).
			Add(refracted.MultiplyByScalar(1 - reflectance))
	}
	return surface.
		Add(reflected).
		Add(refracted)
}

func (w *World) IsShadowed(point geom.Point) bool {
	v := w.Light.Position.SubtractPoint(point)
	distance := v.Magnitude()
	direction := v.Normalize()
	intersections := w.Intersect(ddddf.Ray{point, direction})
	hit, inter := Hit(intersections)
	return hit && inter.Distance < distance
}

func (w *World) ReflectedColor(comps Computations, remaining uint8) geom.Color {
	if remaining <= 0 {
		return geom.Black
	}
	reflective := comps.Object.Material().Reflective
	if reflective == 0 {
		return geom.Black
	}
	reflectRay := ddddf.Ray{comps.OverPoint, comps.ReflectV}
	color := w.ColorAt(reflectRay, remaining-1)
	return color.MultiplyByScalar(reflective)
}

func (w *World) RefractedColor(comps Computations, remaining uint8) geom.Color {
	if remaining <= 0 {
		return geom.Black
	}
	transparency := comps.Object.Material().Transparency
	if transparency == 0 {
		return geom.Black
	}
	nRatio := comps.N1 / comps.N2
	cosI := comps.EyeV.Dot(comps.NormalV)
	sin2t := math.Pow(nRatio, 2) * (1 - math.Pow(cosI, 2))
	if sin2t > 1 {
		return geom.Black
	}

	cosT := math.Sqrt(1.0 - sin2t)
	direction := comps.NormalV.MultiplyScalar(nRatio*cosI - cosT).
		SubtractVector(comps.EyeV.MultiplyScalar(nRatio))

	refractRay := ddddf.Ray{comps.UnderPoint, direction}
	return w.ColorAt(refractRay, remaining-1).MultiplyByScalar(transparency)
}

func Lighting(material *mat.Material, object ddddf.Shape, light PointLight, point geom.Point, eyev geom.Vector, normalv geom.Vector, inShadow bool) geom.Color {
	var color geom.Color
	if material.Pattern != nil {
		color = mat.PatternAtShape(material.Pattern, object, point)
	} else {
		color = material.Color
	}
	effectiveColor := color.Multiply(light.Intensity)
	lightv := light.Position.SubtractPoint(point).Normalize()
	ambient := effectiveColor.MultiplyByScalar(material.Ambient)
	lightDotNormal := lightv.Dot(normalv)
	if lightDotNormal < 0 || inShadow {
		return ambient
	}
	diffuse := effectiveColor.MultiplyByScalar(material.Diffuse).MultiplyByScalar(lightDotNormal)
	reflectv := lightv.Negate().Reflect(normalv)
	reflectDotEye := reflectv.Dot(eyev)
	if reflectDotEye <= 0 {
		return ambient.Add(diffuse)
	}
	factor := math.Pow(reflectDotEye, material.Shininess)
	specular := light.Intensity.MultiplyByScalar(material.Specular).MultiplyByScalar(factor)
	return ambient.Add(diffuse).Add(specular)
}
