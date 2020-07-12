package gray

import (
	"image"
	"image/color"
	"image/png"
	"os"
)

/*
todo:
store color.RGBA instead of gray.Color
*/
type Canvas struct {
	Width, Height int
	Pixels        [][]Color
}

func NewCanvas(width, height int) Canvas {
	pixels := make([][]Color, width)
	for i := range pixels {
		pixels[i] = make([]Color, height)
	}
	return Canvas{width, height, pixels}
}

func (c Canvas) toPNG(filename string) error {
	fo, err := os.Create(filename)
	if err != nil {
		return err
	}

	img := image.NewRGBA(image.Rect(0, 0, c.Width, c.Height))
	for i, p := range c.Pixels {
		for j, px := range p {
			img.Set(i, c.Height-j, color.RGBA{ //todo (Height-j)?
				R: uint8(px.R() * 255),
				G: uint8(px.G() * 255),
				B: uint8(px.B() * 255),
				A: 255})
		}
	}
	err = png.Encode(fo, img)
	if err != nil {
		return err
	}
	if err := fo.Close(); err != nil {
		return err
	}
	return nil
}
