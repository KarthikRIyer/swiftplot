#include <fstream>
#include <iostream>
#include <cstring>
using namespace std;

int w = 1000;
int h = 660;

void saveBMP(const unsigned char* buf, float width, float height, const char* name){

  FILE *f;
  unsigned char *img = NULL;

  w = width;
  h = height;

  float red[w][h];
  float blue[w][h];
  float green[w][h];

  for (int i = 0; i < w; i++) {
    for (int j = 0, l = h-1; j < h; j++, l--) {
      red[i][l] = *(buf + (3*(w*j + i)));
      green[i][l] = *(buf + (3*(w*j + i) + 1));
      blue[i][l] = *(buf + (3*(w*j + i) + 2));
    }
  }

  int filesize = 54 + 3*w*h;  //w is your image width, h is image height, both int

  img = (unsigned char *)malloc(3*w*h);
  memset(img,0,3*w*h);

  for(int i=0; i<w; i++)
  {
      for(int j=0; j<h; j++)
      {
          int x=i; int y=(h-1)-j;
          float r = red[i][j]*255;
          float g = green[i][j]*255;
          float b = blue[i][j]*255;
          if (r > 255) r=255;
          if (g > 255) g=255;
          if (b > 255) b=255;
          img[(x+y*w)*3+2] = (unsigned char)(r);
          img[(x+y*w)*3+1] = (unsigned char)(g);
          img[(x+y*w)*3+0] = (unsigned char)(b);
      }
  }

  unsigned char bmpfileheader[14] = {'B','M', 0,0,0,0, 0,0, 0,0, 54,0,0,0};
  unsigned char bmpinfoheader[40] = {40,0,0,0, 0,0,0,0, 0,0,0,0, 1,0, 24,0};
  unsigned char bmppad[3] = {0,0,0};

  bmpfileheader[ 2] = (unsigned char)(filesize    );
  bmpfileheader[ 3] = (unsigned char)(filesize>> 8);
  bmpfileheader[ 4] = (unsigned char)(filesize>>16);
  bmpfileheader[ 5] = (unsigned char)(filesize>>24);

  bmpinfoheader[ 4] = (unsigned char)(       w    );
  bmpinfoheader[ 5] = (unsigned char)(       w>> 8);
  bmpinfoheader[ 6] = (unsigned char)(       w>>16);
  bmpinfoheader[ 7] = (unsigned char)(       w>>24);
  bmpinfoheader[ 8] = (unsigned char)(       h    );
  bmpinfoheader[ 9] = (unsigned char)(       h>> 8);
  bmpinfoheader[10] = (unsigned char)(       h>>16);
  bmpinfoheader[11] = (unsigned char)(       h>>24);

  f = fopen(name,"wb");
  fwrite(bmpfileheader,1,14,f);
  fwrite(bmpinfoheader,1,40,f);
  for(int i=0; i<h; i++)
  {
      fwrite(img+(w*(h-i-1)*3),3,w,f);
      fwrite(bmppad,1,(4-(w*3)%4)%4,f);
  }

  free(img);
  fclose(f);

}
