import "Display"

public class Resource
{
   virtual void Reference(Resource resource);
   virtual void Load(Resource copy, DisplaySystem displaySystem);
   virtual void Dereference(void);
};

private class ResPtr : struct
{
   ResPtr prev, next;
   Resource resource;
   void * loaded;
};

public class GfxResourceManager
{
   Display display;
   OldList resources;

public:
   public property Display display
   {
      set { display = value; }
      get { return display; }
   }

   void AddResource(Resource resource)
   {
      if(resource)
      {
         ResPtr ptr { resource = resource };
         resources.Add(ptr);
         incref resource;

         // Load Graphics here if window is created already
         if(display)
         {
            display.Lock(false);
            if(!ptr.loaded)
               ptr.loaded = display.displaySystem.LoadResource(resource);
            display.Unlock();
         }
      }
   }

   void RemoveResource(Resource resource)
   {
      if(resource)
      {
         ResPtr ptr;
         for(ptr = resources.first; ptr; ptr = ptr.next)
         {
            if(ptr.resource == resource)
               break;
         }

         if(ptr)
         {
            // Unload Graphics here if window is created already
            if(display)
            {
               if(ptr.loaded)
               {
                  display.Lock(false);
                  display.displaySystem.UnloadResource(resource, ptr.loaded);
                  display.Unlock();
                  ptr.loaded = null;
               }
            }
            delete resource;
            resources.Delete(ptr);
         }
      }
   }
}
