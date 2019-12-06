#include "include/CAGGRenderer.h"
#include "CPPAGGRenderer.h"
#include <iostream>

void * initializePlot(float w, float h, const char* fontPath){
  return CPPAGGRenderer::initializePlot(w, h, fontPath);
}

void delete_plot(void *object){
  CPPAGGRenderer::delete_plot(object);
}

void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_rect(x, y, thickness, r, g, b, a, object);
}

void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, const void *object){
  CPPAGGRenderer::draw_solid_rect(x, y, r, g, b, a, hatch_pattern, object);
}

void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_solid_circle(cx, cy, radius, r, g, b, a, object);
}

void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_solid_triangle(x1, x2, x3, y1, y2, y3, r, g, b, a, object);
}

void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, const void *object){
  CPPAGGRenderer::draw_solid_polygon(x, y, count, r, g, b, a, object);
}

void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, const void *object){
  CPPAGGRenderer::draw_line(x, y, thickness, r, g, b, a, is_dashed, object);
}

void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
  CPPAGGRenderer::draw_plot_lines(x, y, size, thickness, r, g, b, a, isDashed, object);
}

void draw_text(const char *s, float x, float y, float size, float r, float g, float b, float a, float thickness, float angle, const void *object){
  CPPAGGRenderer::draw_text(s, x, y, size, r, g, b, a, thickness, angle, object);
}

void get_text_size(const char *s, float size, float* outW, float* outH, const void *object){
  return CPPAGGRenderer::get_text_size(s, size, outW, outH, object);
}

unsigned save_image(const char *s, const char** errorDesc, const void *object){
  return CPPAGGRenderer::save_image(s, errorDesc, object);
}

unsigned create_png_buffer(unsigned char** output, size_t *outputSize, const char** errorDesc, const void *object) {
  return CPPAGGRenderer::create_png_buffer(output, outputSize, errorDesc, object);
}

void free_png_buffer(unsigned char** output) {
  CPPAGGRenderer::free_png_buffer(output);
}
