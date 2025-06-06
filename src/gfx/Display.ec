#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

bool IsDriverTextMode(const char * driverName)
{
   subclass(DisplayDriver) driver = GetDisplayDriver(driverName);
   return driver ? driver.textMode : false;
}

bool IsDriverPrinter(const char * driverName)
{
   subclass(DisplayDriver) driver = GetDisplayDriver(driverName);
   return driver ? driver.printer : false;
}

#if (defined(GFX_VANILLA) || defined(GFX_ONEDRIVER)) && defined(__WIN32__)
#define GFX_NOTRUETYPE
#endif

import "Extent"
import "Color"
import "Bitmap"
import "Surface"
import "DisplaySystem"
import "Resource"
import "FontResource"
import "BitmapResource"

import "LFBDisplayDriver"

// TOFIX: Temporary until we pass Display instead of DisplaySystem to FontExtent
#if defined(__WIN32__) && !defined(GFX_NOTRUETYPE) && !defined(__UWP__)
import "GDIDisplayDriver"
#endif

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
import "Camera"
import "Plane"
import "Matrix"
import "Mesh"
import "Object"
import "Quaternion"
import "Vector3D"
import "DepthSort"
#endif

#if (!defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL))
import "OpenGLDisplayDriver"

#define Size Size_
#define near near_
#define far far_
#define String String_
#include "gl123es.h"
#undef near
#undef far
#undef Size
#undef String
#endif

public class GLCapabilities : uint
{
public:
   // Expect reloading graphics
   bool compatible      :1;
   bool vertexBuffer    :1;
   bool quads           :1;
   bool intAndDouble    :1;
   bool legacyFormats   :1;
   bool nonPow2Textures :1;
   bool vertexPointer   :1;

   // Should be able to toggle without reloading
   bool legacy          :1;
   bool shaders         :1;
   bool fixedFunction   :1;
   bool immediate       :1;
   bool frameBuffer     :1;
   bool pointSize       :1;
   bool vao             :1;
   bool select          :1;
   // bool mapBuffer       :1;

   bool debug           :1;
   bool gpuCommands     :1;
   bool mdei            :1;

   GLSamplesCount samples:3;
};

public enum GLSamplesCount { none, ms2, ms4, ms8, ms16 };

public enum RenderState { fillMode = 1, depthTest, depthWrite, fogDensity, fogColor, blend, ambient, alphaWrite, antiAlias, vSync };

public union RenderStateFloat { float f; uint ui; };

public enum FillModeValue { solid, wireframe };

public class DisplayFlags
{
   public bool fullScreen:1, flipping:1, alpha:1, memBackBuffer:1, text:1, scrolling:1, printer:1;
};
public class FontFlags
{
   public bool bold:1, italic:1, underline:1;
};

__attribute__((unused)) static void DummyFunction()
{
#if !defined(__EMSCRIPTEN__)
   Mutex { };
#endif
}

public class DisplayDriver
{
public:
   class_data const char * name;
   class_data bool textMode;
   class_data bool printer;
   class_data DisplaySystem displaySystem;

   class_property DisplaySystem displaySystem
   {
      set { class_data(displaySystem) = value; }
      get { return class_data(displaySystem); }
   };

   class_property const char * name
   {
      set { class_data(name) = value; }
      get { return class_data(name); }
   };

   class_property bool printer
   {
      set { class_data(printer) = value; }
      get { return class_data(printer); }
   };

   // Constructor / Destructor
   virtual bool ::CreateDisplaySystem(DisplaySystem);
   virtual void ::DestroyDisplaySystem(DisplaySystem);

   virtual bool ::CreateDisplay(Display);
   virtual void ::DestroyDisplay(Display);

   // Display Position and Size
   virtual bool ::DisplaySize(Display, int, int);
   virtual void ::DisplayPosition(Display, int, int);

   // Palettes
   virtual void ::SetPalette(Display, ColorAlpha *, bool);
   virtual void ::RestorePalette(Display);

   // Display the back buffer content
   virtual void ::StartUpdate(Display);
   virtual void ::Scroll(Display, Box, int, int, Extent);
   virtual void ::Update(Display, Box);
   virtual void ::EndUpdate(Display);

   // Allocate/free a bitmap
   virtual bool ::AllocateBitmap(DisplaySystem, Bitmap, int, int, int, PixelFormat, bool);
   virtual void ::FreeBitmap(DisplaySystem, Bitmap);

   // Lock
   virtual bool ::LockSystem(DisplaySystem displaySystem);
   virtual void ::UnlockSystem(DisplaySystem displaySystem);

   virtual bool ::Lock(Display);
   virtual void ::Unlock(Display);

   // Get/release a surface
   virtual bool ::GetSurface(Display, Surface surface, int,int,Box);
   virtual bool ::GetBitmapSurface(DisplaySystem displaySystem, Surface surface, Bitmap bitmap, int,int,Box);
   virtual void ::ReleaseSurface(Display this, Surface);

   // Clip a surface
   virtual void ::Clip(Display, Surface, Box);

   // Grab from the screen
   virtual bool ::GrabScreen(Display, Bitmap, int, int, unsigned int, unsigned int);

   // Converts a bitmap format
   virtual bool ::ConvertBitmap(DisplaySystem, Bitmap, PixelFormat, ColorAlpha *);

   // Converts an LFB bitmap into an offscreen bitmap for this device
   virtual bool ::MakeDDBitmap(DisplaySystem, Bitmap, bool mipMaps, int cubeMapFace);

   // Font loading
   virtual Font ::LoadFont(DisplaySystem displaySystem, const char * faceName, float size, FontFlags flags, float outlineSize, float outlineFade);
   virtual void ::UnloadFont(DisplaySystem, Font);

   // 2D Drawing
   virtual void ::SetForeground(Display, Surface, ColorAlpha);
   virtual void ::SetBackground(Display, Surface, ColorAlpha);
   virtual void ::LineStipple(Display, Surface, uint pattern);
   virtual ColorAlpha ::GetPixel(Display, Surface, int x, int y);
   virtual void ::PutPixel(Display, Surface, int x, int y);
   virtual void ::DrawLine(Display, Surface, int x1, int y1, int x2, int y2);
   virtual void ::Rectangle(Display, Surface, int x1, int y1, int x2, int y2);
   virtual void ::Area(Display, Surface, int x1, int y1, int x2, int y2);
   virtual void ::Clear(Display, Surface, ClearType);
   virtual void ::Blit(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h);
   virtual void ::Stretch(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h, int sw, int sh);
   virtual void ::Stretchf(Display, Surface, Bitmap, float dx, float dy, float sx, float sy, float w, float h, float sw, float sh);
   virtual void ::Filter(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h, int sw, int sh);
   virtual void ::BlitDI(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h);
   virtual void ::StretchDI(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h, int sw, int sh);
   virtual void ::FilterDI(Display, Surface, Bitmap, int dx, int dy, int sx, int sy, int w, int h, int sw, int sh);
   virtual void ::TextFont(Display, Surface, Font);
   virtual void ::TextOpacity(Display, Surface, bool);
   virtual void ::WriteText(Display, Surface, int x, int y, const String text, int len, int prevGlyph, int * rPrevGlyph);
   virtual void ::TextExtent(Display, Surface, const String text, int len, int * tw, int * th, int prevGlyph, int * rPrevGlyph, int * overHang);
   virtual void ::FontExtent(DisplaySystem, Font, const String text, int len, int * tw, int * th, int prevGlyph, int * rPrevGlyph, int * overHang);
   virtual void ::DrawingChar(Display, Surface, char ch);
   virtual void ::NextPage(Display);
#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
   // 3D Graphics
   virtual void ::SetRenderState(Display, RenderState, uint);
   virtual void ::SetLight(Display, int, Light);
   virtual void ::SetCamera(Display, Surface, Camera);
   virtual bool ::AllocateMesh(DisplaySystem, Mesh, MeshFeatures, int nVertices);
   virtual void ::FreeMesh(DisplaySystem, Mesh);
   virtual bool ::LockMesh(DisplaySystem, Mesh, MeshFeatures flags);
   virtual void ::UnlockMesh(DisplaySystem, Mesh, MeshFeatures flags);
   virtual void * ::AllocateIndices(DisplaySystem, int nIndices, bool indices32bit);
   virtual void ::FreeIndices(DisplaySystem, PrimitiveSingle group);
   virtual uint16 * ::LockIndices(DisplaySystem, PrimitiveSingle group);
   virtual void ::UnlockIndices(DisplaySystem, PrimitiveSingle group, bool indices32bit, int nIndices, void * maeb);
   virtual void ::SelectMesh(Display, Mesh);
   virtual void ::ApplyMaterial(Display, Material, Mesh);
   virtual void ::DrawPrimitives(Display, PrimitiveSingle, Mesh mesh);
   virtual void ::PushMatrix(Display);
   virtual void ::PopMatrix(Display, bool);
   virtual void ::SetTransform(Display, Matrix, bool, bool);
   virtual void ::SetCameraVR(Display, Camera, int eye, int w, int h, void * fb, const Matrix prjMat);
#endif
   virtual void ::SetBlitTint(Display, Surface, ColorAlpha);   // REVIEW: Is it really necessary to have a method here, we have a Surface member
};

public enum Alignment { left, right, center };
public enum ClearType { colorBuffer, depthBuffer, colorAndDepth };

define textCellW = 8;
define textCellH = 16;

public enum PixelFormat // : byte MESSES UP GuiApplication
{
   pixelFormat4, pixelFormat8, pixelFormat444, pixelFormat555, pixelFormat565, pixelFormat888, pixelFormatAlpha, pixelFormatText, pixelFormatRGBA,
   pixelFormatA16, pixelFormatRGBAGL /* TODO: clarify pixelFormatRGBA vs. GL-ready */, pixelFormatETC2RGBA8
};
public enum Resolution : int
{
   resText80x25, res320x200, res320x240, res320x400, res360x480, res400x256, res400x300, res512x256, res512x384,
   res640x200, res640x350, res640x400, res640x480,  res720x348, res800x600, res856x480, res960x720, res1024x768,
   res1152x864, res1280x1024, res1600x1200, res768x480
};

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
public class LightFlags
{
   public bool off:1, spot:1, omni:1, attenuation:1;
};

public struct Light
{
   LightFlags flags;
   ColorRGB ambient;
   ColorRGB diffuse;
   ColorRGB specular;
   Vector3D direction;
   Quaternion orientation;
   Object lightObject;
   Object target;
   Degrees fallOff;
   Degrees hotSpot;
   float Kc;
   float Kl;
   float Kq;
   Degrees start;
   Degrees end;
   float multiplier;
};

public define NumberOfLights = 8;

public class HitRecord : struct
{
public:
   HitRecord prev, next;
   uint pos;
   uint numTags;
   Vector3D center;
   void * tags[1];   // More tags may follow

   int Compare(HitRecord recordB, void * unused)
   {
      if(center.z > recordB.center.z)
         return 1;
      else if(center.z < recordB.center.z)
         return -1;
      else if(pos > recordB.pos)
         return 1;
      else if(pos < recordB.pos)
         return -1;
      else
         return  0;
   }
};

#endif

#define MAX_CLIP_POINTS    50

#if !defined(_GLES) && !defined(_GLES2)
#define USE_32_BIT_INDICES true
#define uintindex uint32
#else
#define USE_32_BIT_INDICES false
#define uintindex uint16
#endif

static uintindex * transIndices = null;
static int transSize = 0;

#define NUM_ROTATE_BUFS 40

public class Display
{
public:
   ~Display()
   {
      if(displaySystem)
      {
         displaySystem.numDisplays--;
         if(!displaySystem.numDisplays)
         {
            transSize = 0;
            delete transIndices;
         }
         displaySystem.driver.DestroyDisplay(this);
      }
#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
      delete display3D;
#endif
   }

   bool Create(DisplaySystem displaySystem, void * window)
   {
      bool result = false;
      if(displaySystem)
      {
         this.displaySystem = displaySystem;
         this.window = window;
         displaySystem.numDisplays++;
         if(displaySystem.driver.CreateDisplay(this))
            result = true;
         // if(!result) LogErrorCode(DisplayInitFailed, displaySystem.driver.name);
      }
      return result;
   }

   Surface GetSurface(int x, int y, Box clip)
   {
      Surface result = null;
      Surface surface { _refCount = 1 };
      if(surface)
      {
         Box box { -x, -y, -x + width - 1, -y + height - 1 };
         box.Clip(clip);

         surface.width = width - x;
         surface.height = height - y;
         surface.driver = displaySystem.driver;
         surface.displaySystem = displaySystem;
         surface.display = this;

         if(displaySystem.driver.GetSurface(this, surface, x, y, box))
            result = surface;
         if(!result)
            delete surface;
      }
      return result;
   }

   bool Resize(int width, int height)
   {
      return displaySystem.driver.DisplaySize(this, width, height);
   }

   void Position(int x, int y)
   {
      displaySystem.driver.DisplayPosition(this, x,y);
   }

   void StartUpdate(void)
   {
      displaySystem.driver.StartUpdate(this);
   }

   void Scroll(Box scroll, int x, int y, Extent dirty)
   {
      displaySystem.driver.Scroll(this, scroll, x, y, dirty);
   }

   void Update(Box updateBox)
   {
      displaySystem.driver.Update(this, updateBox);
   }

   void EndUpdate(void)
   {
      displaySystem.driver.EndUpdate(this);
   }

   void NextPage(void)
   {
      displaySystem.driver.NextPage(this);
   }

   bool Grab(Bitmap bitmap, int x, int y, int w, int h)
   {
      bool result = false;
      if(bitmap && w > 0 && h > 0 &&
         displaySystem.driver.GrabScreen(this, bitmap, x, y, w, h))
         result = true;
      else
         bitmap.Free();
      return result;
   }

   void FontExtent(Font font, const char * text, int len, int * width, int * height)
   {
      int overHang = 0;
      FontExtent2(font, text, len, width, height, 0, null, &overHang);
      if(width) *width += overHang;
   }

   void FontExtent2(Font font, const char * text, int len, int * width, int * height, int prevGlyph, int * rPrevGlyph, int * overHang)
   {
      // Fix for OnLoadGraphics time alpha blended window text extent on GDI
#if defined(__WIN32__) && !defined(GFX_NOTRUETYPE) && !defined(__UWP__)
      if(this && alphaBlend && pixelFormat == pixelFormat888 &&
         displaySystem.driver == class(GDIDisplayDriver))
      {
         Surface s = GetSurface(0,0,null);
         if(s)
         {
            s.font = font;
            s.TextExtent2(text, len, width, height, prevGlyph, rPrevGlyph, overHang);
            delete s;
         }
      }
      else
#endif
         // TODO: Should really pass display here...
         DisplaySystem::FontExtent2(this ? displaySystem : null, font, text, len, width, height, prevGlyph, rPrevGlyph, overHang);
   }

   void SetPalette(ColorAlpha * palette, bool colorMatch)
   {
       displaySystem.driver.SetPalette(this, palette, colorMatch);
   }

   void RestorePalette(void)
   {
      displaySystem.driver.RestorePalette(this);
   }

   bool Lock(bool render)
   {
      bool result = false;
      /*
      int c;
      for(c = 0; c<current; c++)
         Log("   ");
      Logf("Locking (%d)\n", current+1);
      */

      // TOCHECK: Why is displaySystem null with GISDesigner?
      result = displaySystem && displaySystem.Lock();
      if(result && render)
      {
#if !defined(__EMSCRIPTEN__)
         mutex.Wait();
#endif

         if(!current)
            result = displaySystem.driver.Lock(this);
         else
            result = true;
         current++;
      }
      return result;
   }

   void Unlock(void)
   {
      if(current)
      {
         current--;
         /*{
            int c;

            for(c = 0; c<current; c++)
               Log("   ");
            Logf("Unlocking (%d)\n", current);
         }
         */
         if(!current && displaySystem)
            displaySystem.driver.Unlock(this);
#if !defined(__EMSCRIPTEN__)
         mutex.Release();
#endif
      }
      if(displaySystem)
         displaySystem.Unlock();
   }

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
   // *** 3D GRAPHICS ***
   void SetCamera(Surface surface, const Camera camera)
   {
      Camera cam = (void *)camera;
      if(!display3D)
      {
         display3D = Display3D { };
      }
      if(!display3D.selection)
         DrawTranslucency();

      if(!cam)
      {
         if(!display3D.selection)
            displaySystem.driver.SelectMesh(this, null);

         display3D.material = null;
         display3D.mesh = null;
      }
      if(!display3D.selection)
      {
         displaySystem.driver.SetCamera(this, surface, cam);
      }

      this.display3D.camera = cam;

      if(cam)
      {
         if(!cam.focalX)
            cam.Setup(width, height, null);

         // Always calling Update() here had broken interpolation in OrbitWithMouse!
         if(!cam.cAngle.w && surface)
            cam.Update();

         if(display3D.selection)
         {
            // Compute Picking Planes
            Vector3D normal;
            Vector3D point { 0,0,0 };
            Quaternion quat;
            Angle fovLeft, fovRight, fovTop, fovBottom;
            ClippingPlane c;

            double l = cam.origin.x - (display3D.pickX - display3D.pickWidth/2.0f);
            double r = cam.origin.x - (display3D.pickX + display3D.pickWidth/2.0f);
            double t = (display3D.pickY - display3D.pickHeight/2.0f) - cam.origin.y;
            double b = (display3D.pickY + display3D.pickHeight/2.0f) - cam.origin.y;

            fovLeft   = atan(l / cam.focalX);
            fovRight  = atan(r / cam.focalX);
            fovTop    = atan(t / cam.focalY);
            fovBottom = atan(b / cam.focalY);

            // --- Left ---
            quat.Yaw(fovLeft - Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[left].FromPointNormal(normal, point);

            // --- Right ---
            quat.Yaw(fovRight + Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[right].FromPointNormal(normal, point);

            // --- Top ---
            quat.Pitch(fovTop + Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[top].FromPointNormal(normal, point);

            // --- Bottom ---
            quat.Pitch(fovBottom - Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[bottom].FromPointNormal(normal, point);

            // --- Near ---
            normal.x = 0; normal.y = 0; normal.z = 1;
            point.z = cam.zMin;
            display3D.viewPickingPlanes[near].FromPointNormal(normal, point);

            // --- Far ---
            normal.x = 0; normal.y = 0; normal.z = -1;
            point.z = cam.zMax;
            display3D.viewPickingPlanes[far].FromPointNormal(normal, point);

            for(c = 0; c<ClippingPlane::enumSize; c++)
               display3D.worldPickingPlanes[c].MultMatrix(display3D.viewPickingPlanes[c], cam.inverseTranspose);

            // Compute picking ray
            {
               Vector3D p;
               display3D.rayView.p0 = { 0, 0, 0 };
               p.x = display3D.pickX;
               p.y = display3D.pickY;
               p.z = 0.0f;
               cam.Unproject(p, display3D.rayView.delta);

               // Convert ray to world space
               cam.Untransform(display3D.rayView.p0, display3D.rayWorld.p0);
               cam.Untransform(display3D.rayView.delta, p);    // This is a point transform, and origin is 0,0,0
               display3D.rayWorld.delta.Subtract(p, display3D.rayWorld.p0);
            }
         }
      }
   }

   void SetCameraVR(Camera camera, int eye, int w, int h, GLFB output, const Matrix prjMat)
   {
      if(!display3D)
      {
         display3D = Display3D { };
      }
      if(!display3D.selection)
         DrawTranslucency();

      if(!camera)
      {
         if(!display3D.selection)
            displaySystem.driver.SelectMesh(this, null);

         display3D.material = null;
         display3D.mesh = null;
      }
      if(!display3D.selection)
      {
         displaySystem.driver.SetCameraVR(this, camera, eye, w, h, output, prjMat);
      }

      this.display3D.camera = camera;

      if(camera)
      {
         /* TODO:
         if(!camera.focalX)
            camera.Setup(width, height, null);

         // Always calling Update() here had broken interpolation in OrbitWithMouse!
         if(!camera.cAngle.w && surface)
            camera.Update();

         if(display3D.selection)
         {
            // Compute Picking Planes
            Vector3D normal;
            Vector3D point { 0,0,0 };
            Quaternion quat;
            Angle fovLeft, fovRight, fovTop, fovBottom;
            ClippingPlane c;

            double l = camera.origin.x - (display3D.pickX - display3D.pickWidth/2.0f);
            double r = camera.origin.x - (display3D.pickX + display3D.pickWidth/2.0f);
            double t = (display3D.pickY - display3D.pickHeight/2.0f) - camera.origin.y;
            double b = (display3D.pickY + display3D.pickHeight/2.0f) - camera.origin.y;

            fovLeft   = atan(l / camera.focalX);
            fovRight  = atan(r / camera.focalX);
            fovTop    = atan(t / camera.focalY);
            fovBottom = atan(b / camera.focalY);

            // --- Left ---
            quat.Yaw(fovLeft - Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[left].FromPointNormal(normal, point);

            // --- Right ---
            quat.Yaw(fovRight + Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[right].FromPointNormal(normal, point);

            // --- Top ---
            quat.Pitch(fovTop + Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[top].FromPointNormal(normal, point);

            // --- Bottom ---
            quat.Pitch(fovBottom - Pi/2);
            quat.ToDirection(normal);
            display3D.viewPickingPlanes[bottom].FromPointNormal(normal, point);

            // --- Near ---
            normal.x = 0; normal.y = 0; normal.z = 1;
            point.z = camera.zMin;
            display3D.viewPickingPlanes[near].FromPointNormal(normal, point);

            // --- Far ---
            normal.x = 0; normal.y = 0; normal.z = -1;
            point.z = camera.zMax;
            display3D.viewPickingPlanes[far].FromPointNormal(normal, point);

            for(c = 0; c<ClippingPlane::enumSize; c++)
               display3D.worldPickingPlanes[c].MultMatrix(display3D.viewPickingPlanes[c], camera.inverseTranspose);

            // Compute picking ray
            {
               Vector3D p;
               display3D.rayView.p0 = { 0, 0, 0 };
               p.x = display3D.pickX;
               p.y = display3D.pickY;
               p.z = 0.0f;
               camera.Unproject(p, display3D.rayView.delta);

               // Convert ray to world space
               camera.Untransform(display3D.rayView.p0, display3D.rayWorld.p0);
               camera.Untransform(display3D.rayView.delta, p);
               display3D.rayWorld.delta.Subtract(p, display3D.rayWorld.p0);
            }
         }*/
      }
   }

   // --- Lights ---
   void SetLight(int id, Light light)
   {
      if(!display3D)
      {
         display3D = Display3D { };
      }
      displaySystem.driver.SetLight(this, id, light);
   }

   void SetLights(Object object)
   {
      if(object)
         display3D._SetLights(this, object, 0);
   }

   // --- Transformations ---

   void SetTransform(Matrix matrix, bool viewSpace)
   {
      if(display3D.selection)
      {
         ClippingPlane c;
         Matrix transpose;
         transpose.Transpose(matrix);

         if(viewSpace)
         {
            for(c = 0; c<ClippingPlane::enumSize; c++)
               display3D.localPickingPlanes[c].MultMatrix(display3D.viewPickingPlanes[c], transpose);
         }
         else
         {
            for(c = 0; c<ClippingPlane::enumSize; c++)
               display3D.localPickingPlanes[c].MultMatrix(display3D.worldPickingPlanes[c], transpose);
         }

         // Transform ray
         if(display3D.intersecting || (!display3D.pickWidth && !display3D.pickHeight) /* Also used for MollerTrumbore */)
         {
            Vector3D p2, tp2;

            if(viewSpace)
               p2.Add(display3D.rayView.p0, display3D.rayView.delta);
            else
               p2.Add(display3D.rayWorld.p0, display3D.rayWorld.delta);

            display3D.rayLocal.p0.DivideMatrix(display3D.rayWorld.p0, matrix);
            tp2.DivideMatrix(p2, matrix);
            display3D.rayLocal.delta.Subtract(tp2, display3D.rayLocal.p0);

            display3D.rlInvDelta.x = 1.0 / display3D.rayLocal.delta.x;
            display3D.rlInvDelta.y = 1.0 / display3D.rayLocal.delta.y;
            display3D.rlInvDelta.z = 1.0 / display3D.rayLocal.delta.z;
         }
      }
      else
         displaySystem.driver.SetTransform(this, matrix, viewSpace, viewSpace ? false : true);
   }

   void PushMatrix(void)
   {
      displaySystem.driver.PushMatrix(this);
   }

   void PopMatrix(void)
   {
      displaySystem.driver.PopMatrix(this, true);
   }

   // --- Drawing ---
   void ApplyMaterial(Material material, Mesh mesh)
   {
      if(!display3D || material != display3D.material)
      {
         if(display3D) display3D.material = material;
         displaySystem.driver.ApplyMaterial(this, material, mesh);
      }
   }

   void DrawPrimitives(PrimitiveSingle primitive, Mesh mesh)
   {
      displaySystem.driver.DrawPrimitives(this, primitive, mesh);
   }

   void SelectMesh(Mesh mesh)
   {
      displaySystem.driver.SelectMesh(this, mesh);
      if(display3D)
         display3D.mesh = mesh;
   }

   bool DrawMesh(Object object)
   {
      return DrawMeshEx(object, null);
   }

   bool DrawMeshEx(Object object, uint64 * id)
   {
      bool result = false;
      if(display3D.selection)
         result = display3D.PickMeshEx(object, null, id);
      else
      {
         Mesh mesh = *&object.mesh;
         Material objectMaterial = object.material;
         MaterialFlags partlyTransparent = 0;
         PrimitiveGroup group = (&mesh.groups)->first;
         subclass(DisplayDriver) driver = displaySystem.driver;
         ObjectFlags flags = *&object.flags;
         int nPrimitives = mesh.nPrimitives;

         if(!objectMaterial) objectMaterial = defaultMaterial;

         if(group)
         {
            Material curMaterial = display3D.material;

            if(display3D.mesh != mesh)
            {
#if !defined(_GLES) && !defined(_GLES2) && !defined(GFX_NOGL)
               if(!mesh.mab || !display3D.mesh || display3D.mesh.mab != mesh.mab || mesh.flags & { tangents = true, colors = true, bones = true } || mesh.flags != display3D.mesh.flags)
#endif
                  driver.SelectMesh(this, mesh);
            }
            display3D.mesh = mesh;

            for(; group; group = group.next)
            {
               if(!group.type.hide)
               {
                  Material material = group.material;
                  if(!material) material = objectMaterial;
                  partlyTransparent |= material.flags & MaterialFlags { partlyTransparent = true };
                  if(material != curMaterial)
                  {
                     curMaterial = material;
                     driver.ApplyMaterial(this, material, mesh);
                  }

                  // *** Render Vertex Arrays ***
                  driver.DrawPrimitives(this, (PrimitiveSingle *)&group.type, mesh);
               }
            }
            display3D.material = curMaterial;
         }

         if(partlyTransparent)
            display3D.partlyTransparentObjects.Add(object);
         if(flags.translucent)
         {
            Matrix matrix, invTrans;
            int c;

            if(flags.viewSpace)
               matrix = object.matrix;
            else
            {
               Camera camera = display3D.camera;
               Matrix temp = object.matrix;
               temp.m[3][0] -= camera.cPosition.x;
               temp.m[3][1] -= camera.cPosition.y;
               temp.m[3][2] -= camera.cPosition.z;
               matrix.Multiply(temp, camera.viewMatrix);
            }
            matrix.Scale(1,1,-1);   // With the new comparison the scale is actually unnecessary...

            invTrans.InverseTransposeTransform(matrix);

            for(c = 0; c < nPrimitives; c++)
            {
               PrimitiveSingle * triangle = &mesh.primitives[c];
               SortPrimitive * sort;
               Plane * plane = &triangle->plane;
               uint triIndex = display3D.nTriangles;
               bool backface;
               Material material = triangle->material;

               if(!material || !material.opacity || triangle->type.hide) continue;
               if(display3D.nTriangles >= display3D.maxTriangles)
               {
                  display3D.maxTriangles = display3D.maxTriangles ? (display3D.maxTriangles * 3 / 2) : 32768;
                  display3D.triangles = renew display3D.triangles SortPrimitive[display3D.maxTriangles];
               }

               sort = &display3D.triangles[triIndex];
               sort->middle.MultMatrix(triangle->middle, matrix);
               sort->plane.MultMatrix(plane, invTrans);
               sort->plane.normal.Normalize(sort->plane.normal);
               sort->plane.d = -(sort->plane.a * sort->middle.x + sort->plane.b * sort->middle.y + sort->plane.c * sort->middle.z);

               backface = sort->plane.d <= 0;
               if(backface && !material.flags.doubleSided)
                  continue;

               sort->object = object;
               sort->triangle = triangle;
               sort->node = null;

               display3D.nTriangles++;
            }
         }
         else if(nPrimitives)
         {
            int c;
            PrimitiveSingle * primitives = mesh.primitives;

            if(!group && display3D.mesh != mesh
#if !defined(GFX_NOGL)
               && (!mesh.mab || !display3D.mesh || display3D.mesh.mab != mesh.mab || mesh.flags & { tangents = true, colors = true, bones = true } || mesh.flags != display3D.mesh.flags)
#endif
               )
               displaySystem.driver.SelectMesh(this, mesh);
            display3D.mesh = mesh;

            for(c = 0; c<nPrimitives; c++)
            {
               PrimitiveSingle * primitive = &primitives[c];
               Material material = primitive->material ? primitive->material : objectMaterial;
               if(!material) material = defaultMaterial;

               if(material != display3D.material)
               {
                  display3D.material = material;
                  displaySystem.driver.ApplyMaterial(this, material, mesh);
               }
               displaySystem.driver.DrawPrimitives(this, primitive, display3D.mesh);
            }
         }
         result = true;
      }
      return result;
   }

   bool IsObjectVisible(Object object)
   {
      Plane * planes;
      ObjectFlags flags = *&object.flags;
      Display3D display3D = this.display3D;
      Camera camera = display3D.camera;
      if(display3D.selection || !camera)
         planes = flags.viewSpace ? display3D.viewPickingPlanes : display3D.worldPickingPlanes;
      else
         planes = flags.viewSpace ? camera.viewClippingPlanes : camera.worldClippingPlanes;
       return object.InsideFrustum(planes) != outside;
   }

   bool DrawObject(Object object)
   {
      return DrawObjectEx(object, null);
   }

   bool DrawObjectEx(Object object, uint64 * id)
   {
      bool result = false;
      if(object && object.volume)
      {
         Object child;
         FrustumPlacement visible;
         Plane * planes;
         Display3D display3D = this.display3D;
         Camera camera = display3D.camera;
         ObjectFlags flags = *&object.flags;
         bool viewSpace = flags.viewSpace;

         if(flags.hide) return false;

         display3D.cullEnabled = -1;

         if(display3D.selection || !camera)
            planes = viewSpace ? display3D.viewPickingPlanes : display3D.worldPickingPlanes;
         else
            planes = viewSpace ? camera.viewClippingPlanes : camera.worldClippingPlanes;

         visible = object.InsideFrustum(planes);

         if(visible || display3D.pickingPlanes)
         {
            if(display3D.collectingHits && object.tag)
            {
               /*if(flags.root)
                  this.tags[display3D.tagIndex] = object.tag;
               else if(object.tag)
                  this.tags[++display3D.tagIndex] = object.tag;
                  */
               display3D.tags[display3D.tagIndex++] = object.tag;
            }

            if(flags.mesh && object.mesh)
            {
               Vector3D wresult, vresult;

               if(!display3D.selection && displaySystem.driver.PushMatrix)
                  displaySystem.driver.PushMatrix(this);

#if ENABLE_GL_FFP
               if(object.mesh.tangents && object.mesh.normals && flags.computeLightVectors)
               {
                  Mesh mesh = object.mesh;
                  if(!glCaps_shaders)
                  {
                     int count = mesh.nVertices;
                     Vector3Df * normals = mesh.normals;
                     Vector3Df * vertices = mesh.vertices;
                     ColorRGB * lightVectors;
                     Vector3Df * tangents = mesh.tangents;
                     int i;
                     float * l = display3D.light0Pos;
                     Vector3Df light { l[0], l[1], l[2] };
                     Matrix o = object.matrix;
                     Matrix t, inv = camera.viewMatrix;
                     Vector3D ot { };
                     Vector3D cPos = camera.cPosition;
                     Vector3D pos;
                     bool positional = l[3] ? true : false;

                     inv.Scale(1.0/nearPlane, -1.0/nearPlane,-1.0/nearPlane);

                     pos.MultMatrix(cPos, camera.viewMatrix);

                     ot.x = o.m[3][0] + pos.x;
                     ot.y = o.m[3][1] + pos.y;
                     ot.z = o.m[3][2] + pos.z;
                     o.m[3][0] = 0;
                     o.m[3][1] = 0;
                     o.m[3][2] = 0;
                     t.Multiply(o, inv);
                     inv = t;
                     t.Transpose(inv);
                     inv.Inverse(t);

                     mesh.Allocate({ lightVectors = true }, mesh.nVertices, displaySystem);
                     mesh.Lock({ lightVectors = true });
                     lightVectors = mesh.lightVectors;
                     for(i = 0; i < count; i++)
                     {
                        Vector3Df tangent1 = tangents[i*2 + 0];
                        Vector3Df tangent2 = tangents[i*2 + 1];
                        Vector3Df normal = normals[i];
                        Vector3Df tTangent1, tTangent2, tNormal;

                        tTangent1.MultMatrix(tangent1, inv);
                        tTangent2.MultMatrix(tangent2, inv);
                        tNormal  .MultMatrix(normal,   inv);

                        tTangent1.Normalize(tTangent1);
                        tTangent2.Normalize(tTangent2);
                        tNormal  .Normalize(tNormal);

                        {
                           Matrix tbn
                           { {
                               tTangent1.x, tTangent2.x, tNormal.x, 0,
                               tTangent1.y, tTangent2.y, tNormal.y, 0,
                               tTangent1.z, tTangent2.z, tNormal.z, 1
                           } };
                           Vector3Df n;
                           if(positional)
                           {
                              Vector3Df tPos = vertices[i];
                              tPos.x += ot.x, tPos.y += ot.y, tPos.z += ot.z;

                              // Subtract vertex from light for positional lights
                              light.x = l[0] - tPos.x;
                              light.y = l[1] + tPos.y;
                              light.z = l[2] - tPos.z;
                           }
                           n.MultMatrix(light, tbn);
                           if(positional)
                              n.Normalize(n);
                           lightVectors[i] = { n.x / 2 + 0.5f, n.y / 2 + 0.5f, n.z / 2 + 0.5f };
                        }
                     }
                     mesh.Unlock({ lightVectors = true });

                     // Create normalization cube map
                     /*
                     if(!mesh.normMap)
                        mesh.normMap = { };
                     {
                        int w = 256, h = 256, d = 256;
                        Vector3Df min = mesh.min, max = mesh.max;
                        Vector3Df delta
                        {
                           (max.x - min.x) / w,
                           (max.y - min.y) / h,
                           (max.z - min.z) / d
                        };
                        int i;
                        for(i = 0; i < 6; i++)
                        {
                           Bitmap face = i > 0 ? { } : mesh.normMap;
                           int x, y;
                           ColorAlpha * p;
                           face.Free();
                           face.Allocate(null, w, h, 0, pixelFormat888, false);
                           face.driverData = mesh.normMap.driverData;
                           p = (ColorAlpha *)face.picture;
                           for(y = 0; y < h; y++)
                           {
                              for(x = 0; x < w; x++, p++)
                              {
                                 Vector3Df v { min.x + x * delta.x, min.y + y * delta.y, min.z };
                                 v.Normalize(v);
                                 *p = ColorAlpha { 255, {
                                       (byte)((v.x / 2.0 + 0.5) * 255),
                                       (byte)((v.y / 2.0 + 0.5) * 255),
                                       (byte)((v.z / 2.0 + 0.5) * 255) } };
                             }
                           }
                           displaySystem.driver.MakeDDBitmap(displaySystem, face, true, (i + 1));
                           if(i > 0)
                           {
                              face.driverData = 0;
                              delete face;
                           }
                        }
                     }
                     */
                  }
                  else
                     mesh.Free({ lightVectors = true });
               }
#endif

               SetTransform(&object.matrix, viewSpace);
               if(display3D.selection)
               {
                  if(visible == intersecting || display3D.intersecting)
                  {
                     Vector3D rayIntersect;
                     if(display3D.PickMeshEx(object, rayIntersect, id))
                     {
                        if(display3D.intersecting)
                        {
                           wresult.MultMatrix(rayIntersect, object.matrix);
                           if(!viewSpace)
                              camera.TransformPoint(vresult, wresult);
                           else
                              vresult = wresult;

                           if(vresult.z < display3D.rayIntersect.z)
                              display3D.rayIntersect = vresult;      // Returned ray intersect is in viewspace
                           display3D.intersected = true;
                        }
                        result = true;
                     }
                  }
                  else
                     result = true;
               }
               else
               {
                  result |= DrawMesh(object);
                  if(displaySystem.driver.PopMatrix)
                     displaySystem.driver.PopMatrix(this, true);
               }
               if(display3D.collectingHits && result /*&& object.tag*/)
               {
                  int c;
                  HitRecord hit = (HitRecord)new0 byte[sizeof(class HitRecord) + sizeof(void *) * (display3D.tagIndex/*+1*/)];
                  display3D.hitList.Add(hit);
                  hit.pos = display3D.hitList.count-1;
                  hit.numTags = display3D.tagIndex /*+ 1*/;
                  for(c = 0; c</*=*/display3D.tagIndex; c++)
                  {
                     hit.tags[c] = display3D.tags[c];
                  }

                  if(display3D.intersecting)
                     hit.center = vresult;
                  else if(!viewSpace)
                     camera.TransformPoint(hit.center, object.wcenter);
                  else
                     hit.center = object.wcenter;
               }
            }

            for(child = object.children.first; child; child = child.next)
               result |= DrawObjectEx(child, id);

            if(display3D.collectingHits && /*!flags.root && */object.tag)
               display3D.tagIndex--;
         }
      }
      return result;
   }

   private void DrawPartlyTransparentMesh(Object object)
   {
      if(!display3D.selection)
      {
         Mesh mesh = object.mesh;
         Material objectMaterial = object.material;
         PrimitiveGroup group = (&mesh.groups)->first;
         if(group)
         {
            subclass(DisplayDriver) driver = displaySystem.driver;
            if(display3D.mesh != mesh
#if !defined(GFX_NOGL)
               && (!mesh.mab || !display3D.mesh || display3D.mesh.mab != mesh.mab || mesh.flags & { tangents = true, colors = true, bones = true } || mesh.flags != display3D.mesh.flags)
#endif
               )
               driver.SelectMesh(this, mesh);
            display3D.mesh = mesh;

            for(; group; group = group.next)
            {
               Material material = group.material ? group.material : objectMaterial;
               if(!material) material = defaultMaterial;
               if(!group.type.hide && material.flags.partlyTransparent)
               {
                  if(material != display3D.material)
                  {
                     display3D.material = material;
                     material.flags.partlyTransparent = false;
                     driver.ApplyMaterial(this, material, mesh);
                     material.flags.partlyTransparent = true;
                  }

                  // *** Render Vertex Arrays ***
                  driver.DrawPrimitives(this, (PrimitiveSingle *)&group.type, mesh);
               }
            }
         }
      }
   }

   void DrawTranslucency(void)
   {
      if(display3D && display3D.camera)
      {
         // *** Render translucent primitives ***
         if(display3D.nTriangles || display3D.partlyTransparentObjects.count)
         {
            Matrix * matrix = null;
            int c;
            int toFlush = 0;
            Object * partlyTransparentObjects = display3D.partlyTransparentObjects.array;
            int count = display3D.partlyTransparentObjects.count;
            subclass(DisplayDriver) driver = displaySystem.driver;
            int i;
         #if !defined(GFX_NOGL)
            GLEAB * transBuffer = display3D.transBuffer;
         #endif
            int * bufSizes = display3D.bufSizes;
            int bufID = display3D.bufID;

            // *** Sort translucent primitives ***
            sortPrimitives(display3D.triangles, display3D.nTriangles, display3D.camera, display3D.sortData,
               display3D.maxFullSort, display3D.fullProjCheck);

            blend = true;
            depthWrite = false;

            // TODO: Review rendering 32 bit index meshes with OpenGL ES
            if(display3D.nTriangles * 6/*3*/ > transSize)
            {
               transSize = Max(transSize, display3D.nTriangles * 6 /*3*/);
               transIndices = renew transIndices uintindex[display3D.nTriangles * 6 /*3*/];
            }

            driver.PushMatrix(this);
            display3D.material = null;
            display3D.mesh = null;

            for(i = 0; i < count; i++)
            {
               Object o = partlyTransparentObjects[i];
               if(o.mvMatrix[0])
               {
#if !defined(GFX_NOGL)
                  glmsLoadMatrixf(o.mvMatrix);   // TODO: Handle this properly...
#endif
                  DrawPartlyTransparentMesh(o);
               }
               else
               {
                  driver.PushMatrix(this);
                  SetTransform(&o.matrix, (*&o.flags).viewSpace);
                  DrawPartlyTransparentMesh(o);
                  driver.PopMatrix(this, true);
               }
            }
            display3D.partlyTransparentObjects.minAllocSize = display3D.partlyTransparentObjects.size;
            display3D.partlyTransparentObjects.size = 0;

            for(c = 0; c <= display3D.nTriangles; c++)
            {
               bool past = c == display3D.nTriangles;
               SortPrimitive * sort = past ? null : &display3D.triangles[c];
               // if(sort && !sort->object) continue;
               Mesh mesh = past ? null : *&sort->object.mesh;
               PrimitiveSingle * primitive = past ? null : sort->triangle;
               bool ix32 = !past && primitive ? primitive->type.indices32bit : false;
               uint32 * indices32 = past ? null : ix32 ?                                 // baseIndex set but not used for Singles?

                  (primitive->type.sharedIndices && mesh.indices ? mesh.indices + primitive->baseIndexMesh : primitive->indices32) :
                  null;
               uint16 * indices16 = past || ix32 ? null : primitive->indices;
               Material material = past ? null : /*sort->material;  */primitive->material ? primitive->material : sort->object.material;
               bool newMatrix, newMesh, newMaterial;
               if(!material) material = defaultMaterial;
               newMatrix   = past ? false : &sort->object.matrix != matrix;
               newMesh     = past ? false : (display3D.mesh != mesh
#if !defined(GFX_NOGL)
                  && (!mesh.mab || !display3D.mesh || display3D.mesh.mab != mesh.mab || mesh.flags & { tangents = true, colors = true, bones = true } || mesh.flags != display3D.mesh.flags /* || is16Bit */)
                        // TODO: Don't combine for different baseVertex for 16 bit indices?
#endif
                  );
               newMaterial = past ? false : material != display3D.material;

               if(past || newMatrix || newMesh || newMaterial)
               {
                  // TODO: Was translucency support for Direct3D broken?
#if !defined(GFX_NOGL)
                  if(!transBuffer[bufID].buffer || toFlush > bufSizes[bufID])
                  {
                     transBuffer[bufID].allocate(toFlush * sizeof(uint32), null, streamDraw);
                     bufSizes[bufID] = toFlush;
                  }
                  if(toFlush)
                  {
                     uint baseVertex = 0; // TODO: Don't combine for different baseVertex for 16 bit indices?

                     transBuffer[bufID].upload(0, toFlush * sizeof(uint32), transIndices);
                     transBuffer[bufID].draw2(GL_TRIANGLES, toFlush,
                        USE_32_BIT_INDICES ? GL_UNSIGNED_INT : GL_UNSIGNED_SHORT, glCaps_vertexBuffer ? 0 : transIndices, baseVertex);
                     toFlush = 0;
                     bufID++;
                     if(bufID >= NUM_ROTATE_BUFS)
                        bufID = 0;
                  }
#endif
                  if(past)
                     break;
               }


               if(newMatrix)
               {
                  matrix = &sort->object.matrix;

                  driver.PopMatrix(this, false);
                  driver.PushMatrix(this);
                  SetTransform(matrix, sort->object.flags.viewSpace);
               }
               if(newMesh)
               {
                  driver.SelectMesh(this, mesh);
                  display3D.mesh = mesh;
               }

               if(newMaterial)
               {
                  driver.ApplyMaterial(this, material, display3D.mesh);
                  display3D.material = material;
               }

               /*
               if(primitive->type.vertexRange)
               {
                  transIndices[toFlush+0] = primitive->first;
                  transIndices[toFlush+1] = primitive->first+1;
                  transIndices[toFlush+2] = primitive->first+2;
                  toFlush += 3;
                  if(primitive->type == quads)
                  {
                     transIndices[toFlush+0] = primitive->first;
                     transIndices[toFlush+1] = primitive->first+2;
                     transIndices[toFlush+2] = primitive->first+3;
                     toFlush += 3;
                  }
               }
               else*/
               {
                  int meshBaseVertex = mesh.baseVertex;  // TODO: Don't combine for different baseVertex for 16 bit indices?

                  // Handled by SelectMesh when no base vertex support or if we have tangents or colors
#if defined(_GLES) || defined(_GLES2)
                  meshBaseVertex = 0;
#else
                  if(mesh.flags & { tangents = true, colors = true, bones = true })
                     meshBaseVertex = 0;
#endif

                  if(indices32)
                  {
                     transIndices[toFlush+0] = (uintindex)indices32[0] + meshBaseVertex;
                     transIndices[toFlush+1] = (uintindex)indices32[1] + meshBaseVertex;
                     transIndices[toFlush+2] = (uintindex)indices32[2] + meshBaseVertex;
                  }
                  else
                  {
                     transIndices[toFlush+0] = indices16[0] + meshBaseVertex;
                     transIndices[toFlush+1] = indices16[1] + meshBaseVertex;
                     transIndices[toFlush+2] = indices16[2] + meshBaseVertex;
                  }
                  toFlush += 3;
                  if(primitive->type == quads)
                  {
                     if(indices32)
                     {
                        transIndices[toFlush+0] = (uintindex)indices32[0] + meshBaseVertex;
                        transIndices[toFlush+1] = (uintindex)indices32[2] + meshBaseVertex;
                        transIndices[toFlush+2] = (uintindex)indices32[3] + meshBaseVertex;
                     }
                     else
                     {
                        transIndices[toFlush+0] = indices16[0] + meshBaseVertex;
                        transIndices[toFlush+1] = indices16[2] + meshBaseVertex;
                        transIndices[toFlush+2] = indices16[3] + meshBaseVertex;
                     }
                     toFlush += 3;
                  }
               }
            }

            display3D.bufID = bufID;

#if !defined(GFX_NOGL)
            GLABBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
#endif

            driver.PopMatrix(this, true);

            display3D.nTriangles = 0;
            blend = false;
            depthWrite = true;
         }
      }
   }

   // --- Picking ---
   void StartSelection(int pickX, int pickY, int pickW, int pickH)
   {
      if(!display3D)
      {
         display3D = Display3D { };
      }
      display3D.pickX = (float)pickX;
      display3D.pickY = (float)pickY;
      display3D.pickWidth = (float)pickW;
      display3D.pickHeight = (float)pickH;
      display3D.selection = true;
   }

   void CollectHits(void)
   {
      display3D.collectingHits = true;
   }

   int GetHits(OldList list)
   {
      display3D.collectingHits = false;
      display3D.hitList.Sort(HitRecord::Compare, null);
      list = display3D.hitList;
      display3D.hitList.Clear();
      return list.count;
   }

   void IntersectPolygons(void)
   {
      display3D.rayIntersect = { MAXFLOAT, MAXFLOAT, MAXFLOAT };
      display3D.intersected = false;
      display3D.intersecting = true;
   }

   // Document that returned ray intersect is in viewspace
   bool GetIntersect(Vector3D intersect)
   {
      intersect = display3D.rayIntersect;
      display3D.intersecting = false;
      return display3D.intersected;
   }

   void StopSelection(void)
   {
      display3D.selection = false;
   }

   // --- Rendering States ---
   property FillModeValue fillMode { set { displaySystem.driver.SetRenderState(this, fillMode, value); } };
   property bool depthTest    { set { displaySystem.driver.SetRenderState(this, depthTest, value); } };
   property bool depthWrite   { set { displaySystem.driver.SetRenderState(this, depthWrite, value); } };
   property float fogDensity  { set { displaySystem.driver.SetRenderState(this, fogDensity, RenderStateFloat { value }.ui); } };
   property Color fogColor    { set { displaySystem.driver.SetRenderState(this, fogColor, value); } };
   property bool blend        { set { displaySystem.driver.SetRenderState(this, blend, value); } };
   property Color ambient     { set { displaySystem.driver.SetRenderState(this, ambient, value); } };
   property bool alphaWrite   { set { displaySystem.driver.SetRenderState(this, alphaWrite, value); } };
   property bool antiAlias    { set { displaySystem.driver.SetRenderState(this, antiAlias, value); } };
   property bool vSync        { set { displaySystem.driver.SetRenderState(this, vSync, value); } };

   property bool pickingPlanes { set { display3D.pickingPlanes = value; } };
   property int maxFullSort { set { display3D.maxFullSort = value; } get { return display3D.maxFullSort; } }
   property bool fullProjCheck { set { display3D.fullProjCheck = value; } get { return display3D.fullProjCheck; } }
#endif
   property DisplayFlags flags { get { return displaySystem.flags; } }
   property PixelFormat pixelFormat { get { return /*alphaBlend ? pixelFormat888 : */displaySystem.pixelFormat; } }
   property bool alphaBlend { set { alphaBlend = value; } get { return alphaBlend; } };
   property bool useSharedMemory { set { useSharedMemory = value; } get { return useSharedMemory; } };
   property void * systemWindow { get { return window; } };
   property DisplaySystem displaySystem { get { return displaySystem; } };
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D)
   property GLCapabilities glCapabilities
   {
      get
      {
#if !defined(GFX_NOGL)
         return ((OGLDisplay)driverData).capabilities;
#else
         return 0;
#endif
      }
      set
      {
         glCapabilities = value;
#if !defined(GFX_NOGL)
         if(driverData && displaySystem.driver == class(OpenGLDisplayDriver))
         {
            OGLDisplay oglDisplay = driverData;
            if(!oglDisplay.originalCapabilities.fixedFunction)
               value.shaders = true;
            if(!oglDisplay.originalCapabilities.shaders)
               value.fixedFunction = true;
            // Disable things that don't work with shaders
            if(value.shaders)
            {
               value.fixedFunction = false;
               value.legacy = false;
               value.immediate = false;
            }
            oglDisplay.capabilities = oglDisplay.originalCapabilities & value;

            Lock(true);
            OpenGLDisplayDriver::initialDisplaySetup(this, true, false);
            Unlock();
         }
#endif
      }
   };
   property int glVersion
   {
      get
      {
#if !defined(GFX_NOGL)
         return ((OGLDisplay)driverData).version;
#else
         return 0;
#endif
      }
   }
#endif

   int width, height;
   void * driverData;

private:

   DisplaySystem displaySystem;
   void * window;

#if !defined(__EMSCRIPTEN__)
   Mutex mutex { };
#endif
   int current;

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
   Display3D display3D;
#endif
   bool alphaBlend;

   // GLX Configuration
   void * xVisualInfo;
   void * glxFBConfig;
   bool useSharedMemory;

   GLCapabilities glCapabilities;
   glCapabilities = { true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, true, ms16 };

   public property void * xVisualInfo
   {
      set { xVisualInfo = value; }
      get { return xVisualInfo; }
   }

   public property void * glxFBConfig
   {
      set { glxFBConfig = value; }
      get { return glxFBConfig; }
   }
};

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)

// Möller and Trumbore
static inline bool intersectTriangle(const Vector3Df a, const Vector3Df b, const Vector3Df c, const Line r, double * kPtr)
{
   bool result = false;
   Vector3D e1 { b.x - a.x, b.y - a.y, b.z - a.z };
   Vector3D e2 { c.x - a.x, c.y - a.y, c.z - a.z };
   Vector3D n;
   double det;
   const Vector3D * dir = &r.delta;

   n.CrossProduct(e1, e2);
   det = -dir->DotProduct(n);
   if(Abs(det) >= 1e-6)
   {
      double invDet = 1.0 / det;
      Vector3D ao { r.p0.x - a.x, r.p0.y - a.y, r.p0.z - a.z };
      Vector3D dao;
      double u, v, k;

      dao.CrossProduct(ao, dir);
      u =  dao.DotProduct(e2) * invDet;
      v = -dao.DotProduct(e1) * invDet;
      k =  ao.DotProduct(n)   * invDet;
      result = k >= 0.0 && u >= 0.0 && v >= 0.0 && (u+v) <= 1.0;
      if(kPtr)
         *kPtr = k;
   }
   return result;
}

private class Display3D : struct
{
   // 3D Display
   int nTriangles;
   SortPrimitive * triangles;
   int maxTriangles;
   Vector3D points[MAX_CLIP_POINTS];
   Vector3D newPoints[MAX_CLIP_POINTS];
   byte goodPoints[MAX_CLIP_POINTS];
   Array<Object> partlyTransparentObjects { };

   Material material;
   Mesh mesh;
   Camera camera;
   Plane viewPickingPlanes[ClippingPlane], worldPickingPlanes[ClippingPlane];
   Plane localPickingPlanes[ClippingPlane];

   bool collectingHits, selection, intersecting, intersected, pickingPlanes;
   float pickX, pickY, pickWidth, pickHeight;
   OldList hitList;
   void * tags[64];
   int tagIndex;

   Line rayView, rayWorld, rayLocal;
   Vector3D rayIntersect;
   float light0Pos[4];
   Vector3D rlInvDelta;
   int cullEnabled;

   int maxFullSort;
   maxFullSort = 3000;
   // maxFullSort = 0;
   // maxFullSort = 1000000;
   bool fullProjCheck;
   fullProjCheck = true;

#if !defined(GFX_NOGL)
   GLEAB transBuffer[NUM_ROTATE_BUFS];
#endif
   int bufSizes[NUM_ROTATE_BUFS];
   int bufID;

   SortDataPtr sortData;

   ~Display3D()
   {
      delete triangles;
      sortData.free();
   }

   int _SetLights(Display display, Object object, int id)
   {
      if(id < NumberOfLights)
      {
         Object child;

         if(object.flags.light && !object.light.flags.off)
            display.SetLight(id++, object.light);

         for(child = object.children.first; child; child = child.next)
         {
            id = _SetLights(display, child, id);
         }
      }
      return id;
   }

   //#define THRESHOLD           -1
   //#define THRESHOLD           -0.25
   #define THRESHOLD           -0.0025

   bool PickPrimitives(Mesh mesh, PrimitiveSingle primitive, Vector3D rayDiff, Vector3D rayIntersect)
   {
      float * vertices = (float *)(mesh.skin && mesh.skin.vertices ? mesh.skin.vertices : mesh.vertices);
      return PickPrimitivesEx(mesh, vertices, primitive, rayDiff, rayIntersect, 0, null);
   }

   bool PickPrimitivesEx(Mesh mesh, float * vertices, PrimitiveSingle primitive, Vector3D rayDiff, Vector3D rayIntersect,
      int groupIx, uint64 * id)
   {
      Plane * planes = localPickingPlanes;
      bool useMollerTrumbore = !planes || (!pickWidth && !pickHeight);   // We need rayLocal to be set for MollerTrumbore
      int c = 0;
      int nIndex = 1, nPoints = 1;
      bool result = false;
      Vector3D * points = this.points;
      Vector3D * newPoints = this.newPoints;
      byte * goodPoints = this.goodPoints;
      int nVertices = primitive.type.vertexRange ? primitive.nVertices : primitive.nIndices;
      int strip = 1;
      bool i32bit = primitive.type.indices32bit;
      uint32 * indices32 = !i32bit ? null :
         primitive.indices32 != null ? primitive.indices32 : mesh.indices ? mesh.indices + primitive.baseIndexMesh : null;
      uint16 * indices16 = !i32bit && primitive.indices != null ? primitive.indices : null;
      Array<MeshPart> parts = mesh.parts;
      int pi;
      int firstPart = 0, lastPart = 0;
      // float * vertices = (float *)(mesh.skin && mesh.skin.vertices ? mesh.skin.vertices : mesh.vertices);
      int vStride = mesh.flags.interleaved ? 8 : 3;

      if(!vertices || (!indices32 && !indices16)) return false; // Need vertices and indices here...

      // Parts are currently in the Mesh rather than the PrimitiveGroup, assuming the group order (restarting at ix 0)
      // However picking currently does not seem to support groups with shared indices (baseIndex)
      if(parts && id)
      {
         int gix = -1;
         for(pi = 0; pi < parts.count; pi++)
         {
            MeshPart * part = parts && id ? &parts[pi] : null;
            if(part->start == 0)
            {
               if(++gix == groupIx)
                  lastPart = firstPart = pi;
               if(gix > groupIx)
                  break;
            }
            else if(gix == groupIx)
               lastPart = pi;
         }
      }

      for(pi = firstPart; pi <= lastPart; pi++)
      {
         MeshPart * part = parts && id ? &parts[pi] : null;
         int offset = 0;
         int start = part ? part->start : 0;
         int end = start + (part ? part->count : nVertices);   // TOCHECK: Fix part to be indices, rather than tris?
         bool done = false;
         const Vector3Df * vx[4];

         switch(primitive.type.primitiveType)
         {
            case triangles: nIndex = 3; nPoints = 3; break;
            case quads: nIndex = 4; nPoints = 4; break;
            case triStrip:
            case triFan:
               nIndex = 1; nPoints = 3;
               offset = 2;
               vx[0] = (Vector3Df *)(vertices + vStride * (primitive.type.vertexRange ? primitive.first : (i32bit ? indices32[start + 0] : indices16[start + 0])));
               vx[1] = (Vector3Df *)(vertices + vStride * (primitive.type.vertexRange ? primitive.first+1 : (i32bit ? indices32[start + 1] : indices16[start + 1])));
               break;
         }

         for(c = start + offset; c < end; c += nIndex)
         {
            bool outside = false;
            int i;

            if(primitive.type.vertexRange)
            {
               if(primitive.type.primitiveType == triStrip)
               {
                  vx[0] = (Vector3Df *)(vertices + vStride * (primitive.first + (c & 1) ? (c - 1) : (c - 2)));
                  vx[1] = (Vector3Df *)(vertices + vStride * (primitive.first + (c & 1) ? (c - 2) : (c - 1)));
               }
               else if(primitive.type.primitiveType == triFan)
               {
                  vx[0] = (Vector3Df *)(vertices + vStride * (primitive.first + 0));
                  vx[1] = (Vector3Df *)(vertices + vStride * (primitive.first + c - 1));
               }
               for(i = 0; i<nIndex; i++)
                  vx[i + offset] = (Vector3Df *)(vertices + vStride * (primitive.first + c+i));
            }
            else
            {
               if(primitive.type.primitiveType == triStrip)
               {
                  i = (c & 1) ? (c - 1) : (c - 2);
                  vx[0] = (Vector3Df *)(vertices + vStride * ((i32bit ? indices32[i] : indices16[i])));
                  i = (c & 1) ? (c - 2) : (c - 1);
                  vx[1] = (Vector3Df *)(vertices + vStride * ((i32bit ? indices32[i] : indices16[i])));
               }
               else if(primitive.type.primitiveType == triFan)
               {
                  vx[0] = (Vector3Df *)(vertices + vStride * ((i32bit ? indices32[start] : indices16[start])));
                  vx[1] = (Vector3Df *)(vertices + vStride * ((i32bit ? indices32[c-1] : indices16[c-1])));
               }
               for(i = 0; i<nIndex; i++)
                  vx[i + offset] = (Vector3Df *)(vertices + vStride * ((i32bit ? indices32[c+i] : indices16[c+i])));
            }

            if(!pickingPlanes)   // TODO: Review the meaning of this only set in orbitWithMouse
            {                    //       Calculate an intersect treating each triangles as an infinite planes?
               if(!useMollerTrumbore)
               {
                  // Classic method clipping consecutively against 6 picking planes akin to a smaller view frustum
                  ClippingPlane p;
                  int n = nPoints;

                  points[0] = { (double)vx[0]->x, (double)vx[0]->y, (double)vx[0]->z };
                  points[1] = { (double)vx[1]->x, (double)vx[1]->y, (double)vx[1]->z };
                  points[2] = { (double)vx[2]->x, (double)vx[2]->y, (double)vx[2]->z };
                  if(nPoints > 3)
                     points[3] = { (double)vx[3]->x, (double)vx[3]->y, (double)vx[3]->z };
                  for(p = 0; p < 6; p++)
                  {
                     const Plane * plane = &planes[p];
                     int i;
                     int numGoodPoints = 0;

                     memset(goodPoints, 0, n);
                     for(i = 0; i < n; i++)
                     {
                        double dot = plane->normal.DotProduct(points[i]);
                        double distance = dot + plane->d;
                        if(distance > THRESHOLD)
                        {
                           numGoodPoints++;
                           goodPoints[i] = 1;
                        }
                     }
                     if(!numGoodPoints)
                     {
                        outside = true;
                        break;
                     }
                     if(numGoodPoints < n)
                     {
                        // Clip the polygon
                        int newN = 0;
                        int lastGood = -1;
                        int j;

                        for(j = 0; j<n; )
                        {
                           if(goodPoints[j])
                           {
                              newPoints[newN++] = points[j];
                              lastGood = j++;
                           }
                           else
                           {
                              Line edge;
                              int next;

                              if(lastGood == -1)
                                 for(lastGood = n-1; !goodPoints[lastGood]; lastGood--);

                              edge.p0 = points[lastGood];
                              edge.delta.Subtract(points[j], edge.p0);
                              plane->IntersectLine(edge, newPoints[newN++]);

                              for(next = j+1; next != j; next++)
                              {
                                 if(next == n) next = 0;
                                 if(goodPoints[next])
                                 {
                                    int prev = next - 1;
                                    if(prev < 0) prev = n-1;

                                    edge.p0 = points[prev];
                                    edge.delta.Subtract(points[next], edge.p0);
                                    plane->IntersectLine(edge, newPoints[newN++]);
                                    break;
                                 }
                              }
                              if(next <= j)
                                 break;
                              else
                                 j = next;
                           }
                        }
                        // Use the new points for the next planes...
                        memcpy(points, newPoints, newN * sizeof(Vector3D));
                        n = newN;
                     }
                  }
               }
               else
               {
                  // Möller and Trumbore supporting arbitrary ray used for a null pick aperture
                  double k;
                  bool doesIntersect = intersectTriangle(vx[0], vx[1], vx[2], rayLocal, &k);
                  if(!doesIntersect && nPoints > 3)
                     doesIntersect = intersectTriangle(vx[0], vx[2], vx[3], rayLocal, &k);
                  if(doesIntersect)
                  {
                     result = true;
                     if(intersecting)
                     {
                        // TOCHECK: GetIntersect() currently returns view space intersect, but here we return local intersect
                        Vector3D intersect = rayLocal.p0;
                        intersect.x += k * rayLocal.delta.x;
                        intersect.y += k * rayLocal.delta.y;
                        intersect.z += k * rayLocal.delta.z;

                        if(k < rayDiff.z)
                        {
                           if(part && id)
                              *id = part->id;
                           rayDiff.z = k;
                           rayIntersect = intersect;
                        }
                     }
                     else
                     {
                        done = true;
                        break;
                     }
                  }
                  else
                     outside = true;
               }
            }

            if(!outside && !useMollerTrumbore)
            {
               result = true;

               if(intersecting)
               {
                  // Intersect primitives
                  Plane plane;
                  Vector3D intersect;

                  // not using 'points' as they are clipped and may all be the same here
                  plane.FromPointsf(vx[0], vx[1], vx[2]);

                  if(plane.a || plane.b || plane.c)   // Avoid bad colinear triangles...
                  {
                     Vector3D diff;
                     double k;

                     plane.IntersectLine(rayLocal, intersect);

                     // In local space
                     diff.Subtract(intersect, rayLocal.p0);
                     diff.x = (intersect.x - rayLocal.p0.x) * rlInvDelta.x;   // These should be the k of p = p0 + k * delta
                     diff.y = (intersect.y - rayLocal.p0.y) * rlInvDelta.y;   // but delta components may be 0 in local space
                     diff.z = (intersect.z - rayLocal.p0.z) * rlInvDelta.z;
                     k = Min(Min(diff.x, diff.y), diff.z);
                     if(k < rayDiff.z)
                     {
                        if(part && id)
                           *id = part->id;

                        rayDiff.z = k;
                        rayIntersect = intersect;
                     }
                  }
                  else
                  {
#ifdef _DEBUG
                     // PrintLn("WARNING: Colinear triangle");
#endif
                  }
               }
               else
               {
                  done = true;
                  break;
               }
            }

            switch(primitive.type)
            {
               case triStrip:
                  vx[strip] = vx[2];
                  strip ^= 1;
                  break;
               case triFan:
                  vx[1] = vx[2];
                  break;
            }
         }
         if(done)
            break;
      }
      return result;
   }

   bool PickMesh(Object object, Vector3D rayIntersect)
   {
      return PickMeshEx(object, rayIntersect, null);
   }

#define GPU_SKIN
   static inline void ::inlineMultMatrix(Vector3Df dest, const Vector3Df source, const Matrixf matrix)
   {
      dest.x = (float)(source.x * matrix.m[0][0] + source.y * matrix.m[1][0] + source.z * matrix.m[2][0] + matrix.m[3][0]);
      dest.y = (float)(source.x * matrix.m[0][1] + source.y * matrix.m[1][1] + source.z * matrix.m[2][1] + matrix.m[3][1]);
      dest.z = (float)(source.x * matrix.m[0][2] + source.y * matrix.m[1][2] + source.z * matrix.m[2][2] + matrix.m[3][2]);
   }

   bool PickMeshEx(Object object, Vector3D rayIntersect, uint64 * id)
   {
      Mesh mesh = object.mesh;
      bool result = false;
      Vector3D rayDiff { MAXFLOAT, MAXFLOAT, MAXFLOAT };
      Vector3Df * vertices = mesh.vertices;
      Vector3Df * tmpVertices = null;
      // We need to apply bone weights for picking
      MeshSkin skin = mesh.skin;
      if(skin)
      {
#ifdef GPU_SKIN
         Vector3Df * oVertices = mesh.vertices;
         int nVertices = skin.skinVerts.count;
         Array<Matrixf> matBones = mesh.matBones;
         int i;

         // Lock({ vertices = true });
         vertices = tmpVertices = new Vector3Df[mesh.nVertices];

         for(i = 0; i < nVertices; i++)
         {
            Vector3Df * vert = &vertices[i];
            SkinVert * sv = &skin.skinVerts[i];
            int j;
            float tw = 0;
            Vector3Df vt { };
            for(j = 0; j < MAX_BONES; j++)
            {
               int b = sv->bones[j];
               if(b != NO_BONE)
               {
                  float w = sv->weights[j] / 255.0f;
                  Vector3Df v;
                  inlineMultMatrix(v, oVertices[i], matBones[b]);
                  tw += w;
                  vt.x += w * v.x;
                  vt.y += w * v.y;
                  vt.z += w * v.z;
               }
               else
                  break;
            }

            if(tw)
            {
               tw = 1.0f / tw;
               vert->x = vt.x * tw;
               vert->y = vt.y * tw;
               vert->z = vt.z * tw;
            }
            else
               *vert = oVertices[i];
         }

         if(mesh.dupVerts)
         {
            int * dv = mesh.dupVerts.array - nVertices;
            int count = nVertices + mesh.dupVerts.count;
            for(i = nVertices; i < count; i++)
            {
               int ix = dv[i];
               vertices[i] = vertices[ix];
            }
         }
      }
#else
      if(skin.vertices)
         vertices = skin.vertices;
#endif

      if(rayIntersect != null)
         rayIntersect = { MAXFLOAT, MAXFLOAT, MAXFLOAT };

      if(mesh.groups.first)
      {
         PrimitiveGroup group;
         int groupIX = 0;

         for(group = mesh.groups.first; group; group = group.next)
         {
            if(!group.type.hide && PickPrimitivesEx(mesh, (float *) vertices, (PrimitiveSingle *)&group.type, rayDiff, rayIntersect, groupIX, id))
            {
               result = true;
               if(!intersecting)
                  break;
            }
            groupIX++;
         }
      }

      if(mesh.nPrimitives)
      {
         int c;
         for(c = 0; c < mesh.nPrimitives; c++)
         {
            PrimitiveSingle * primitive = &mesh.primitives[c];

            if(!primitive->type.hide && PickPrimitivesEx(mesh, (float *) vertices, primitive, rayDiff, rayIntersect, 0, null))
            {
               result = true;
               if(!intersecting)
                  break;
            }
         }
      }
      delete tmpVertices;

      return result;
   }
};
#endif

static ColorAlpha defaultPalette[256] =
{
   // 16 Colors
/*
   0xFF000000,0xFF000080,0xFF008000,0xFF008080,0xFF800000,0xFF800080,0xFF808000,0xFFC0C0C0,
   0xFF808080,0xFF0000FF,0xFF00FF00,0xFF00FFFF,0xFFFF0000,0xFFFF00FF,0xFFFFFF00,0xFFFFFFFF,
*/
   0xFF000000,0xFF0000AA,0xFF00AA00,0xFF00AAAA,0xFFAA0000,0xFFAA00AA,0xFFAAAA00,0xFFABABAB,
   0xFF555555,0xFF5555FF,0xFF55FF55,0xFF55FFFF,0xFFFF5555,0xFFFF55FF,0xFFFFFF55,0xFFFFFFFF,

   // 6 x 6 x 6 Color Cube
   0xFF000000, 0xFF000033, 0xFF000066, 0xFF000099, 0xFF0000CC, 0xFF0000FF,
   0xFF003300, 0xFF003333, 0xFF003366, 0xFF003399, 0xFF0033CC, 0xFF0033FF,
   0xFF006600, 0xFF006633, 0xFF006666, 0xFF006699, 0xFF0066CC, 0xFF0066FF,
   0xFF009900, 0xFF009933, 0xFF009966, 0xFF009999, 0xFF0099CC, 0xFF0099FF,
   0xFF00CC00, 0xFF00CC33, 0xFF00CC66, 0xFF00CC99, 0xFF00CCCC, 0xFF00CCFF,
   0xFF00FF00, 0xFF00FF33, 0xFF00FF66, 0xFF00FF99, 0xFF00FFCC, 0xFF00FFFF,

   0xFF330000, 0xFF330033, 0xFF330066, 0xFF330099, 0xFF3300CC, 0xFF3300FF,
   0xFF333300, 0xFF333333, 0xFF333366, 0xFF333399, 0xFF3333CC, 0xFF3333FF,
   0xFF336600, 0xFF336633, 0xFF336666, 0xFF336699, 0xFF3366CC, 0xFF3366FF,
   0xFF339900, 0xFF339933, 0xFF339966, 0xFF339999, 0xFF3399CC, 0xFF3399FF,
   0xFF33CC00, 0xFF33CC33, 0xFF33CC66, 0xFF33CC99, 0xFF33CCCC, 0xFF33CCFF,
   0xFF33FF00, 0xFF33FF33, 0xFF33FF66, 0xFF33FF99, 0xFF33FFCC, 0xFF33FFFF,

   0xFF660000, 0xFF660033, 0xFF660066, 0xFF660099, 0xFF6600CC, 0xFF6600FF,
   0xFF663300, 0xFF663333, 0xFF663366, 0xFF663399, 0xFF6633CC, 0xFF6633FF,
   0xFF666600, 0xFF666633, 0xFF666666, 0xFF666699, 0xFF6666CC, 0xFF6666FF,
   0xFF669900, 0xFF669933, 0xFF669966, 0xFF669999, 0xFF6699CC, 0xFF6699FF,
   0xFF66CC00, 0xFF66CC33, 0xFF66CC66, 0xFF66CC99, 0xFF66CCCC, 0xFF66CCFF,
   0xFF66FF00, 0xFF66FF33, 0xFF66FF66, 0xFF66FF99, 0xFF66FFCC, 0xFF66FFFF,

   0xFF990000, 0xFF990033, 0xFF990066, 0xFF990099, 0xFF9900CC, 0xFF9900FF,
   0xFF993300, 0xFF993333, 0xFF993366, 0xFF993399, 0xFF9933CC, 0xFF9933FF,
   0xFF996600, 0xFF996633, 0xFF996666, 0xFF996699, 0xFF9966CC, 0xFF9966FF,
   0xFF999900, 0xFF999933, 0xFF999966, 0xFF999999, 0xFF9999CC, 0xFF9999FF,
   0xFF99CC00, 0xFF99CC33, 0xFF99CC66, 0xFF99CC99, 0xFF99CCCC, 0xFF99CCFF,
   0xFF99FF00, 0xFF99FF33, 0xFF99FF66, 0xFF99FF99, 0xFF99FFCC, 0xFF99FFFF,

   0xFFCC0000, 0xFFCC0033, 0xFFCC0066, 0xFFCC0099, 0xFFCC00CC, 0xFFCC00FF,
   0xFFCC3300, 0xFFCC3333, 0xFFCC3366, 0xFFCC3399, 0xFFCC33CC, 0xFFCC33FF,
   0xFFCC6600, 0xFFCC6633, 0xFFCC6666, 0xFFCC6699, 0xFFCC66CC, 0xFFCC66FF,
   0xFFCC9900, 0xFFCC9933, 0xFFCC9966, 0xFFCC9999, 0xFFCC99CC, 0xFFCC99FF,
   0xFFCCCC00, 0xFFCCCC33, 0xFFCCCC66, 0xFFCCCC99, 0xFFCCCCCC, 0xFFCCCCFF,
   0xFFCCFF00, 0xFFCCFF33, 0xFFCCFF66, 0xFFCCFF99, 0xFFCCFFCC, 0xFFCCFFFF,

   0xFFFF0000, 0xFFFF0033, 0xFFFF0066, 0xFFFF0099, 0xFFFF00CC, 0xFFFF00FF,
   0xFFFF3300, 0xFFFF3333, 0xFFFF3366, 0xFFFF3399, 0xFFFF33CC, 0xFFFF33FF,
   0xFFFF6600, 0xFFFF6633, 0xFFFF6666, 0xFFFF6699, 0xFFFF66CC, 0xFFFF66FF,
   0xFFFF9900, 0xFFFF9933, 0xFFFF9966, 0xFFFF9999, 0xFFFF99CC, 0xFFFF99FF,
   0xFFFFCC00, 0xFFFFCC33, 0xFFFFCC66, 0xFFFFCC99, 0xFFFFCCCC, 0xFFFFCCFF,
   0xFFFFFF00, 0xFFFFFF33, 0xFFFFFF66, 0xFFFFFF99, 0xFFFFFFCC, 0xFFFFFFFF,

   // 16 Shades of gray
   0xFF000000,0xFF101010,0xFF202020,0xFF303030,0xFF404040,0xFF505050,0xFF606060,0xFF707070,
   0xFF808080,0xFF909090,0xFFA0A0A0,0xFFB0B0B0,0xFFC0C0C0,0xFFD0D0D0,0xFFE0E0E0,0xFFF0F0F0,

   // Some more grays
   0xFF080808,0xFF101010,0xFF585858,0xFF606060,0xFFA8A8A8,0xFFB0B0B0,0xFFF8F8F8,0xFFFFFFFF

/*
   // Red
   0xFF080000,0xFF100000,0xFF180000,0xFF200000,0xFF280000,0xFF300000,0xFF380000,0xFF400000,
   0xFF480000,0xFF500000,0xFF580000,0xFF600000,0xFF680000,0xFF700000,0xFF780000,0xFF800000,
   0xFF880000,0xFF900000,0xFF980000,0xFFA00000,0xFFA80000,0xFFB00000,0xFFB80000,0xFFC00000,
   0xFFC80000,0xFFD00000,0xFFD80000,0xFFE00000,0xFFE80000,0xFFF00000,0xFFF80000,0xFFFF0000,
   // Green
   0xFF000800,0xFF001000,0xFF001800,0xFF002000,0xFF002800,0xFF003000,0xFF003800,0xFF004000,
   0xFF004800,0xFF005000,0xFF005800,0xFF006000,0xFF006800,0xFF007000,0xFF007800,0xFF008000,
   0xFF008800,0xFF009000,0xFF009800,0xFF00A000,0xFF00A800,0xFF00B000,0xFF00B800,0xFF00C000,
   0xFF00C800,0xFF00D000,0xFF00D800,0xFF00E000,0xFF00E800,0xFF00F000,0xFF00F800,0xFF00FF00,
   // Cyan
   0xFF000808,0xFF001010,0xFF001818,0xFF002020,0xFF002828,0xFF003030,0xFF003838,0xFF004040,
   0xFF004848,0xFF005050,0xFF005858,0xFF006060,0xFF006868,0xFF007070,0xFF007878,0xFF008080,
   0xFF008888,0xFF009090,0xFF009898,0xFF00A0A0,0xFF00A8A8,0xFF00B0B0,0xFF00B8B8,0xFF00C0C0,
   0xFF00C8C8,0xFF00D0D0,0xFF00D8D8,0xFF00E0E0,0xFF00E8E8,0xFF00F0F0,0xFF00F8F8,0xFF00FFFF,
   // Blue
   0xFF000008,0xFF000010,0xFF000018,0xFF000020,0xFF000028,0xFF000030,0xFF000038,0xFF000040,
   0xFF000048,0xFF000050,0xFF000058,0xFF000060,0xFF000068,0xFF000070,0xFF000078,0xFF000080,
   0xFF000088,0xFF000090,0xFF000098,0xFF0000A0,0xFF0000A8,0xFF0000B0,0xFF0000B8,0xFF0000C0,
   0xFF0000C8,0xFF0000D0,0xFF0000D8,0xFF0000E0,0xFF0000E8,0xFF0000F0,0xFF0000F8,0xFF0000FF,
   // Magenta
   0xFF080008,0xFF100010,0xFF180018,0xFF200020,0xFF280028,0xFF300030,0xFF380038,0xFF400040,
   0xFF480048,0xFF500050,0xFF580058,0xFF600060,0xFF680068,0xFF700070,0xFF780078,0xFF800080,
   0xFF880088,0xFF900090,0xFF980098,0xFFA000A0,0xFFA800A8,0xFFB000B0,0xFFB800B8,0xFFC000C0,
   0xFFC800C8,0xFFD000D0,0xFFD800D8,0xFFE000E0,0xFFE800E8,0xFFF000F0,0xFFF800F8,0xFFFF00FF,
   // Yellow
   0xFF080800,0xFF101000,0xFF181800,0xFF202000,0xFF282800,0xFF303000,0xFF383800,0xFF404000,
   0xFF484800,0xFF505000,0xFF585800,0xFF606000,0xFF686800,0xFF707000,0xFF787800,0xFF808000,
   0xFF888800,0xFF909000,0xFF989800,0xFFA0A000,0xFFA8A800,0xFFB0B000,0xFFB8B800,0xFFC0C000,
   0xFFC8C800,0xFFD0D000,0xFFD8D800,0xFFE0E000,0xFFE8E800,0xFFF0F000,0xFFF8F800,0xFFFFFF00,
   // White
   0xFF080808,0xFF101010,0xFF181818,0xFF202020,0xFF282828,0xFF303030,0xFF383838,0xFF404040,
   0xFF484848,0xFF505050,0xFF585858,0xFF606060,0xFF686868,0xFF707070,0xFF787878,0xFF808080,
   0xFF888888,0xFF909090,0xFF989898,0xFFA0A0A0,0xFFA8A8A8,0xFFB0B0B0,0xFFB8B8B8,0xFFC0C0C0,
   0xFFC8C8C8,0xFFD0D0D0,0xFFD8D8D8,0xFFE0E0E0,0xFFE8E8E8,0xFFF0F0F0,0xFFF8F8F8,0xFFFFFFFF
*/
};

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
static Material defaultMaterial
{
   opacity = 1.0f,
   diffuse = { 1.0f, 1.0f, 1.0f },
   ambient = { 1.0f, 1.0f, 1.0f },
   flags = { doubleSided = true, noFog = true, setupTextures = true, update = true };
};
#endif

static byte colorDepthShifts[PixelFormat] = { 0,0,1,1,1,2,0,1,2,1 };
static Size resolutions[Resolution] =
{
   {80,25},
   {320,200},{320,240},{320,400},{360,480},
   {400,256},{400,300},{512,256},{512,384},
   {640,200},{640,350},{640,400},{640,480},
   {720,348},{800,600},{856,480},{960,720},
   {1024,768},{1152,864},{1280,1024},{1600,1200},
   {768,480}
};
static int colorDepths[PixelFormat] = {4,8,12,15,16,32,8,16,32,16};

// --- Query utilities ---

public int GetResolutionWidth(Resolution resolution)
{
   return resolutions[resolution].w;
}

public int GetResolutionHeight(Resolution resolution)
{
   return resolutions[resolution].h;
}

public int GetDepthBits(PixelFormat colorDepth)
{
   return colorDepths[colorDepth];
}

public byte GetColorDepthShifts(PixelFormat format)
{
   return colorDepthShifts[format];
}

public ColorAlpha * GetDefaultPalette()
{
   return (ColorAlpha *)defaultPalette;
}
#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
public Material GetDefaultMaterial()
{
   return defaultMaterial;
}
#endif
public int BestColorMatch(ColorAlpha * palette, int start, int end, Color rgb)
{
   int best = 0;
   if(palette)
   {
      int c;
      int bestscore = MAXINT,score;
      byte r = rgb.r, g = rgb.g, b = rgb.b;
      Color current;

      for(c = start; c <= end; c++)
      {
         int dr,dg,db;
         current = palette[c];
         if(rgb && !c) continue;
         dr = r - current.r;
         dg = g - current.g;
         db = b - current.b;
         score = Abs(dr) + Abs(dg) + Abs(db);
         if(score <= bestscore)
         {
            bestscore = score;
            best = c;
         }
      }
   }
   return best;
}

// had to move this here due to compiler ordering issue for "get property" symbol
public subclass(DisplayDriver) GetDisplayDriver(const char * driverName)
{
   if(driverName)
   {
      OldLink link;
      for(link = class(DisplayDriver).derivatives.first; link; link = link.next)
      {
         subclass(DisplayDriver) displayDriver = link.data;
         if(displayDriver && displayDriver.name && !strcmp(displayDriver.name, driverName))
            return displayDriver;
      }
   }
   return null;
}

DisplaySystem GetDisplaySystem(const char * driverName)
{
   subclass(DisplayDriver) displayDriver = GetDisplayDriver(driverName);
   return displayDriver ? displayDriver.displaySystem : null;
}

#if !defined(GFX_VANILLA) && !defined(GFX_NO3D)
public struct DrawSlot
{
   Object object;
   Bitmap baseMap;

   int OnCompare(DrawSlot b)
   {
      /*
      uintptr ma = (uintptr)*&(object.mesh), mb = (uintptr)*&(b.object.mesh);
      Mesh mesh1 = (Mesh)ma, mesh2 = (Mesh)mb;
      PrimitiveGroup g1 = (&mesh1.groups)->first;
      PrimitiveGroup g2 = (&mesh2.groups)->first;
      Material mat1 = g1 ? *&g1.material : null;
      Material mat2 = g2 ? *&g2.material : null;

      if(mat1.baseMap < mat2.baseMap) return -1;
      if(mat1.baseMap > mat2.baseMap) return 1;
      if(mat1 < mat2) return -1;
      if(mat1 > mat2) return  1;
      if(ma < mb) return -1;
      if(ma > mb) return  1;
      */

      uintptr ma = (uintptr)*&(object.mesh), mb = (uintptr)*&(b.object.mesh);
      if(baseMap < b.baseMap) return -1;
      if(baseMap > b.baseMap) return 1;
      if(ma < mb) return -1;
      if(ma > mb) return  1;
      return 0;
   }
};

public class DrawList
{
   Matrix sm, svm;
   //Vector3Df sms;
   Vector3D cp;
   Plane * vp, * wp;
   Array<DrawSlot> slots { };

public:
   void init(Matrix sm, Matrix vm, Vector3D cp, Plane * vp, Plane * wp, int guessCount)
   {
      this.sm = sm;
      svm.Multiply(vm, sm);
      this.cp = cp;
      this.vp = vp;
      this.wp = wp;
      //sms = { Sgn(sm.m[0][0]), Sgn(sm.m[1][1]), Sgn(sm.m[2][2]) };

      slots.minAllocSize = Max(slots.minAllocSize, guessCount);
      slots.size = 0;
   }

   void addObject(Object object)
   {
      if(object)
      {
         ObjectFlags flags = *&object.flags;
         bool viewSpace = flags.viewSpace;
         FrustumPlacement visible = object.InsideFrustum(viewSpace ? vp : wp);
         if(visible)
         {
            Object child;
            Mesh mesh = flags.mesh ? *&object.mesh : null;
            /*Object parent = viewSpace ? null : object.parent;
            Vector3Df scaling = object.transform.scaling;
            object.mvs = parent ? parent.mvs : sms;
            object.mvs.x *= scaling.x;
            object.mvs.y *= scaling.y;
            object.mvs.z *= scaling.z;*/

            if(mesh)
            {
               DrawSlot * slot = &slots[slots.count++];
               PrimitiveGroup g = (&mesh.groups)->first;
               Material mat = g ? *&g.material : null;
               slot->object = object;
               slot->baseMap = mat ? mat.baseMap : null;
               object.setTransform(sm, svm, cp);
            }
            for(child = (*&object.children).first; child; child = child.next)
               addObject(child);
         }
      }
   }

   void prepare()
   {
      slots.Sort(true);
   }

   void render(Display display)
   {
      int i, count = this.slots.count;
      DrawSlot * slots = this.slots.array;
#if !defined(GFX_NOGL)
      Shader shader = DefaultShader::shader();
      glmsFlushMatrices();
      glEnable(GL_CULL_FACE);
#endif
      for(i = 0; i < count; i++)
      {
         Object object = slots[i].object;
#if !defined(GFX_NOGL)
         if(glCaps_shaders)
            shader.updateMatrix(modelView, object.mvMatrix, /*object.mvs,*/ false);
#if ENABLE_GL_FFP
         else
            glLoadMatrixf(object.mvMatrix);  // GLLoadMatrixf
#endif
#endif
         display.DrawMesh(object);
      }
#if !defined(GFX_NOGL)
      GLLoadMatrixd((double *)&svm);
#endif
   }
}
#endif
