#include<stdbool.h>
#include<stddef.h>
#ifdef __cplusplus
extern "C"  {
#endif

void * initializePlot(float w, float h, const char* fontPath);

void delete_plot(void *object);

void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, const void *object);

void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, const void *object);

void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, const void *object);

void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, const void *object);

void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, const void *object);

void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, const void *object);

void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object);

void draw_text(const char *s, float x, float y, float size, float r, float g, float b, float a, float thickness, float angle, const void *object);

void get_text_size(const char *s, float size, float* outW, float* outH, const void *object);

unsigned save_image(const char *s, const char** errorDesc, const void *object);

unsigned create_png_buffer(unsigned char** output, size_t *outputSize, const char** errorDesc, const void *object);

void free_png_buffer(unsigned char** output);

#ifdef __cplusplus
}
#endif
