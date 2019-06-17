#include <iostream>
#include "string.h"

#include "include/CPPAGGRenderer.h"
//agg rendering library
#include "agg_basics.h"
#include "agg_rendering_buffer.h"
#include "agg_rasterizer_scanline_aa.h"
#include "agg_scanline_p.h"
#include "agg_pixfmt_rgb.h"
#include "agg_path_storage.h"
#include "agg_ellipse.h"
#include "platform/agg_platform_support.h"
#include "agg_gsv_text.h"
#include "agg_conv_curve.h"
#include "agg_conv_dash.h"
#include "agg_span_allocator.h"
#include "agg_span_pattern_gray.h"
#include "agg_span_pattern_rgb.h"
#include "agg_span_pattern_rgba.h"
#include "agg_image_accessors.h"
//lodepng library
#include "lodepng.h"
//header to save bitmaps
#include "savebmp.h"

#define AGG_RGB24
// #define AGG_BGRA32
#include "include/pixel_formats.h"

typedef agg::pixfmt_rgb24 pixfmt;
typedef agg::renderer_base<pixfmt> renderer_base;
typedef agg::renderer_base<pixfmt_pre> renderer_base_pre;
typedef agg::renderer_scanline_aa_solid<renderer_base> renderer_aa;
typedef agg::renderer_scanline_bin_solid<renderer_base> renderer_bin;
typedef agg::rasterizer_scanline_aa<> rasterizer_scanline;
typedef agg::scanline_p8 scanline;
typedef agg::rgba Color;

const Color black(0.0,0.0,0.0,1.0);
const Color blue_light(0.529,0.808,0.922,1.0);
const Color white(1.0,1.0,1.0,1.0);
const Color white_translucent(1.0,1.0,1.0,0.8);

int frame_width = 1000;
int frame_height = 660;
int sub_width = 1000;
int sub_height = 660;

namespace CPPAGGRenderer{

  void write_bmp(const unsigned char* buf, unsigned width, unsigned height, const char* file_name){
    saveBMP(buf, width, height, file_name);
  }

  void write_png(std::vector<unsigned char>& image, unsigned width, unsigned height, const char* filename) {
    //Encode the image
    LodePNGColorType colorType = LCT_RGB;
    unsigned error = lodepng::encode(filename, image, width, height, colorType);

    //if there's an error, display it
    if(error) std::cout << "encoder error " << error << ": "<< lodepng_error_text(error) << std::endl;
  }

  std::vector<unsigned char> write_png_memory(const unsigned char* buf, unsigned width, unsigned height){
    //Encode the image
    LodePNGColorType colorType = LCT_RGB;
    std::vector<unsigned char> out;
    unsigned error = lodepng::encode(out, buf, width, height, colorType);

    //if there's an error, display it
    if(error) std::cout << "encoder error " << error << ": "<< lodepng_error_text(error) << std::endl;
    return out;
  }

  class Plot{

  public:
    agg::rasterizer_scanline_aa<> m_ras;
    agg::scanline_p8              m_sl_p8;
    agg::line_cap_e roundCap = agg::round_cap;
    renderer_aa ren_aa;
    int pngBufferSize = 0;

    unsigned char* buffer;

    agg::int8u*           m_pattern;
    agg::rendering_buffer m_pattern_rbuf;
    renderer_base_pre rb_pre;

    Plot(float width, float height, float subW, float subH){
      frame_width = width;
      frame_height = height;
      sub_width = subW;
      sub_height = subH;
      delete[] buffer;
      buffer = new unsigned char[frame_width*frame_height*3];
    }

    void generate_pattern(float r, float g, float b, float a, int hatch_pattern){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt_pre pixf_pre(rbuf);
      rb_pre = renderer_base_pre(pixf_pre);
      agg::path_storage m_ps;
      int size = 10;
      m_pattern = new agg::int8u[size * size * 3];
      m_pattern_rbuf.attach(m_pattern, size, size, size*3);
      pixfmt pixf_pattern(m_pattern_rbuf);
      agg::renderer_base<pixfmt> rb_pattern(pixf_pattern);
      agg::renderer_scanline_aa_solid<agg::renderer_base<pixfmt> > rs_pattern(rb_pattern);
      rb_pattern.clear(agg::rgba_pre(r, g, b, a));

      switch (hatch_pattern) {
        case 0:
          break;
        case 1:
          {
            m_ps.move_to(0,0);
            m_ps.line_to(size, size);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            stroke.line_cap(agg::butt_cap);
            m_ras.add_path(stroke);
            break;
          }
        case 2:
          {
            m_ps.move_to(0,size);
            m_ps.line_to(size, 0);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        case 3:
          {
            agg::ellipse circle(size/2, size/2, size/2 - 2, size/2 - 2, 100);
            agg::conv_stroke<agg::ellipse> stroke(circle);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        case 4:
          {
            agg::ellipse circle(size/2, size/2, size/2 - 2, size/2 - 2, 100);
            m_ras.add_path(circle);
            break;
          }
        case 5:
          {
            m_ps.move_to(size/2, 0);
            m_ps.line_to(size/2, size);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        case 6:
          {
            m_ps.move_to(0, size/2);
            m_ps.line_to(size, size/2);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        case 7:
          {
            m_ps.move_to(size/2, 0);
            m_ps.line_to(size/2, size);
            m_ps.move_to(0, size/2);
            m_ps.line_to(size, size/2);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        case 8:
          {
            m_ps.move_to(0, 0);
            m_ps.line_to(size, size);
            m_ps.move_to(0, size);
            m_ps.line_to(size, 0);
            agg::conv_stroke<agg::path_storage> stroke(m_ps);
            stroke.width(1);
            m_ras.add_path(stroke);
            break;
          }
        default:
          break;
      }
      rs_pattern.color(agg::rgba8(0,0,0));
      agg::render_scanlines(m_ras, m_sl_p8, rs_pattern);
    }

    void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, bool is_origin_shifted){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      for (int i = 1; i < 4; i++) {
        rect_path.line_to(*(x+i),*(y+i));
      }
      rect_path.close_polygon();
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      if (hatch_pattern == 0) {
        Color c(r, g, b, a);
        m_ras.add_path(trans);
        ren_aa.color(c);
        agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
      }
      else {
        generate_pattern(r, g, b, a, hatch_pattern);
        typedef agg::wrap_mode_repeat_auto_pow2 wrap_x_type;
        typedef agg::wrap_mode_repeat_auto_pow2 wrap_y_type;
        typedef agg::image_accessor_wrap<pixfmt, wrap_x_type, wrap_y_type> img_source_type;
        typedef agg::span_pattern_rgb<img_source_type> span_gen_type;
        agg::span_allocator<color_type> sa;
        pixfmt          img_pixf(m_pattern_rbuf);
        img_source_type img_src(img_pixf);
        span_gen_type sg(img_src, 0,0);
        sg.alpha(span_gen_type::value_type(255.0));

        m_ras.add_path(trans);
        agg::render_scanlines_aa(m_ras, m_sl_p8, rb_pre, sa, sg);
      }
    }

    void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_origin_shifted){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      for (int i = 1; i < 4; i++) {
        rect_path.line_to(*(x+i),*(y+i));
      }
      rect_path.close_polygon();
      agg::conv_stroke<agg::path_storage> rect_path_line(rect_path);
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>> stroke(curve);
      stroke.width(thickness);
      m_ras.add_path(stroke);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, bool is_origin_shifted) {
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::ellipse circle(cx, cy, radius, radius, 100);
      Color c(r, g, b, a);
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::ellipse, agg::trans_affine> trans(circle, matrix);
      m_ras.add_path(trans);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, bool is_origin_shifted) {
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage tri_path;
      tri_path.move_to(x1, y1);
      tri_path.line_to(x2, y2);
      tri_path.line_to(x3, y3);
      tri_path.close_polygon();
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(tri_path, matrix);
      m_ras.add_path(trans);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, bool is_origin_shifted) {
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage poly_path;
      poly_path.move_to(*x, *y);
      for (int i = 1; i < count; i++) {
        poly_path.line_to(*(x+i),*(y+i));
      }
      poly_path.close_polygon();
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(poly_path, matrix);
      m_ras.add_path(trans);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, bool is_origin_shifted){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      rect_path.line_to(*(x+1),*(y+1));

      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>> stroke(curve);
      if (is_dashed) {
        agg::conv_dash<agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>>> poly2_dash(stroke);
        agg::conv_stroke<agg::conv_dash<agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>>>> poly2(poly2_dash);
        poly2.width(thickness);
        poly2_dash.add_dash(thickness + 1, thickness + 1);
        poly2.line_cap(roundCap);
        m_ras.add_path(poly2);
      }
      else {
        m_ras.add_path(stroke);
      }
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      for (int i = 1; i < size; i++) {
        rect_path.line_to(*(x+i),*(y+i));
      }
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>> stroke(curve);
      stroke.width(thickness);
      if (isDashed) {
        agg::conv_dash<agg::conv_transform<agg::path_storage, agg::trans_affine>> poly2_dash(trans);
        agg::conv_curve<agg::conv_dash<agg::conv_transform<agg::path_storage, agg::trans_affine>>> curve(poly2_dash);
        agg::conv_stroke<agg::conv_curve<agg::conv_dash<agg::conv_transform<agg::path_storage, agg::trans_affine>>>> poly2(curve);
        poly2.width(thickness);
        poly2_dash.add_dash(thickness + 1, thickness + 1);
        poly2.line_cap(roundCap);
        m_ras.add_path(poly2);
      }
      else {
        m_ras.add_path(stroke);
      }
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_text(const char *s, float x, float y, float size, float thickness, float angle, bool is_origin_shifted){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::gsv_text t;
      t.size(size);
      t.text(s);
      t.start_point(0,0);
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_rotation(agg::deg2rad(angle));
      matrix *= agg::trans_affine_translation(x, y);
      if (is_origin_shifted) {
        matrix *= agg::trans_affine_translation(sub_width*0.1f, sub_height*0.1f);
      }
      agg::conv_transform<agg::gsv_text, agg::trans_affine> trans(t, matrix);
      agg::conv_curve<agg::conv_transform<agg::gsv_text, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::gsv_text, agg::trans_affine>>> stroke(curve);
      stroke.width(thickness);
      m_ras.add_path(stroke);
      ren_aa.color(black);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    float get_text_width(const char *s, float size){
      agg::gsv_text t;
      t.text(s);
      t.size(size);
      return t.text_width();
    }

    void save_image(const char *s){
      char* file_png = (char *) malloc(1 + strlen(s)+ strlen(".png") );
      strcpy(file_png, s);
      strcat(file_png, ".png");
      std::vector<unsigned char> image(buffer, buffer + (frame_width*frame_height*3));
      write_png(image, frame_width, frame_height, file_png);
    }

    const unsigned char* getPngBuffer(){
      std::vector<unsigned char> outputImage = write_png_memory(buffer, frame_width, frame_height);
      pngBufferSize = outputImage.size();
    	return outputImage.data();
    }

    int getPngBufferSize(){
      return pngBufferSize;
    }

    void delete_buffer(){
      delete[] buffer;
    }

  };

  const void * initializePlot(float w, float h, float subW, float subH){
    Plot *plot = new Plot(w, h, subW, subH);
    memset(plot->buffer, 255, frame_width*frame_height*3);
    return (void *)plot;
  }

  void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_rect(x, y, thickness, r, g, b, a, is_origin_shifted);
  }

  void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_rect(x, y, r, g, b, a, hatch_pattern, is_origin_shifted);
  }

  void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_circle(cx, cy, radius, r, g, b, a, is_origin_shifted);
  }

  void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_triangle(x1, x2, x3, y1, y2, y3, r, g, b, a, is_origin_shifted);
  }

  void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_polygon(x, y, count, r, g, b, a, is_origin_shifted);
  }

  void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_line(x, y, thickness, r, g, b, a, is_dashed, is_origin_shifted);
  }

  void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_plot_lines(x, y, size, thickness, r, g, b, a, isDashed);
  }

  void draw_text(const char *s, float x, float y, float size, float thickness, float angle, bool is_origin_shifted, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_text(s, x, y, size, thickness, angle, is_origin_shifted);
  }

  float get_text_width(const char *s, float size, const void *object){
    Plot *plot = (Plot *)object;
    return plot -> get_text_width(s, size);
  }

  void save_image(const char *s, const void *object){
    Plot *plot = (Plot *)object;
    plot -> save_image(s);
  }

  const unsigned char* get_png_buffer(const void *object){
    Plot *plot = (Plot *)object;
    return plot -> getPngBuffer();
  }

  int get_png_buffer_size(const void *object){
    Plot *plot = (Plot *)object;
    return plot -> getPngBufferSize();
  }

  void delete_buffer(const void *object){
    Plot *plot = (Plot *)object;
    plot -> delete_buffer();
  }

}
