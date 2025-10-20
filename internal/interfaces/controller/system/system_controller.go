package system

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

type SystemHandler struct{}

func (handler *SystemHandler) Health(ctx echo.Context) error {
	return ctx.NoContent(http.StatusOK)
}

func NewSystemHandler() *SystemHandler {
	return &SystemHandler{}
}
