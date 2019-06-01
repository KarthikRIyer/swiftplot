#include "include/CAGGRenderer.h"
#include "CPPAGGRenderer.h"
#include <iostream>

const void * initializePlot(float w, float h, float subW, float subH){
  return CPPAGGRenderer::initializePlot(w, h, subW, subH);
}

void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_rect(x, y, thickness, r, g, b, a, object);
}

void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_solid_rect(x, y, r, g, b, a, object);
}

void draw_solid_rect_transformed(const float *x, const float *y, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_solid_rect_transformed(x, y, r, g, b, a, object);
}

void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_line(x, y, thickness, r, g, b, a, object);
}

void draw_transformed_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
  CPPAGGRenderer::draw_transformed_line(x, y, thickness, r, g, b, a, isDashed, object);
}

void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
  CPPAGGRenderer::draw_plot_lines(x, y, size, thickness, r, g, b, a, isDashed, object);
}

void draw_text(const char *s, float x, float y, float size, float thickness, const void *object){
  CPPAGGRenderer::draw_text(s, x, y, size, thickness, object);
}

void draw_transformed_text(const char *s, float x, float y, float size, float thickness, const void *object){
  CPPAGGRenderer::draw_transformed_text(s, x, y, size, thickness, object);
}

void draw_rotated_text(const char *s, float x, float y, float size, float thickness, float angle, const void *object){
  CPPAGGRenderer::draw_rotated_text(s, x, y, size, thickness, angle, object);
}

float get_text_width(const char *s, float size, const void *object){
  return CPPAGGRenderer::get_text_width(s, size, object);
}

void save_image(const char *s, const void *object){
  CPPAGGRenderer::save_image(s, object);
}

const unsigned char* get_png_buffer(const void *object){
  return CPPAGGRenderer::get_png_buffer(object);
}

int get_png_buffer_size(const void *object){
  return CPPAGGRenderer::get_png_buffer_size(object);
}
