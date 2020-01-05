class Node
{
  int val;
  int x;
  int y;
  int h;
  int g;
  Node parent;
  
  Node(int Val, int X, int Y)
  {
    val = Val;
    x = X;
    y = Y;
  }
  
  Node()
  { 
  }
  
  int F()
  {
    return g + h;
  }
}
