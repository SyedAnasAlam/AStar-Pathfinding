int rows = 20;
int columns = 20;
int tileWidth;
int tileHeight;

int startX = 0;
int startY = 0;
Cell start = new Cell(startX, startY);

int destinationX = columns - 1;
int destinationY = rows - 1;
Cell destination = new Cell(destinationX, destinationY);

ArrayList<Cell> open = new ArrayList<Cell>();
ArrayList<Cell> closed = new ArrayList<Cell>();

//Containing where on the grid there are walls
int[][] walls = new int[columns][rows];
//Probability of a cell being a wall
float k = 0.4;

ArrayList<Cell> path = new ArrayList<Cell>();

//For animation of path
int i = 0;

void setup()
{
  size(800, 800);

  tileWidth = width / columns;
  tileHeight = height / rows;

  //Drawing grid
  for (int x = 0; x < columns; x++)
  {
    for (int y = 0; y < rows; y++)
    {
      fill(255);
      strokeWeight(2);
      rect(tileWidth * x, tileHeight * y, tileWidth, tileHeight);
    }
  }

  //Making random walls
  for (int i = 0; i < columns; i++)
  {
    for (int j = 0; j < rows; j++)
    {
      if (random(0, 1) < k)
      {
        walls[i][j] = 1;
      }

      if (walls[i][j] == 1)
      {
        fill(234, 32, 39);
        rect(tileWidth * i, tileHeight * j, tileWidth, tileHeight);
      }
    }
  }
  
  path = Pathfind();
}

void draw()
{
  frameRate(5);
  
  fill(0, 148, 50);
  rect(path.get(i).x * tileWidth, path.get(i).y * tileHeight, tileWidth, tileHeight);
  
  if (i < path.size() - 1) i++;
}

boolean CheckBounds(Cell c)
{
  return c.x < 0 || c.x >= columns || c.y < 0 || c.y >= rows;
}

ArrayList<Cell> Neighbours(Cell c)
{
  Cell cEast = new Cell(c.x + 1, c.y);
  Cell cWest = new Cell(c.x - 1, c.y);
  Cell cNorth = new Cell(c.x, c.y - 1);
  Cell cSouth = new Cell(c.x, c.y + 1);

  ArrayList<Cell> neighbours = new ArrayList<Cell>();

  if (!CheckBounds(cEast))
    if (walls[cEast.x][cEast.y] == 0)
      neighbours.add(cEast);

  if (!CheckBounds(cWest))
    if (walls[cWest.x][cWest.y] == 0)
      neighbours.add(cWest);

  if (!CheckBounds(cNorth))
    if (walls[cNorth.x][cNorth.y] == 0)
      neighbours.add(cNorth);

  if (!CheckBounds(cSouth))
    if (walls[cSouth.x][cSouth.y] == 0)
      neighbours.add(cSouth);

  return neighbours;
}

boolean Contains(ArrayList<Cell> list, Cell nabour)
{
  for (Cell c : list)
  {
    if (c.x == nabour.x && c.y == nabour.y)
    {
      return true;
    }
  }
  return false;
}

//Finding cell with lowest F score
Cell NextCell(ArrayList<Cell> list)
{
  int check = 999;
  Cell nextCell = new Cell();
  for (Cell c : list)
  {
    if (c.F() < check)
    {
      check = c.h;
      nextCell = c;
    }
  }
  return nextCell;
}

//Heuristic function 
int Heuristic(Cell a, Cell b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  //Manhattan:
  return abs((int)dx) + abs((int)dy);
  
  //Euclidian:
  //return (int)sqrt(pow(dx, 2) + pow(dy, 2));
}

//A*
ArrayList<Cell> Pathfind()
{
  open.add(start);
  do
  {
    Cell current = NextCell(open);
    closed.add(current);
    open.remove(current);
    
    if (Contains(closed, destination))
    {
      break;
    }

    for (Cell c : Neighbours(current))
    {
      if (Contains(closed, c))
      {
        continue;
      }
      
      if (Contains(open, c))
      {
        if ((current.g + 1) < c.g)
        {
          c.g = current.g + 1;
          c.parent = current;
        }
      }
      else
      {
        c.parent = current;
        c.g = c.parent.g + 1;
        c.h = Heuristic(c, destination);
        open.add(c);
      }
    }
  } while (open.size() > 0);
  
  Cell end = closed.get(closed.size() - 1);
  if(end.x != destination.x && end.y != destination.y || walls[0][0] == 1) println("No path");
  return BuildPath(end);
}

ArrayList<Cell> BuildPath(Cell c)
{
  path.add(c);

  if (c.parent != null)
  {
    BuildPath(c.parent);
  }
  return path;
}
