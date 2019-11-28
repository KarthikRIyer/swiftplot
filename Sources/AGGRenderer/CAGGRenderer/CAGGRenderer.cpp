#include "include/CAGGRenderer.h"
#include "CPPAGGRenderer.h"
#include <iostream>

const void * initializePlot(float w, float h, float subW, float subH, const char* fontPath){
  return CPPAGGRenderer::initializePlot(w, h, subW, subH, fontPath);
}

void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_rect(x, y, thickness, r, g, b, a, is_origin_shifted, object);
}

void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_solid_rect(x, y, r, g, b, a, hatch_pattern, is_origin_shifted, object);
}

void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_solid_circle(cx, cy, radius, r, g, b, a, is_origin_shifted, object);
}

void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_solid_triangle(x1, x2, x3, y1, y2, y3, r, g, b, a, is_origin_shifted, object);
}

void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_solid_polygon(x, y, count, r, g, b, a, is_origin_shifted, object);
}

void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_line(x, y, thickness, r, g, b, a, is_dashed, is_origin_shifted, object);
}

void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
  CPPAGGRenderer::draw_plot_lines(x, y, size, thickness, r, g, b, a, isDashed, object);
}

void draw_text(const char *s, float x, float y, float size, float r, float g, float b, float a, float thickness, float angle, bool is_origin_shifted, const void *object){
  CPPAGGRenderer::draw_text(s, x, y, size, r, g, b, a, thickness, angle, is_origin_shifted, object);
}

void get_text_size(const char *s, float size, float* outW, float* outH, const void *object){
  return CPPAGGRenderer::get_text_size(s, size, outW, outH, object);
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

void delete_buffer(const void *object){
  CPPAGGRenderer::delete_buffer(object);
}
