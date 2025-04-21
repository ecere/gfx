#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

import "Resource"

public class BitmapResource : Resource
{
   char * fileName;
   Bitmap bitmap;
   bool grayed, mono, transparent;
   bool alphaBlend;
   bool mipMaps;
   int count;
   bool keepData;

   BitmapResource()
   {
      transparent = true;
   }

   ~BitmapResource()
   {
      delete bitmap;
      delete fileName;
   }

   void Load(BitmapResource copy, DisplaySystem displaySystem)
   {
      delete fileName;
      fileName = CopyString(copy.fileName);
      grayed = copy.grayed;
      mono = copy.mono;
      transparent = copy.transparent;
      alphaBlend = copy.alphaBlend;
      mipMaps = copy.mipMaps;
      keepData = copy.keepData;

      if(fileName)
      {
         DisplaySystem ds = displaySystem;

         bitmap = Bitmap { alphaBlend = (alphaBlend && displaySystem.pixelFormat != pixelFormat8), keepData = keepData };
#if defined(__WIN32__)
         // if(bitmap.alphaBlend) ds = null;
#endif
         if(
            (mipMaps && !bitmap.LoadMipMaps(fileName, null, ds)) ||
            (!mipMaps && mono && !bitmap.LoadMonochrome(fileName, null, ds)) ||
            (!mipMaps && !mono && grayed && !bitmap.LoadGrayed(fileName, null, ds)) ||
            (!mipMaps && !mono && !grayed && transparent && !bitmap.LoadT(fileName, null, ds)) ||
            (!mipMaps && !mono && !grayed && !transparent && !bitmap.Load(fileName, null, ds)))
               delete bitmap;
         if(bitmap && bitmap.alphaBlend)
         {
            bitmap.Convert(null, pixelFormat888, null);
            bitmap.displaySystem = displaySystem;
         }
      }
   }

   void Reference(BitmapResource reference)
   {
      bitmap = reference.bitmap;
      count++;
   }

   void Dereference()
   {
      count--;
      if(!count)
         bitmap = null;
   }

   void OnDisplay(Surface surface, int x, int y, int width, void * fieldData, Alignment alignment, uint /*DataDisplayFlags*/ displayFlags)
   {
      char * string = this ? fileName : null;
      Bitmap bitmap = this ? this.bitmap : null;
      // TODO: This isn't an ideal way of obtaining the clipped height, will fail on hidden areas
      int yOffset = (1+surface.box.bottom - surface.box.top - 17)/2;

/* GCC-4.4 Bug!!
      if(!string) string = "(none)";
      surface.WriteTextDots(alignment, x + 24, y + 1, width - 24, string, strlen(string));
*/
      if(string)
         surface.WriteTextDots(alignment, x + 24, y + 1, width - 24, string, strlen(string));
      else
         surface.WriteTextDots(alignment, x + 24, y + 1, width - 24, "(none)", 6);

      y += yOffset-1;
      surface.SetBackground(white);
      surface.Area(x - 4, y, x + 20, y + 15);
      if(bitmap)
         surface.Filter(bitmap, x, y + 2, 0,0, 18, 12, bitmap.width, bitmap.height);

      surface.SetForeground(black);
      surface.Rectangle(x-1, y + 1, x + 18, y + 14);
   }

public:
   property const char * fileName
   {
      set
      {
         delete fileName;
         fileName = CopyString(value);
         if(value && SearchString(value, 0, ".png", false, true))
            alphaBlend = true;
      }
      get { return this ? fileName : null; }
   };
   property bool grayed { set { grayed = value; } get { return this ? grayed : false; } };
   property bool monochrome
   {
      set
      {
         mono = value;
      }
      get { return this ? mono : false; }
   };
   property bool transparent { set { transparent = value; } get { return this ? transparent : false; } isset { return (this && !transparent) ? true : false; } };
   property bool alphaBlend
   {
      set { alphaBlend = value; }
      get { return this ? alphaBlend : false; }
      isset { return alphaBlend && (!fileName || !SearchString(fileName, 0, ".png", false, true)); }
   };
   property bool mipMaps
   {
      set { mipMaps = value; }
      get { return this ? mipMaps : false; }
      isset { return mipMaps; }
   };
   property bool keepData { set { keepData = value; } get { return this ? keepData : false; } };
   property Bitmap bitmap { get { return this ? bitmap : null; } set { bitmap = value; if(bitmap) incref bitmap; } };
   property GfxResourceManager manager { set { if(value != null) value.AddResource(this); } };
};
