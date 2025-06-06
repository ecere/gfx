define MODELS_TEXTUREARRAY_SIZE = 2048; // 512;

import "Display"

#ifdef ETC2_COMPRESS
default extern void * etc2Compress(float * pixelData, unsigned int width, unsigned int height,
   unsigned int * size, unsigned int * dw, unsigned int * dh, int format);
default extern void etc2Free(void * data);
#endif

public class BitmapFormat
{
   class_data const char ** extensions;

   class_property const char ** extensions
   {
      get { return class_data(extensions); }
      set { class_data(extensions) = value; }
   }

   virtual bool ::Load(Bitmap bitmap, File f);
   virtual bool ::Save(Bitmap bitmap, const char * fileName, void * options);
   virtual ColorAlpha * ::LoadPalette(const char * fileName, const char * type);
};

static const char * typesToTry[] =
{
   "gif", "jpg", "png", "bmp", "pcx", "memorybmp"
};

#define NUM_TYPES_TO_TRY   ((int)(sizeof(typesToTry) / sizeof(char *)))

static subclass(BitmapFormat) FindFormat(const char * type)
{
   subclass(BitmapFormat) format = null;
   if(type)
   {
      OldLink link;
      for(link = class(BitmapFormat).derivatives.first; link; link = link.next)
      {
         const char ** extensions;
         format = link.data;
         extensions = format.extensions;
         if(extensions)
         {
            int c;
            for(c = 0; extensions[c] && extensions[c][0]; c++)
               if(!strcmp(extensions[c], type))
                  break;
            if(extensions[c] && extensions[c][0])
               break;
         }
      }
      if(!link) format = null;
   }
   return format;
}

public ColorAlpha * LoadPalette(const char * fileName, const char * type)
{
   char ext[MAX_EXTENSION];
   subclass(BitmapFormat) format = null;
   ColorAlpha * palette = null;
   int typeToTry = -1;
   Bitmap bitmap { };

   if(!type)
      type = strlwr(GetExtension(fileName, ext));

   if(type)
      format = FindFormat(type);

   if(!format)
      typeToTry = 0;

   for(; typeToTry < NUM_TYPES_TO_TRY; typeToTry++)
   {
      if(typeToTry >= 0)
         format = FindFormat(typesToTry[typeToTry]);

      if(format)
      {
         palette = format.LoadPalette(fileName, type);
         if(palette)
            break;
      }
      if(!palette)
      {

         if(bitmap.Load(fileName, type, null))
         {
            palette = bitmap.Quantize(0, 255);
            bitmap.allocatePalette = false;
            break;
         }
      }
      if(typeToTry == -1) break;
   }

   delete bitmap;

   if(!palette)
      ; //eGraphics_LogErrorCode(GERR_LOAD_BITMAP_FAILED, fileName);
   return palette;
}

static define GRANULARITY = 4;

static class QuantNode : struct
{
   QuantNode prev, next;
   QuantNode parent;
   QuantNode nodes[2][2][2];
   int index;
   byte minR, maxR;
   byte minG, maxG;
   byte minB, maxB;
   int n2;
   float e;
   float sr, sg, sb;
   int level;

   void AddColor(int r, int g, int b, OldList nodeList, int * nonZeroN2)
   {
      int size = maxR - minR + 1;
      int mr = (maxR - minR) / 2;
      int mg = (maxG - minG) / 2;
      int mb = (maxB - minB) / 2;
      e += ((r-mr) * (r-mr) + (g-mg) * (g-mg) + (b-mb) * (b-mb)) >> level;

      if(size > GRANULARITY)
      {
         int ri = (r - minR) / (size >> 1);
         int gi = (g - minG) / (size >> 1);
         int bi = (b - minB) / (size >> 1);
         QuantNode child = nodes[ri][gi][bi];
         if(!child)
         {
            child = nodes[ri][gi][bi] = QuantNode { };
            nodeList.Add(child);

            child.level = level + 1;
            child.parent = this;
            child.minR = (byte)(minR + ri * (size >> 1));
            child.maxR = (byte)(child.minR + (size >> 1) - 1);
            child.minG = (byte)(minG + gi * (size >> 1));
            child.maxG = (byte)(child.minG + (size >> 1) - 1);
            child.minB = (byte)(minB + bi * (size >> 1));
            child.maxB = (byte)(child.minB + (size >> 1) - 1);
         }
         child.AddColor(r, g, b, nodeList, nonZeroN2);
      }
      else
      {
         if(!n2)
            (*nonZeroN2)++;
         n2 ++;
         sr += r;
         sg += g;
         sb += b;
      }
   }

   void PruneNode(OldList nodeList, int * nonZeroN2)
   {
      int r,g,b;
      QuantNode parent = this.parent;
      int ri = (minR != parent.minR);
      int gi = (minG != parent.minG);
      int bi = (minB != parent.minB);

      for(r = 0; r<2; r++)
         for(g = 0; g<2; g++)
            for(b = 0; b<2; b++)
            {
               QuantNode child = nodes[r][g][b];
               if(child)
                  child.PruneNode(nodeList, nonZeroN2);
            }

      this.parent.nodes[ri][gi][bi] = null;

      if(n2 && parent.n2)
         (*nonZeroN2)--;

      parent.sr += sr;
      parent.sg += sg;
      parent.sb += sb;
      parent.n2 += n2;

      nodeList.Delete(this);
   }

   int FindColor(ColorAlpha * palette, int r, int g, int b)
   {
      int size = maxR - minR + 1;
      if(size > GRANULARITY)
      {
         int ri = (r - minR) / (size >> 1);
         int gi = (g - minG) / (size >> 1);
         int bi = (b - minB) / (size >> 1);
         QuantNode child = nodes[ri][gi][bi];
         if(child)
            return child.FindColor(palette, r, g, b);
      }
      return index;
   }

   int Compare(const QuantNode b, void * data)
   {
      return (e > b.e) ? -1 : (e < b.e);
   }

   void AddNodeToColorTable(ColorAlpha * palette, int * c)
   {
      int r, g, b;

      if(n2 > 0)
      {
         r = (int)(sr / n2);
         g = (int)(sg / n2);
         b = (int)(sb / n2);
         r = Max(Min(r,255),0);
         g = Max(Min(g,255),0);
         b = Max(Min(b,255),0);

         palette[*c] = { 255, Color { (byte)r, (byte)g, (byte)b } };
         index = *c;
         (*c)++;
      }

      for(r = 0; r<2; r++)
         for(g = 0; g<2; g++)
            for(b = 0; b<2; b++)
            {
               QuantNode child = nodes[r][g][b];
               if(child)
                  child.AddNodeToColorTable(palette, c);
            }
   }
};

public class Bitmap
{
   class_no_expansion
   ~Bitmap()
   {
      Free();
   }
public:
   int width, height;

   // Data representation
   PixelFormat pixelFormat;
   byte * picture;
   uint stride;
   uint size, sizeBytes;   // TODO: Change this to be 64 bit? (breaking)
   ColorAlpha * palette;
   bool allocatePalette;

   // Appearance
   bool transparent;
   // TODO: byte shadeShift;
   int shadeShift;
   byte * paletteShades;
   bool alphaBlend;

   // Hidden Data
   DisplaySystem displaySystem;
   subclass(DisplayDriver) driver;
   void * driverData;
   bool keepData;
   bool mipMaps;
   bool sRGB2Linear;
   int numMipMaps;
   Bitmap * bitmaps;

public:

   /*property byte * picture { get { return picture; } set { picture = value; } };
   property int width { get { return width; }  set { width = value; } };
   property int height { get { return height; }  set { height = value; } };
   property int stride { get { return stride; }  set { stride = value; } };
   property int size { get { return size; } };
   property ColorAlpha * palette { set { palette = value; } get { return palette; } };
   property bool transparent { set { transparent = value; } get { return transparent; } };
   property bool alphaBlend { set { alphaBlend = value; } get { return alphaBlend; } };
   property byte * paletteShades { set { paletteShades = value; } get { return paletteShades; } };
   property PixelFormat pixelFormat { get { return pixelFormat; }  set { pixelFormat = value; } };
   property bool keepData { set { keepData = value; } get { return keepData; } };*/

   Surface GetSurface(int x, int y, Box clip)
   {
      Surface result = null;
      Surface surface { };
      if(surface)
      {
         Box box { 0, 0, width - 1, height - 1 };
         box.Clip(clip);

         surface.width = (clip != null) ? (clip.right - clip.left + 1) : width;
         surface.height = (clip != null) ? (clip.bottom - clip.top + 1) : height;
         surface.driver = (driver != null) ? driver : ((subclass(DisplayDriver))class(LFBDisplayDriver));
         surface.displaySystem = displaySystem;
         surface.display = null; // For now... with render to textures, the texture should have a display...
         //surface.alphaWrite = write;

         if(surface.driver.GetBitmapSurface(displaySystem, surface, this, x, y, box))
         {
            surface.TextOpacity(false);
            surface.SetForeground(white);
            surface.SetBackground(black);
            result = surface;
         }
         if(!result)
            delete surface;
      }
      return result;
   }

   void SmoothEdges(int size)
   {
      Surface surface = GetSurface(0, 0, null);
      if(surface)
      {
         int cx,cy;
         int acrossX = width / size;
         int acrossY = height / size;

         for(cy = 0; cy < acrossY; cy++)
            for(cx = 0; cx < acrossX; cx++)
            {
               int x,y;
               Color in1, in2, res;
   /*
               Color color { GetRandom(0,255), GetRandom(0,255), GetRandom(0,255)) };
               surface.SetForeground(color);
               for(y = 0; y<size; y++)
                  for(x = 0; x<size; x++)
                     surface.PutPixel(cx * size + x, cy * size + y);
   */
               // Corner
               if(cx > 0 || cy > 0)
               {
                  int r = 0, g = 0, b = 0, num = 0;
                  if(cx > 0)
                  {
                     in1 = surface.GetPixel(cx * size - 1, cy * size);
                     in2 = surface.GetPixel(cx * size,  cy * size);
                     r += in1.r + in2.r;
                     g += in1.g + in2.g;
                     b += in1.b + in2.b;
                     num += 2;
                  }
                  if(cy > 0)
                  {
                     in1 = surface.GetPixel(cx * size, cy * size - 1);
                     in2 = surface.GetPixel(cx * size, cy * size);
                     r += in1.r + in2.r;
                     g += in1.g + in2.g;
                     b += in1.b + in2.b;
                     num += 2;
                  }
                  surface.SetForeground(Color { (byte)(r/num), (byte)(g/num), (byte)(b/num) });
                  surface.PutPixel(cx * size, cy * size);
                  if(cx > 0) surface.PutPixel(cx * size - 1, cy * size);
                  if(cy > 0) surface.PutPixel(cx * size, cy * size - 1);
                  if(cx > 0 && cy > 0) surface.PutPixel(cx * size - 1, cy * size - 1);
               }

               // Left
               if(cx>0)
                  for(y = 1; y<size; y++)
                  {
                     in1 = surface.GetPixel(cx * size - 1, cy * size + y);
                     in2 = surface.GetPixel(cx * size,  cy * size + y);
                     res = Color { (in1.r + in2.r) / 2, (in1.g + in2.g) / 2, (in1.b + in2.b) / 2 };
                     surface.SetForeground(res);
                     surface.PutPixel(cx * size - 1, cy * size + y);
                     surface.PutPixel(cx * size, cy * size + y);
                  }

               // Top
               if(cy>0)
                  for(x = 1; x<size; x++)
                  {
                     in1 = surface.GetPixel(cx * size + x, cy * size - 1);
                     in2 = surface.GetPixel(cx * size + x, cy * size);
                     res = Color { (in1.r + in2.r) / 2, (in1.g + in2.g) / 2, (in1.b + in2.b) / 2 };
                     surface.SetForeground(res);
                     surface.PutPixel(cx * size + x, cy * size - 1);
                     surface.PutPixel(cx * size + x, cy * size);
                  }
            }
         delete surface;
      }
   }

   // --- Bitmap conversion ---

   bool Convert(DisplaySystem displaySystem, PixelFormat format, ColorAlpha * palette)
   {
      if(driver)
         return driver.ConvertBitmap(displaySystem, this, format, palette);
      return pixelFormat == format;
   }

   bool Copy(Bitmap source)
   {
      return Copy2(source, false);
   }

   bool Copy2(Bitmap source, bool moveStuff)
   {
      bool result = false;
      if(source)
      {
         Free();

         // TODO: Watch out for inst stuff
         width = source.width;
         height = source.height;
         pixelFormat = source.pixelFormat;
         picture = source.picture;
         stride = source.stride;
         size = source.stride;
         transparent = source.transparent;
         shadeShift = source.shadeShift;
         paletteShades = source.paletteShades;
         sizeBytes = source.sizeBytes;
         displaySystem = source.displaySystem;
         driver = source.driver;
         driverData = source.driverData;
         mipMaps = source.mipMaps;
         numMipMaps = source.numMipMaps;
         bitmaps = source.bitmaps;
         palette = source.palette;

         if(!moveStuff)
         {
            picture = new byte[sizeBytes];
            allocatePalette = false;
            if(source.picture)
               memcpy(picture, source.picture, sizeBytes);
            else
               memset(picture, 0, sizeBytes);
         }
         else
         {
            source.picture = null;
            source.palette = null;
            source.bitmaps = null;
            source.numMipMaps = 0;
            picture = source.picture;
            allocatePalette = source.allocatePalette;
         }
         result = true;
      }
      return result;
   }

   bool MakeDD(DisplaySystem displaySystem)
   {
      bool result = false;
      if(this && displaySystem && (!driver || driver == class(LFBDisplayDriver)))
      {
         if(displaySystem.driver.MakeDDBitmap(displaySystem, this, false, 0))
         {
            this.displaySystem = displaySystem;
            driver = displaySystem ? displaySystem.driver : ((subclass(DisplayDriver))class(LFBDisplayDriver));
            result = true;
         }
      }
      return result;
   }

   bool MakeMipMaps(DisplaySystem displaySystem)
   {
      bool result = false;
      if(this && displaySystem && (!driver || driver == class(LFBDisplayDriver)))
      {
         if(displaySystem.driver.MakeDDBitmap(displaySystem, this, true, 0))
         {
            this.mipMaps = true;
            this.displaySystem = displaySystem;
            result = true;
         }
      }
      return result;
   }

   // --- Bitmap loading ---
   bool LoadFromFile(File file, const char * type, DisplaySystem displaySystem)
   {
      bool result = false;
      if(file)
      {
         subclass(BitmapFormat) format = null;
         int typeToTry = -1;
         uintsize pos = file.Tell();

         if(type)
            format = FindFormat(type);

         if(!format)
            typeToTry = 0;

         for(; typeToTry < NUM_TYPES_TO_TRY; typeToTry++)
         {
            file.Seek(pos, start);
            if(typeToTry >= 0)
               format = FindFormat(typesToTry[typeToTry]);

            if(format)
            {
               if((result = format.Load(this, file)))
               {
                  if(displaySystem)
                  {
                     if(!MakeDD(displaySystem))
                     {
                        Free();
                        result = false;
                     }
                  }
                  break;
               }
            }
            if(typeToTry == -1) break;
         }
      }

      if(!result)
          ; // eGraphics_LogErrorCode(GERR_LOAD_BITMAP_FAILED, null);
      return result;
   }

   bool Load(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = false;
      char ext[MAX_EXTENSION];
      subclass(BitmapFormat) format = null;
      int typeToTry = -1;
      const char * guessedType = type;

      if(!fileName) return false;
      if(!guessedType)
         guessedType = strlwr(GetExtension(fileName, ext));

      if(guessedType)
         format = FindFormat(guessedType);
      if(!format)
         typeToTry = 0;

      for(; typeToTry < NUM_TYPES_TO_TRY; typeToTry++)
      {
         if(typeToTry >= 0)
            format = FindFormat(typesToTry[typeToTry]);

         if(format)
         {
            File f = FileOpen(fileName, read);
            if(f)
            {
               if((result = format.Load(this, f)))
               {
                  if(displaySystem)
                  {
                     if(!MakeDD(displaySystem))
                     {
                        Free();
                        result = false;
                     }
                  }
                  delete f;
                  break;
               }
               delete f;
            }
         }
         if(typeToTry == -1)
         {
            if(type) break;
            typeToTry = 0;
         }
      }

      if(!result)
          ; //eGraphics_LogErrorCode(GERR_LOAD_BITMAP_FAILED, fileName);
      return result;
   }

   bool LoadT(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = Load(fileName, type, null);
      if(result)
      {
         transparent = true;
         if(displaySystem)
            if(!MakeDD(displaySystem))
            {
               Free();
               result = false;
            }
      }
      return result;
   }

   #define TRESHOLD  384

   bool LoadGrayed(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = Load(fileName, type, null);
      if(result)
      {
         if(pixelFormat == pixelFormatRGBA)
         {
            int c;
            int x, y;
            Bitmap grayed { };

            grayed.Allocate(null, width, height, 0, pixelFormat888, false);

            for(y = 0;  y <height - 1; y++)
            {
               for(x = 0; x < width - 1; x++)
               {
                  ColorRGBA b = ((ColorRGBA *)picture)[y * stride + x];
                  //if(b && !(palette[b].color))
                  if(/*b.a > 128 && */(b.r + b.g + b.b) < TRESHOLD)
                  {
                     // TODO: Precomp syntax error here without brackets
                     ((ColorAlpha *)grayed.picture)[(y + 1) * grayed.stride + (x + 1)] =
                        ColorAlpha { b.a, white };
                  }
               }
            }

            for(c = 0; c<size; c++)
            {
               ColorRGBA b = ((ColorRGBA *)picture)[c];
               //if(b.a > 128)
               {
                  ((ColorAlpha *)grayed.picture)[c] =
                     (/*b.a > 128 && */b.r + b.g + b.b < TRESHOLD) ?
                        ColorAlpha { b.a, { 128, 128, 128 } } : ColorAlpha { b.a, { 212, 208, 200 } };
               }
            }

            Free();

            pixelFormat = grayed.pixelFormat;
            picture = grayed.picture;
            grayed.picture = null;
            transparent = true;
            alphaBlend = true;
            driver = grayed.driver;

            delete grayed;

            if(displaySystem)
               if(!MakeDD(displaySystem))
               {
                  Free();
                  result = false;
               }
            return result;
         }
         if(pixelFormat != pixelFormat8)
         {
            transparent = true;
            palette = Quantize(1, 255);
         }
         if(pixelFormat == pixelFormat8)
         {
            int c;
            int x, y;
            Bitmap grayed { };

            grayed.Allocate(null, width, height, 0, pixelFormat888, false);


            for(y = 0;  y <height - 1; y++)
            {
               for(x = 0; x < width - 1; x++)
               {
                  byte b = picture[y * stride + x];
                  //if(b && !(palette[b].color))
                  if(b && (palette[b].color.r + palette[b].color.g + palette[b].color.b) < TRESHOLD)
                  {
                     // TODO: Precomp syntax error here without brackets
                     ((ColorAlpha *)grayed.picture)[(y + 1) * grayed.stride + (x + 1)] =
                        ColorAlpha { 255, white };
                  }
               }
            }

            for(c = 0; c<size; c++)
            {
               byte b = picture[c];
               if(b)
               {
                  ((ColorAlpha *)grayed.picture)[c] =
                     //(bitmap.palette[b].color) ? Color { 212, 208, 200 } : Color { 128,128,128 };
                     (palette[b].color.r + palette[b].color.g + palette[b].color.b < TRESHOLD) ?
                        ColorAlpha { 255, { 128, 128, 128 } } : ColorAlpha { 255, { 212, 208, 200 } };
               }
            }

            Free();

            pixelFormat = grayed.pixelFormat;
            picture = grayed.picture;
            grayed.picture = null;
            transparent = true;
            driver = grayed.driver;

            delete grayed;

            if(displaySystem)
               if(!MakeDD(displaySystem))
               {
                  Free();
                  result = false;
               }
         }
         else
         {
            Free();
            result = false;
         }
      }

      return result;
   }

   bool LoadMonochrome(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = Load(fileName, type, null);
      if(result)
      {
         if(pixelFormat != pixelFormat8)
            Convert(null, pixelFormat8, null);
         if(pixelFormat == pixelFormat8)
         {
            int x, y;
            Bitmap grayed { };

            grayed.Allocate(null, width, height, 0, pixelFormat888, false);

            for(y = 0; y<height - 1; y++)
            {
               for(x = 0; x<width - 1; x++)
               {
                  byte b = picture[y * stride + x];
                  if(b && !palette[b].color)
                  {
                     ((ColorAlpha *)grayed.picture)[(y + 1) * grayed.stride + (x + 1)] = white;
                  }
               }
            }
            Free();

            pixelFormat = grayed.pixelFormat;
            size = grayed.size;
            sizeBytes = grayed.sizeBytes;
            stride = grayed.stride;
            picture = grayed.picture;
            grayed.picture = null;
            transparent = true;

            delete grayed;

            if(displaySystem)
               if(!MakeDD(displaySystem))
               {
                  Free();
                  result = false;
               }
         }
         else
         {
            Free();
            result = false;
         }
      }
      return result;
   }

   bool LoadMipMaps(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = Load(fileName, type, null);
      if(result && displaySystem)
         if(!MakeMipMaps(displaySystem))
         {
            Free();
            result = false;
         }
      return result;
   }

   bool LoadTMipMaps(const char * fileName, const char * type, DisplaySystem displaySystem)
   {
      bool result = Load(fileName, type, null);
      if(result && displaySystem)
      {
         transparent = true;
         if(displaySystem)
            if(!MakeMipMaps(displaySystem))
               result = false;
      }
      return result;
   }

   bool Save(const char * fileName, const char * type, void * options)
   {
      char ext[MAX_EXTENSION];
      subclass(BitmapFormat) format = null;

      if(!type)
         type = strlwr(GetExtension(fileName, ext));

      if(type)
         format = FindFormat(type);

      if(format)
         return format.Save(this, fileName, options);
      return false;
   }

   // --- Memory bitmaps ---

   bool AllocateDD(DisplaySystem displaySystem, int width, int height)
   {
      bool result = false;
      PixelFormat pixelFormat = displaySystem ? displaySystem.pixelFormat : pixelFormat888;
      driver = displaySystem ? displaySystem.driver : ((subclass(DisplayDriver))class(LFBDisplayDriver));
      this.displaySystem = displaySystem;
      if(driver.AllocateBitmap(displaySystem, this, width, height, 0, pixelFormat, true))
         result = true;
      else
      {
         paletteShades = null;
         palette = null;
         allocatePalette = false;
         transparent = false;

         // FillBytes(bitmap, 0, sizeof(Bitmap));

         driver = ((subclass(DisplayDriver))class(LFBDisplayDriver));
         displaySystem = null;
         if(driver.AllocateBitmap(null, this, width, height, 0, pixelFormat, true))
         {
            result = true;
         }
      }
      if(!result)
         Free();
      return result;
   }

   bool Allocate(const char * driverName, int width, int height, int stride, PixelFormat format, bool allocatePalette)
   {
      bool result = false;
      subclass(DisplayDriver) displayDriver = driverName ? GetDisplayDriver(driverName) : ((subclass(DisplayDriver))class(LFBDisplayDriver));
      Free();
      if(displayDriver)
      {
         driver = displayDriver;
         if(driver.AllocateBitmap(null, this, width, height, stride, format, allocatePalette))
            result = true;
         if(!result)
            Free();
      }
      return result;
   }

   void Free()
   {
      if(this && bitmaps)
      {
         uint i;

         for(i = 0; i < numMipMaps; i++)
         {
            if(bitmaps[i] && pixelFormat == pixelFormatETC2RGBA8)
            {
   #ifdef ETC2_COMPRESS
               etc2Free(bitmaps[i].picture);
               bitmaps[i].picture = null;
   #else
               delete bitmaps[i].picture;
   #endif
            }
            delete bitmaps[i];
         }
         delete bitmaps;
      }
      if(this && pixelFormat == pixelFormatETC2RGBA8)
      {
#ifdef ETC2_COMPRESS
         if(picture) etc2Free(picture);
         picture = null;
#else
         delete picture;
#endif
      }

      if(this && driver)
      {
         driver.FreeBitmap(displaySystem, this);
         picture = null;
         driverData = null;
         driver = class(LFBDisplayDriver);
      }
      if(this && (keepData || !driver))
         delete picture;
   }

   void Grab(Bitmap src, int x, int y)
   {
      Surface surface = GetSurface(0, 0, null);
      surface.blend = false;
      surface.Blit(src, 0,0, x, y, width, height);
      delete surface;
   }

   ColorAlpha * Quantize(uint start, uint end)
   {
      ColorAlpha * palette = new ColorAlpha[256];
      if(palette)
      {
         int c;
         OldList nodeList { };
         QuantNode mainNode { maxR = 255, maxG = 255, maxB = 255 };
         QuantNode node;
         Color * picture;
         int nonZeroN2 = 0;

         nodeList.Add(mainNode);

         Convert(null, pixelFormat888, null);

         for(picture = (Color *)this.picture, c = 0; c<size; c++, picture++)
         {
            Color color = *picture;
            mainNode.AddColor(color.r, color.g, color.b, nodeList, &nonZeroN2);
         }

         nodeList.Sort(QuantNode::Compare, null);

         while(nonZeroN2 > end - start + 1)
         {
            for(node = nodeList.last; node; node = node.prev)
            {
               if(node.n2 > 0)
               {
                  ((QuantNode)nodeList.last).PruneNode(nodeList, &nonZeroN2);
                  break;
               }
            }
         }

         c = 0;
         mainNode.AddNodeToColorTable(palette + start, &c);

         {
            Bitmap newBitmap { };
            if(newBitmap.Allocate(null, width, height, 0, pixelFormat8, false))
            {
               int y, x;
               ColorAlpha * picture = (ColorAlpha *)this.picture;
               byte * newPicture = newBitmap.picture;

               for(y = 0; y < height; y++)
                  for(x = 0; x < width; x++, picture++, newPicture++)
                  {
                     byte color;

                     if(transparent && start > 0 && !picture->a)
                        color = 0;
                     else
                        color = (byte)(mainNode.FindColor(palette + start, picture->color.r, picture->color.g, picture->color.b) + start);
                     *newPicture = color;
                  }

               delete this.picture;
               this.picture = newBitmap.picture;
               this.palette = palette;
               allocatePalette = true;
               pixelFormat = pixelFormat8;
               sizeBytes = stride * height;

               newBitmap.picture = null;
            }
            delete newBitmap;
         }
         nodeList.Free(null);
      }
      return palette;
   }

   Bitmap ProcessDD(bool mipMaps, uint cubeMapFace, bool compress, int maxTextureSize, bool makePow2, int enforcedWidth, int enforcedHeight)
   {
      Bitmap bitmap = this;
      Bitmap retValue = null;
      Bitmap convBitmap { mipMaps = false };
      bool freeConvBitmap = true;
      PixelFormat workingFormat = pixelFormat888;

#if defined(_GLES) && !defined(_GLES2) && !defined(_GLES3)
      makePow2 = true; // TOCHECK: Otherwise detect NPOT capability higher up?
#endif

#if !defined(ETC2_COMPRESS)
      compress = false;
#endif

#if defined(_GLES3)
      if(compress)
         workingFormat = pixelFormatRGBA;  // DXT5 compressor expects reverse order?
#endif

      convBitmap.width = bitmap.width;
      convBitmap.height = bitmap.height;
      convBitmap.pixelFormat = bitmap.pixelFormat;
      convBitmap.picture = bitmap.picture;
      convBitmap.stride = bitmap.stride;
      convBitmap.size = bitmap.stride;
      convBitmap.transparent = bitmap.transparent;
      convBitmap.shadeShift = bitmap.shadeShift;
      convBitmap.paletteShades = bitmap.paletteShades;
      convBitmap.sizeBytes = bitmap.sizeBytes;
      convBitmap.displaySystem = bitmap.displaySystem;
      convBitmap.driver = bitmap.driver;
      convBitmap.driverData = bitmap.driverData;

      if(bitmap.keepData)
      {
         convBitmap.picture = new byte[convBitmap.sizeBytes];
         if(bitmap.picture)
            memcpy(convBitmap.picture, bitmap.picture, bitmap.sizeBytes);
         else
            memset(convBitmap.picture, 0, convBitmap.sizeBytes);
      }
      else
      {
         convBitmap.picture = bitmap.picture;
         bitmap.picture = null;
         if(!convBitmap.picture)
            // TOCHECK: Why is this happening?
            convBitmap.picture = new0 byte[convBitmap.sizeBytes];
      }

      convBitmap.palette = bitmap.palette;
      convBitmap.allocatePalette = false;

      // Pre process the bitmap... First make it 32 bit
      if(convBitmap.Convert(null, workingFormat, null))
      {
         int c, level;
         uint w = bitmap.width, h = bitmap.height;
         bool oldStyleCubeMap = (cubeMapFace >> 3) != 0;
         bool result = true;
         int numMipMaps = 0;

         if(makePow2)
         {
            w = pow2i(w);
            h = pow2i(h);
         }
         if(compress)
         {
            w = (w + 3) & (~3);
            h = (h + 3) & (~3);
         }
         w = Min(w, maxTextureSize);
         h = Min(h, maxTextureSize);

         if(mipMaps)
         {
            if(enforcedWidth)
               w = enforcedWidth;
#if !defined(_GLES) && !defined(_GLES2) && !defined(_GLES3)
            else
               while(w * 2 < h) w *= 2;
#endif

            if(enforcedHeight)
               h = enforcedHeight;
#if !defined(_GLES) && !defined(_GLES2) && !defined(_GLES3)
            else
               while(h * 2 < w) h *= 2;
#endif
            numMipMaps = 1+Max(log2i(w), log2i(h));
         }

         // Switch ARGB to RGBA
         {
            int size = convBitmap.stride * convBitmap.height;
            uint * pic = (uint *)convBitmap.picture;
            for(c = 0; c < size; c++)
            {
               ColorAlpha color = pic[c];
               Color clr = color.color;
               pic[c] = ColorRGBA { clr.r, clr.g, clr.b, color.a };
            }
         }

         if(cubeMapFace && oldStyleCubeMap)
         {
            int face = (cubeMapFace & 7) - 1;
            if(face == 0 || face == 1 || face == 4 || face == 5)
            {
               uint w = convBitmap.width;
               uint32 * tmp = new uint [convBitmap.width];
               int x, y;
               for(y = 0; y < convBitmap.height; y++)
               {
                  uint32 * pic = (uint32 *)((byte *)convBitmap.picture + y * w * 4);
                  for(x = 0; x < w; x++)
                     tmp[x] = pic[w-1-x];
                  memcpy(pic, tmp, w*4);
               }
               delete tmp;
            }
            else if(face == 2 || face == 3)
            {
               int y;
               Bitmap tmp { };
               tmp.Allocate(null, convBitmap.width, convBitmap.height, 0, convBitmap.pixelFormat, false);
               for(y = 0; y < convBitmap.height; y++)
               {
                  memcpy(tmp.picture + convBitmap.width * 4 * y,
                     convBitmap.picture + (convBitmap.height-1-y) * convBitmap.width * 4,
                     convBitmap.width * 4);
               }
               memcpy(convBitmap.picture, tmp.picture, convBitmap.sizeBytes);
               delete tmp;
            }
         }

         for(level = 0; result && (w >= 1 || h >= 1); level++, w >>= 1, h >>= 1)
         {
            Bitmap mipMap;
            int mw, mh;
            if(!w) w = 1;
            if(!h) h = 1;
            mw = w;
            mh = h;
            if(compress)
            {
               mw = (mw + 3) & (~3);
               mh = (mh + 3) & (~3);
            }

            if(bitmap.width != mw || bitmap.height != mh)
            {
               mipMap = Bitmap { };
               if(mipMap.Allocate(null, mw, mh, mw, workingFormat, false))
               {
                  Surface mipSurface = mipMap.GetSurface(0,0,null);
                  mipSurface.blend = false;
                  mipSurface.Filter(convBitmap, 0,0,0,0, mw, mh, convBitmap.width, convBitmap.height);
                  if(compress)
                  {
                     // NOTE: The mipmap dimensions are reset to not include the 4x4 blocks compression adjustment
                     mipMap.width = w;
                     mipMap.height = h;
                  }
                  delete mipSurface;
               }
               else
               {
                  result = false;
                  delete mipMap;
               }
            }
            else
               mipMap = convBitmap;

            if(result)
            {
               if(mipMaps)
               {
                  if(!retValue)
                  {
                     retValue = { mipMaps = true };
                     retValue.pixelFormat = compress ? pixelFormatETC2RGBA8 : pixelFormatRGBAGL;
                     retValue.width = mw;
                     retValue.height = mh;
                     retValue.bitmaps = new0 Bitmap[numMipMaps];
                  }
                  if(mipMap == convBitmap)
                     freeConvBitmap = false;
                  retValue.bitmaps[retValue.numMipMaps++] = mipMap;
               }
               else
               {
                  retValue = mipMap;
                  if(mipMap == convBitmap)
                     freeConvBitmap = false;
                  retValue.pixelFormat = compress ? pixelFormatETC2RGBA8 : pixelFormatRGBAGL;
               }
            }
            if(!mipMaps) break;
         }
#ifdef ETC2_COMPRESS
         if(retValue && compress)
         {
            for(level = 0; level < (mipMaps ? retValue.numMipMaps : 1); level++)
            {
               uint size = 0;
               Bitmap mipMap = mipMaps ? retValue.bitmaps[level] : retValue;
               void * pixelData = mipMap.picture;
               uint width = mipMap.width, height = mipMap.height;
               int format = 0;
#if !defined(_GLES3)
               format = 1;
#endif

               // NOTE: Re-adjust the dimensions as allocated here
               width = (width + 3) & (~3);
               height = (height + 3) & (~3);

               mipMap.picture = etc2Compress(pixelData, width, height, &size, &width, &height, format);
               mipMap.sizeBytes = size; mipMap.pixelFormat = pixelFormatETC2RGBA8;
               delete pixelData;
            }
         }
#endif
      }
      if(freeConvBitmap)
         delete convBitmap;
      return retValue;
   }
};

public class CubeMap : Bitmap
{
public:
   bool Load(DisplaySystem displaySystem, const String * names, const String extension, bool oldStyle)
   {
      int i;
      bool result = true;
      for(i = 0; result && i < 6; i++)
      {
         char location[MAX_LOCATION];
         Bitmap face = i > 0 ? { sRGB2Linear = sRGB2Linear } : this;
         strcpy(location, names[i]);
         if(extension)
            ChangeExtension(location, extension, location);
         if(face.Load(location, null, null))
         {
            face.driverData = driverData;
            result = displaySystem.driver.MakeDDBitmap(displaySystem, face, true, (i + 1) | (oldStyle << 3));
         }
         else
            result = false;
         if(i > 0)
         {
            face.driverData = 0;
            delete face;
         }
      }
      return result;
   }

   bool LoadFromFiles(DisplaySystem displaySystem, File files[6], const String extension, bool oldStyle)
   {
      int i;
      bool result = true;
      for(i = 0; result && i < 6; i++)
      {
         Bitmap face = i > 0 ? { sRGB2Linear = sRGB2Linear } : this;
         if(face.LoadFromFile(files[i], extension, null))
         {
            face.driverData = driverData;
            result = displaySystem.driver.MakeDDBitmap(displaySystem, face, true, (i + 1) | (oldStyle << 3));
         }
         else
            result = false;
         if(i > 0)
         {
            face.driverData = 0;
            delete face;
         }
      }
      return result;
   }
};
