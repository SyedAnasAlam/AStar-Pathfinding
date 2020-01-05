ArrayList<Node> nodeList = new ArrayList<Node>();


int[][] adjacencyMatrix; 

Node start = new Node();
Node goal = new Node();


ArrayList<Node> open = new ArrayList<Node>();
ArrayList<Node> closed = new ArrayList<Node>();

ArrayList<Node> path = new ArrayList<Node>();

//For animation of path
int i = 0;

//Framerate
int frame = 1;


int scale = 800/25;


//Variables for graph construction and drawing of graph

//Number of nodes
int nodes = 100;
//Minimum distance between every node
int min = 100;
//Diameter of nodes
int dia = 25;
//Max distance between two nodes if the two nodes is to be connected with an edge
int max = 7;
//Value between 0 and 1. Probability of a given is connected to another node which is within max-distance
float k = 0.3;

void setup()
{
  size(1800, 900);
  background(255);
  
  //Draw random nodes and fill nodelist
  while(nodeList.size() < nodes)
  { 
    int x = (int)random(1, 56);
    int y = (int)random(1, 28);
    
    boolean overlaps = false;
    
    
    for(int j = 0; j < nodeList.size(); j++)
    {
      int d = (int)dist(nodeList.get(j).x * scale, nodeList.get(j).y * scale, x * scale, y * scale);
      if(d < min) overlaps = true; 
    }
    if(!overlaps) addNode(0,x,y);
  }
  
  for(int i = 0; i < nodeList.size(); i++)
  {
    nodeList.get(i).val = i;
  }
  
  adjacencyMatrix = new int[nodeList.size()][nodeList.size()];
  
  //Add edges 
  for(int i = 0; i < nodeList.size(); i++)
  {
    ArrayList<Node> nearbyNodes = NearbyNodes(nodeList.get(i));
    for(int j = 0; j < nearbyNodes.size(); j++)
    {
      if(random(1) < k)
        addEdge(nodeList.get(i), nearbyNodes.get(j));
    }
  }
  
  initiate();
  
  println("Start node = " + start.val);
  println("End node = " + goal.val);
  
  path = Pathfind();
}

void draw()
{  
  //Drawing of graph and animation path 
  fill(0, 0, 255);
  ellipse(start.x * scale, start.y * scale, dia, dia);
  fill(255, 0, 0);
  ellipse(goal.x * scale, goal.y * scale, dia, dia);
  
  int pathSize = path.size() - 1;
  frameRate(frame);
  stroke(0, 255, 0);
  strokeWeight(6);
  if(i < pathSize)
    line(path.get(pathSize - i).x * scale, path.get(pathSize - i).y * scale, path.get(pathSize - i - 1).x * scale, path.get(pathSize - i - 1).y * scale);
  
  if(i < path.size())
    print(path.get(pathSize - i).val + ", ");
      
  i++;
  
  //Drawing the nodes which A* has visited
  for(Node n : closed)
  {
    stroke(255, 255, 0);
    noFill();
    strokeWeight(4);
    ellipse(n.x * scale, n.y * scale, dia, dia);
  } 
  
  for(Node n : nodeList)
  {
    textSize(dia/2);
    fill(255);
    text(n.val, n.x * scale - textWidth(str(n.val))/2, n.y * scale + dia/4);
  }
}

//Finding the two nodes which are farthest apart from each other and initiate them as start and end node
void initiate()
{
  int check = 0;
  for(int i = 0; i < nodeList.size(); i++)
  {
    for(int j = 0; j < nodeList.size(); j++)
    {
      int d = (int)dist(nodeList.get(i).x, nodeList.get(i).y, nodeList.get(j).x, nodeList.get(j).y);
      if(d > check)
      {
        check = d;
        goal = nodeList.get(i);
        start = nodeList.get(j);
      }
    }
  }
}

//Add node to nodelist and draw node
void addNode(int val, int x, int y)
{
  Node n = new Node(val, x, y);
  nodeList.add(n); 
  fill(0);
  ellipse(n.x * scale, n.y * scale, dia, dia);
}

//Add edge and draw edge
void addEdge(Node n1, Node n2)
{
  adjacencyMatrix[getIndex(n1)][getIndex(n2)] = 1;
  adjacencyMatrix[getIndex(n2)][getIndex(n1)] = 1;
  strokeWeight(2);
  line(n1.x * scale, n1.y * scale, n2.x * scale, n2.y * scale);
}

int getIndex(Node node)
{
  int index = 0;
  for(int i = 0; i < nodeList.size(); i++)
  {
    if(nodeList.get(i).val == node.val) index = i;
  }
  return index;
}

ArrayList<Node> NearbyNodes(Node n)
{
  ArrayList<Node> returnList = new ArrayList<Node>();
  
  for(int i = 0; i < nodeList.size(); i++)
  {
    if(dist(n.x, n.y, nodeList.get(i).x, nodeList.get(i).y) < max && nodeList.get(i) != n)
    {
      returnList.add(nodeList.get(i));
    }
  }
  return returnList;
}

ArrayList<Node> Neighbours(Node n)
{
  int index = getIndex(n);
  
  ArrayList<Node> neighbours = new ArrayList<Node>();
  
  for(int i = 0; i < adjacencyMatrix.length; i++)
  {
    if(adjacencyMatrix[index][i] == 1)
    {
      neighbours.add(nodeList.get(i));
    }
  }
  return neighbours;
}

boolean Contains(ArrayList<Node> list, Node node)
{
  for (Node n : list)
  {
    if (n.val == node.val)
    {
      return true;
    }
  }
  return false;
}

//Finding node with lowest F score
Node NextNode(ArrayList<Node> list)
{
  int check = 999;
  Node nextNode = new Node();
  for (Node n : list)
  {
    if (n.F() < check)
    {
      check = n.F();
      nextNode = n;
    }
  }
  return nextNode;
}

//Heuristic function based on distance
int Heuristic(Node a, Node b)
{
  float dx = a.x - b.x;
  float dy = a.y - b.y;
  
  //Euclidian:
  return (int)sqrt(pow(dx, 2) + pow(dy, 2));
}

//A*
ArrayList<Node> Pathfind()
{
  open.add(start);
  do
  {
    Node current = NextNode(open);
    open.remove(current);
    closed.add(current);
    
    if(Contains(closed, goal)) break;
    
    for(Node n : Neighbours(current))
    {
      if(Contains(closed, n)) continue;
      
      if(Contains(open, n))
      {
        if(current.g + 1 < n.g)
        {
          n.g = current.g + 1;
          n.parent = current;
        }
      } 
      else
      {
        n.parent = current;
        n.h = Heuristic(n, goal);
        n.g = n.parent.g + 1;
        open.add(n);
      }
    }
  }while(open.size() > 0);
  
  Node end = closed.get(closed.size() - 1);
  
  if(end != goal) println("no path");
  
  return BuildPath(end);
}

ArrayList<Node> BuildPath(Node n)
{
  path.add(n);

  if (n.parent != null)
  {
    BuildPath(n.parent);
  }
  return path;
}
