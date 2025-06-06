#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
import "fmFontManager"
#endif

public class FontResource : Resource
{
public:
   property const char * faceName { set { delete faceName; faceName = CopyString(value); } get { return this ? faceName : null; } };
   property float size { set { size = value; } get { return this ? size : 0; } };
   property bool bold { set { flags.bold = value; } get { return this ? flags.bold : false; } };
   property bool italic { set { flags.italic = value; } get { return this ? flags.italic : false; } };
   property bool underline { set { flags.underline = value; } get { return this ? flags.underline : false; } };
   property Font font { get { return this ? font : null; } };
   property GfxResourceManager manager { set { if(value != null) { value.RemoveResource(this); value.AddResource(this); } }  };
   property float outlineSize { set { outlineSize = value; } get { return this ? outlineSize : 0; } };
   property float outlineFade { set { outlineFade = value; } get { return this ? outlineFade : 0; } };
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
   property FMFont fmFont { get { return this ? fmFont : null; } };
#endif

private:
   char * faceName;
   Font font;
   float size;
   FontFlags flags;
   DisplaySystem displaySystem;
   float outlineSize, outlineFade;
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
   FontManager fm;
   FMFont fmFont;
#endif

   void Load(FontResource copy, DisplaySystem displaySystem)
   {
      delete faceName;
      faceName = *&CopyString(copy.faceName);
      *&size = *&copy.size;
      *&flags = *&copy.flags;
      *&outlineSize = *&copy.outlineSize;
      *&outlineFade = *&copy.outlineFade;
      if(faceName && displaySystem)
      {
         this.displaySystem = displaySystem;
         font = displaySystem.LoadOutlineFont(faceName, size, flags, outlineSize, outlineFade);
      }
   }

#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
   void LoadFM(FontResource copy, DisplaySystem displaySystem, FontManager fm)
   {
      Load(copy, displaySystem);
      if(fm)
      {
         this.fm = fm;
         fmFont = fm.getFont(this);
      }
   }
#endif

   void Reference(FontResource reference)
   {
      delete faceName;
      faceName = *&CopyString(reference.faceName);
      *&size = *&reference.size;
      *&flags = *&reference.flags;
      *&outlineSize = *&reference.outlineSize;
      *&outlineFade = *&reference.outlineFade;
      font = reference.font;
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
      fmFont = reference.fmFont;
#endif
   }

   void Dereference()
   {
      font = null;
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
      fmFont = null;
#endif
   }

   ~FontResource()
   {
      if(font && displaySystem)
         displaySystem.UnloadFont(font);
#if !defined(GFX_VANILLA) && !defined(GFX_ONEDRIVER) && !defined(GFX_NO3D) && !defined(GFX_NOGL)
      if(fmFont && fm)
         fm.removeFont(fmFont);
#endif
      delete faceName;
   }

   void OnCopy(FontResource newData)
   {
      if(newData)
      {
         size = newData.size;
         delete faceName; faceName = CopyString(newData.faceName);
         flags = newData.flags;
         outlineSize = newData.outlineSize;
         outlineFade = newData.outlineFade;
      }
      else
      {
         size = 0;
         flags = 0;
         outlineSize = 0;
         outlineFade = 0;
         delete faceName;
      }
   }

/*
   Window OnEdit(Window window, Window master, int x, int y, int w, int h, void * userData)
   {
      Window editData = class::OnEdit(window, master, x + 24,y,w - 48,h, userData);
      Button browse
      {
         window, master = editData, inactive = true, text = "...", hotKey = F2,
         position = { Max(x + 24, x + w - 24), y }, size = { 24, h }
      };
      browse.Create();
      return editData;
   }

   void OnDisplay(Surface surface, int x, int y, int width, void * fieldData, Alignment alignment, DataDisplayFlags flags)
   {
      char * string = this ? faceName : null;
      Font font = this ? font : null;
      if(!string) string = "(none)";
      surface.WriteTextDots(alignment, x + 24, y + 1, width - 24, string, strlen(string));
      surface.SetBackground(White);
      surface.Area(x - 4, y, x + 20, y + 15);

      surface.SetForeground(Black);
      surface.Rectangle(x-1, y + 1, x + 18, y + 14);
   }

   int OnCompare(FontResource font2)
   {
      int result = 0;
      if(this && font2)
      {
         char * string1 = faceName;
         char * string2 = font2.faceName;
         if(string1 && string2)
            result = strcmpi(string1, string2);
      }
      return result;
   }

   const char * OnGetString(char * string, void * fieldDat, ObjectNotationType * onType)
   {
      if(this)
      {
         char * fileName = faceName;
         if(fileName)
            strcpy(string, fileName);
         else
            string[0] = '\0';
         return string;
      }
      return null;
   }

   bool OnGetDataFromString(const char * string)
   {
      this = (string && string[0]) ? FontResource { } : null;
      if(this)
         faceName = string;
   }
*/
};
