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
#include "agg_scanline_u.h"
#include "agg_scanline_bin.h"
#include "agg_conv_contour.h"
#include "agg_font_freetype.h"
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
#include "include/pixel_formats.h"

typedef agg::pixfmt_rgb24 pixfmt;
typedef agg::renderer_base<pixfmt> renderer_base;
typedef agg::renderer_base<pixfmt_pre> renderer_base_pre;
typedef agg::renderer_scanline_aa_solid<renderer_base> renderer_aa;
typedef agg::renderer_scanline_bin_solid<renderer_base> renderer_bin;
typedef agg::font_engine_freetype_int32 font_engine_type;
typedef agg::font_cache_manager<font_engine_type> font_manager_type;
typedef agg::rasterizer_scanline_aa<> rasterizer_scanline;
typedef agg::scanline_p8 scanline;
typedef agg::rgba Color;

const Color black(0.0,0.0,0.0,1.0);
const Color blue_light(0.529,0.808,0.922,1.0);
const Color white(1.0,1.0,1.0,1.0);
const Color white_translucent(1.0,1.0,1.0,0.8);

namespace CPPAGGRenderer{

  void write_bmp(const unsigned char* buf, unsigned width, unsigned height, const char* file_name){
    saveBMP(buf, width, height, file_name);
  }

  unsigned write_png(const unsigned char* image, unsigned width, unsigned height, const char* filename, const char** errorDesc) {
    //Encode the image
    LodePNGColorType colorType = LCT_RGB;
    unsigned error = lodepng::encode(filename, image, width, height, colorType);
    if(error && errorDesc)
        *errorDesc = lodepng_error_text(error);
    return error;
  }

  unsigned write_png_memory(const unsigned char *image, unsigned width, unsigned height,
                            unsigned char **output, size_t *outputSize, const char **errorDesc){
    //Encode the image
    LodePNGColorType colorType = LCT_RGB;
    unsigned error = lodepng_encode_memory(output, outputSize, image, w, h, colorType, 8);
    if(error && errorDesc)
        *errorDesc = lodepng_error_text(error);
    return error;
  }

  class Plot{
    agg::rasterizer_scanline_aa<> m_ras;
    agg::scanline_p8              m_sl_p8;
    agg::line_cap_e buttCap = agg::butt_cap;
    renderer_aa ren_aa;

    font_engine_type  m_feng;
    font_manager_type m_fman;
    agg::glyph_rendering gren = agg::glyph_ren_agg_gray8;
    //Pipeline to process the vector glyph paths (curves + contour)
    agg::conv_curve<font_manager_type::path_adaptor_type> m_curves;
    agg::conv_contour<agg::conv_curve<font_manager_type::path_adaptor_type>> m_contour;
    int font_weight = 0;
    int font_height = 0;
    int font_width = 0;
    bool font_hinting = false;
    bool font_kerning = true;
    string fontPath = "";

    unsigned char* buffer = NULL;
    int frame_width = 1000;
    int frame_height = 660;

    agg::int8u*           m_pattern;
    agg::rendering_buffer m_pattern_rbuf;
    renderer_base_pre rb_pre;
    
  public:
    
    Plot(float width, float height, const char* fontPathPtr) :
    m_feng(),
    m_fman(m_feng),
    m_curves(m_fman.path_adaptor()),
    m_contour(m_curves),
    frame_width(width),
    frame_height(height)
    {
      buffer = new unsigned char[frame_width*frame_height*3];
      memset(buffer, 255, frame_width*frame_height*3);
      m_curves.approximation_scale(2.0);
      m_contour.auto_detect_orientation(false);
      fontPath = fontPathPtr;
      if(fontPath.empty()){
        string file_path = __FILE__;
        string dir_path = file_path.substr(0, file_path.rfind("/"));
        fontPath = dir_path.append("/Roboto-Regular.ttf");
      }
    }
    
    ~Plot() {
      delete [] buffer;
    }

    void generate_pattern(float r, float g, float b, float a, int hatch_pattern){
      agg::path_storage m_ps;
      int size = 10;
      m_pattern = new agg::int8u[size * size * 3];
      m_pattern_rbuf.attach(m_pattern, size, size, size*3);
      pixfmt pixf_pattern(m_pattern_rbuf);
      agg::renderer_base<pixfmt> rb_pattern(pixf_pattern);
      agg::renderer_scanline_aa_solid<agg::renderer_base<pixfmt>> rs_pattern(rb_pattern);
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

    void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      pixfmt_pre pixf_pre(rbuf);
      renderer_base_pre rb_pre(pixf_pre);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      for (int i = 1; i < 4; i++) {
        rect_path.line_to(*(x+i),*(y+i));
      }
      rect_path.close_polygon();
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
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

    void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a){
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
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>> stroke(curve);
      stroke.width(thickness);
      m_ras.add_path(stroke);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a) {
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::ellipse circle(cx, cy, radius, radius, 100);
      Color c(r, g, b, a);
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      agg::conv_transform<agg::ellipse, agg::trans_affine> trans(circle, matrix);
      m_ras.add_path(trans);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a) {
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
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(tri_path, matrix);
      m_ras.add_path(trans);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a) {
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
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(poly_path, matrix);
      m_ras.add_path(trans);
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      agg::path_storage rect_path;
      rect_path.move_to(*x, *y);
      rect_path.line_to(*(x+1),*(y+1));

      agg::trans_affine matrix;
      matrix *= agg::trans_affine_translation(0, 0);
      agg::conv_transform<agg::path_storage, agg::trans_affine> trans(rect_path, matrix);
      agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>> curve(trans);
      agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>> stroke(curve);
      if (is_dashed) {
        agg::conv_dash<agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>>> poly2_dash(stroke);
        agg::conv_stroke<agg::conv_dash<agg::conv_stroke<agg::conv_curve<agg::conv_transform<agg::path_storage, agg::trans_affine>>>>> poly2(poly2_dash);
        poly2.width(thickness);
        poly2_dash.add_dash(thickness + 1, thickness + 1);
        poly2.line_cap(buttCap);
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
        poly2.line_cap(buttCap);
        m_ras.add_path(poly2);
      }
      else {
        m_ras.add_path(stroke);
      }
      Color c(r, g, b, a);
      ren_aa.color(c);
      agg::render_scanlines(m_ras, m_sl_p8, ren_aa);
    }

    void draw_text(const char *s, float x, float y, float size, float r, float g, float b, float a, float thickness, float angle){
      agg::rendering_buffer rbuf = agg::rendering_buffer(buffer, frame_width, frame_height, -frame_width*3);
      pixfmt pixf = pixfmt(rbuf);
      renderer_base rb = renderer_base(pixf);
      ren_aa = renderer_aa(rb);
      font_width = font_height = size;
      font_weight = thickness;
      Color color(r, g, b, a);
      m_contour.width(-font_weight*font_height*0.05);
      if(m_feng.load_font(fontPath.c_str(), 0, gren)){
      // if(m_feng.load_font(0, gren, roboto, roboto_size)){
        m_feng.hinting(font_hinting);
        m_feng.height(font_height);
        m_feng.width(font_width);
        m_feng.flip_y(false);
        agg::trans_affine matrix;
        matrix *= agg::trans_affine_rotation(agg::deg2rad(angle));
        m_feng.transform(matrix);
        while(*s){
          const agg::glyph_cache* glyph = m_fman.glyph(*s);
          if(glyph){
            if(font_kerning){
              double dx = double(x);
              double dy = double(y);
              m_fman.add_kerning(&dx, &dy);
            }
            m_fman.init_embedded_adaptors(glyph, x, y);
            ren_aa.color(color);
            agg::render_scanlines(m_fman.gray8_adaptor(), m_fman.gray8_scanline(), ren_aa);
            x+=glyph->advance_x;
            y+=glyph->advance_y;
          }
          ++s;
        }
      }
    }

    void get_text_size(const char *s, float size, float* outW, float* outH){
      font_width = font_height = size;
      m_contour.width(-font_weight*font_height*0.05);
        float x = 0;
        float y = 0;
      // set rotation of font engine to zero before calculating text width
      agg::trans_affine matrix;
      matrix *= agg::trans_affine_rotation(agg::deg2rad(0));
      m_feng.transform(matrix);
      if(m_feng.load_font(fontPath.c_str(), 0, gren)){
        m_feng.hinting(font_hinting);
        m_feng.height(font_height);
        m_feng.width(font_width);
        m_feng.flip_y(false);
        while(*s){
          const agg::glyph_cache* glyph = m_fman.glyph(*s);
          if(glyph){
            x+=glyph->advance_x;
            float height = glyph->bounds.y2 - glyph->bounds.y1;
            y = max(y, height);
          }
          ++s;
        }
      }
        if (outW)
            *outW = x;
        if (outH)
        *outH = y;
    }

    unsigned save_image(const char *s, const char** errorDesc){
      char* file_png = (char *) malloc(1 + strlen(s)+ strlen(".png") );
      strcpy(file_png, s);
      strcat(file_png, ".png");
      unsigned err = write_png(buffer, frame_width, frame_height, file_png, errorDesc);
      free(file_png);
      return err;
    }

    unsigned create_png_buffer(unsigned char** output, size_t *outputSize, const char** errorDesc) {
      return write_png_memory(buffer, frame_width, frame_height, output, outputSize, errorDesc);
    }
  };

  void * initializePlot(float w, float h, const char* fontPath){
    Plot *plot = new Plot(w, h, fontPath);
    return (void *)plot;
  }

  void delete_plot(void *object) {
    Plot *plot = (Plot *)object;
    delete plot;
    object = 0;
  }

  void draw_rect(const float *x, const float *y, float thickness, float r, float g, float b, float a,
                 const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_rect(x, y, thickness, r, g, b, a);
  }

  void draw_solid_rect(const float *x, const float *y, float r, float g, float b, float a, int hatch_pattern, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_rect(x, y, r, g, b, a, hatch_pattern);
  }

  void draw_solid_circle(float cx, float cy, float radius, float r, float g, float b, float a, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_circle(cx, cy, radius, r, g, b, a);
  }

  void draw_solid_triangle(float x1, float x2, float x3, float y1, float y2, float y3, float r, float g, float b, float a, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_triangle(x1, x2, x3, y1, y2, y3, r, g, b, a);
  }

  void draw_solid_polygon(const float* x, const float* y, int count, float r, float g, float b, float a, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_solid_polygon(x, y, count, r, g, b, a);
  }

  void draw_line(const float *x, const float *y, float thickness, float r, float g, float b, float a, bool is_dashed, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_line(x, y, thickness, r, g, b, a, is_dashed);
  }

  void draw_plot_lines(const float *x, const float *y, int size, float thickness, float r, float g, float b, float a, bool isDashed, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_plot_lines(x, y, size, thickness, r, g, b, a, isDashed);
  }

  void draw_text(const char *s, float x, float y, float size, float r, float g, float b, float a, float thickness, float angle, const void *object){
    Plot *plot = (Plot *)object;
    plot -> draw_text(s, x, y, size, r, g, b, a, thickness, angle);
  }

  void get_text_size(const char *s, float size, float* outW, float* outH, const void *object){
    Plot *plot = (Plot *)object;
    plot -> get_text_size(s, size, outW, outH);
  }

  unsigned save_image(const char *s, const char** errorDesc, const void *object){
    Plot *plot = (Plot *)object;
    return plot -> save_image(s, errorDesc);
  }

  unsigned create_png_buffer(unsigned char** output, size_t *outputSize, const char** errorDesc, const void *object) {
    Plot *plot = (Plot *)object;
    return plot -> create_png_buffer(output, outputSize, errorDesc);
  }

  void free_png_buffer(unsigned char** buffer) {
    if (buffer) { free(*buffer); }
    *buffer = 0;
  }
}
