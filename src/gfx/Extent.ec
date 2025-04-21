#ifdef EC_STATIC
public import static "ecrt"
#else
public import "ecrt"
#endif

private class BoxItem : Item //FastItem
{
   Box box;
};

// REVIEW: This is used for Display::Scroll()
public struct Extent : OldList
{
   void Empty()
   {
      Free(null);
   }

   void AddBox(Box box)
   {
      //BoxItem extentBox = (BoxItem)Add(sizeof(class BoxItem));
      Add(BoxItem { box = box });
   }

   void Copy(Extent source)
   {
      BoxItem extentBox;

      // Clear();
      Empty();
      //FASTLIST_LOOP(source, extentBox)
      for(extentBox = (BoxItem)source.first; extentBox; extentBox = (BoxItem)extentBox.next)
         AddBox(extentBox.box);
   }

   void IntersectBox(Box box)
   {
      // Clip all boxes of extent against inside of the new box
      BoxItem extentBox, next;

      //FASTLIST_LOOPN(this, extentBox, next)   // Macros still mess up the parser!
      for(extentBox = (BoxItem)this.first; extentBox; extentBox = next)
      {
         next = (BoxItem)extentBox.next;
         if(box.left > extentBox.box.left) extentBox.box.left = box.left;
         if(box.top > extentBox.box.top) extentBox.box.top = box.top;
         if(box.right < extentBox.box.right) extentBox.box.right = box.right;
         if(box.bottom < extentBox.box.bottom) extentBox.box.bottom = box.bottom;
         if(extentBox.box.right < extentBox.box.left || extentBox.box.bottom < extentBox.box.top)
            Delete(extentBox);
      }
   }

   void ExcludeBox(Box box, Extent temp)
   {
      BoxItem extentBox;

      temp.Copy(this);
      Empty();

      for(extentBox = (BoxItem)temp.first; extentBox; extentBox = (BoxItem)extentBox.next)
      {
         if(extentBox.box.left < box.right && extentBox.box.right > box.left &&
            extentBox.box.top < box.bottom && extentBox.box.bottom > box.top)
         {
            // Top box
            if(extentBox.box.top < box.top && extentBox.box.bottom >= box.top)
            {
               Box newBox
               {
                  extentBox.box.left, extentBox.box.top,
                  extentBox.box.right, Min(extentBox.box.bottom, box.top -1)
               };
               AddBox(newBox);
            }

            // Bottom box
            if(extentBox.box.bottom > box.bottom && extentBox.box.top <= box.bottom)
            {
               Box newBox
               {
                  extentBox.box.left, Max(extentBox.box.top,box.bottom +1),
                  extentBox.box.right, extentBox.box.bottom
               };
               AddBox(newBox);
            }

            // Middle boxes
            if(extentBox.box.bottom >= box.top && extentBox.box.top <= box.bottom)
            {
               // Left box
               if(extentBox.box.left < box.left && extentBox.box.right >= box.left)
               {
                  Box newBox
                  {
                     extentBox.box.left, Max(extentBox.box.top, box.top),
                     Min(extentBox.box.right, box.left-1), Min(extentBox.box.bottom, box.bottom)
                  };
                  AddBox(newBox);
               }

               // Right box
               if(extentBox.box.right > box.right && extentBox.box.left <= box.right)
               {
                  Box newBox
                  {
                     Max(extentBox.box.left, box.right+1), Max(extentBox.box.top, box.top),
                     extentBox.box.right, Min(extentBox.box.bottom, box.bottom)
                  };
                  AddBox(newBox);
               }
            }
         }
         else
         {
            AddBox(extentBox.box);
         }
      }
      temp.Empty();
   }

   void UnionBox(Box box, Extent temp)
   {
      BoxItem extentBox, next;

      // First pass: check if this box is not already covered by one of the extent's box
      for(extentBox = (BoxItem)this.first; extentBox; extentBox = (BoxItem)extentBox.next)
      {
         if(extentBox.box.left <= box.left && extentBox.box.right >= box.right &&
            extentBox.box.top <= box.top && extentBox.box.bottom >= box.bottom)
         {
            // No change
            return;
         }
      }

      // Second pass: only keep boxes not completely covered in the new box
      for(extentBox = (BoxItem)this.first; extentBox; extentBox = next)
      {
         next = (BoxItem)extentBox.next;
         if(extentBox.box.left >= box.left && extentBox.box.right <= box.right &&
            extentBox.box.top >= box.top && extentBox.box.bottom <= box.bottom)
            Delete(extentBox);
      }

      // Add the exclusion to the extent
      ExcludeBox(box, temp);

      // Add the new box
      if(box.bottom >= box.top && box.right >= box.left)
      {
         // Optimization: if the resulting boxes touch, add them smarter
         for(extentBox = (BoxItem)this.first; extentBox; extentBox = (BoxItem)extentBox.next)
         {
            if(box.top == extentBox.box.top && box.bottom == extentBox.box.bottom)
            {
               if(Abs(box.right - extentBox.box.left) <= 1)
               {
                  extentBox.box.left = box.left;
                  break;
               }
               else if(Abs(box.left - extentBox.box.right) <= 1)
               {
                  extentBox.box.right = box.right;
                  break;
               }
            }
            else if(box.left == extentBox.box.left && box.right == extentBox.box.right)
            {
               if(Abs(box.bottom - extentBox.box.top) <= 1)
               {
                  extentBox.box.top = box.top;
                  break;
               }
               else if(Abs(box.top - extentBox.box.bottom) <= 1)
               {
                  extentBox.box.bottom = box.bottom;
                  break;
               }
            }
         }

         // Else, add it
         if(!extentBox)
            AddBox(box);
      }
   }

   void Union(Extent b, Extent temp)
   {
      BoxItem extentBox;

      for(extentBox = (BoxItem)b.first; extentBox; extentBox = (BoxItem)extentBox.next)
         UnionBox(extentBox.box, temp);
   }

   void Intersection(Extent b, Extent temp, Extent temp2, Extent temp3)
   {
      BoxItem extentBox;
      temp.Copy(this);

      Empty();

      for(extentBox = (BoxItem)b.first; extentBox; extentBox = (BoxItem)extentBox.next)
      {
         temp2.Copy(temp);
         temp2.IntersectBox(extentBox.box);
         Union(temp2, temp3);
         temp2.Empty();
      }
      temp.Empty();
   }

   void Exclusion(Extent b, Extent temp)
   {
      BoxItem extentBox;
      for(extentBox = (BoxItem)b.first; extentBox; extentBox = (BoxItem)extentBox.next)
         ExcludeBox(extentBox.box, temp);
   }

   void Offset(int x, int y)
   {
      BoxItem extentBox;
      for(extentBox = (BoxItem)this.first; extentBox; extentBox = (BoxItem)extentBox.next)
      {
         extentBox.box.left += x;
         extentBox.box.top += y;
         extentBox.box.right += x;
         extentBox.box.bottom += y;
      }
   }
};
