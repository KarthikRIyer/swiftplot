#include "include/AGGRendererWrapper.h"
#include "AGGRenderer.h"
#include <iostream>

const void * initializePlot(float w, float h){
  return AGGRenderer::initializePlot(w, h);
}

void draw_rect(const float *x, const float *y, float thickness, const void *object){
  AGGRenderer::draw_rect(x, y, thickness, object);
}

void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, const void *object){
  AGGRenderer::draw_solid_rect(x, y, r, g, b, a, object);
}

void draw_line(const float *x, const float *y, float thickness, const void *object){
  AGGRenderer::draw_line(x, y, thickness, object);
}

void draw_transformed_line(const float *x, const float *y, float thickness, const void *object){
  AGGRenderer::draw_transformed_line(x, y, thickness, object);
}

void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, const void *object){
  AGGRenderer::draw_plot_lines(x, y, size, thickness, r, g, b, a, object);
}

void draw_text(const char *s, float x, float y, float size, float thickness, const void *object){
  AGGRenderer::draw_text(s, x, y, size, thickness, object);
}

void draw_transformed_text(const char *s, float x, float y, float size, float thickness, const void *object){
  AGGRenderer::draw_transformed_text(s, x, y, size, thickness, object);
}

void draw_rotated_text(const char *s, float x, float y, float size, float thickness, float angle, const void *object){
  AGGRenderer::draw_rotated_text(s, x, y, size, thickness, angle, object);
}

float get_text_width(const char *s, float size, const void *object){
  return AGGRenderer::get_text_width(s, size, object);
}

void save_image(const char *s, const void *object){
  AGGRenderer::save_image(s, object);
}
