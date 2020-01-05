class Cell 
{
  int x;
  int y;
  int h;
  int g;
  Cell parent;
  
  Cell(int X, int Y) 
  {
    x = X;
    y = Y;
  }
  
  Cell() 
  {
    
  }
  
  int F() 
  {
    return g + h;
  }
}
