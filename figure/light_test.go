package figure

import (
	"github.com/oleg/graytracer/oned"
	"github.com/stretchr/testify/assert"
	"testing"
)

func Test_point_light_has_position_and_intensity(t *testing.T) {
	intensity := oned.White
	position := oned.Point{0, 0, 0}

	light := PointLight{position, intensity}

	assert.Equal(t, position, light.Position)
	assert.Equal(t, intensity, light.Intensity)
}
