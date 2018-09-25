// @author Melissa Ewing
// Recursively generates crumpled grid with random variation depending on mouse position.

import processing.pdf.*;

int maxlevel = 7;
int  w = 800, h = 800;
int borderRatio = 8;  // grid is surrounded by a border that is a fraction of the width/height
float startrng = 0; // higher range = greater randomness in placing points (the more "crumpled" the grid looks)
float lastrng = -1;
int numVertices;

Vertex[][] grid;

void setup() {
  size(w,h);
  background(255);
  strokeWeight(.8);
  
  // Calculate total number of vertices in the grid ahead of time
  numVertices = 2;
  for (int i = 1; i <= maxlevel; i++) {
    numVertices += pow(2,i-1);
  }
}

void draw() {
  if (lastrng != startrng) {
    background(255);
    grid =  makeGrid();
    drawGrid();
    lastrng = startrng;
  }
}

void mouseMoved() {
   startrng = map(mouseX, 0, width, 0, 230);
}

// Draws the lines (left to right and top to bottom) 
// between vertices of the grid
void drawGrid() {
  
  for (int i = 0; i < numVertices; i++) {
    for (int j = 0; j < numVertices; j++) {
      Vertex v = grid[i][j];
      if (i<numVertices-1) {
        Vertex vright = grid[i+1][j];
        line(v.x,v.y,vright.x,vright.y);
      }
      if (j<numVertices-1) {
        Vertex vdown = grid[i][j+1];
        line(v.x,v.y,vdown.x,vdown.y);
      }
    }
  }
}

// Generates initial fractal grid starting with four corner vertices.
// Stores points in vertex array called grid 
// Calls recursive function to do the rest of the work
Vertex[][] makeGrid() {
  
  // first four vertices determine the outline of the grid
  // start in four corners offset by border that is a fraction of the width/height
  Vertex v1 = new Vertex(w/borderRatio,h/borderRatio,0,0);
  Vertex v2 = new Vertex(w-w/borderRatio,h/borderRatio,numVertices-1,0);
  Vertex v3 = new Vertex(w-w/borderRatio,h-h/borderRatio,numVertices-1,numVertices-1);
  Vertex v4 = new Vertex(w/borderRatio,h-h/borderRatio,0,numVertices-1);
  
  Vertex[][] grid = new Vertex[numVertices][numVertices];
  grid[0][0] = v1;
  grid[numVertices-1][0] = v2;
  grid[numVertices-1][numVertices-1] = v3;
  grid[0][numVertices-1] = v4;
  
  return makeVertices(v1,v2,v3,v4,grid,0,startrng);
}

// Determine the position and index in the Vertex[][] of the next vertex 
// Derived vertex's x and y position will be at the midpoint of 
// two given vertices (plus a small randomized vertical/horizontal offset rng).
// Derived vertex's index in the array will also be midway between the 
// two given vertices' xi and yi indices
Vertex makeVertex(Vertex p1, Vertex p2, float rng) {
  Vertex v = new Vertex((p2.x+p1.x)/2+random(-rng, rng),
                        (p2.y+p1.y)/2+random(-rng, rng),
                        (p2.xi+p1.xi)/2,
                        (p2.yi+p1.yi)/2);
  return v;
}

// Recursively find the next level of vertices given 4 border vertices. 
// Subdivides grid to create more vertices at regular intervals with randomized x, y offset in rng
// Stores derived vertices in storage grid to use in draw method.
Vertex[][] makeVertices(Vertex p1, Vertex p2, Vertex p3, Vertex p4, Vertex[][] grid, int level, float rng) {
   
  if (level < maxlevel) {
     level++;
     rng /= 2;
     
     Vertex v1 = makeVertex(p2, p1, rng);
     Vertex v2 = makeVertex(p2, p3, rng);
     Vertex v3 = makeVertex(p3, p4, rng);
     Vertex v4 = makeVertex(p1, p4, rng);
     
     // last vertex is midway between all four points
     Vertex v5 = new Vertex((p1.x+p2.x+p3.x+p4.x)/4+random(-rng, rng),
                            (p1.y+p2.y+p3.y+p4.y)/4+random(-rng, rng),
                            (p1.xi+p2.xi)/2,
                            (p2.yi+p3.yi)/2);
     
     grid[v1.xi][v1.yi] = v1;
     grid[v2.xi][v2.yi] = v2;
     grid[v3.xi][v3.yi] = v3;
     grid[v4.xi][v4.yi] = v4;
     grid[v5.xi][v5.yi] = v5;
     
     grid = makeVertices(p1,v1,v5,v4,grid,level,rng);
     grid = makeVertices(v1,p2,v2,v5,grid,level,rng);
     grid = makeVertices(v5,v2,p3,v3,grid,level,rng);
     grid = makeVertices(v4,v5,v3,p4,grid,level,rng);
   }
   
   return grid;
}

// Optional save as pdf when r key is pressed
void keyPressed() {
  int keyIndex = -1;
  if (key == 'r'|| key == 'R') {
    beginRecord(PDF, "grid.pdf"); 
    endRecord();
  }
}

// Vertex class keeps track of a vertex's location on the screen 
// as well as index in the Vertex[][] grid.
class Vertex {
  //vertex has location and index
  float x,y;
  //x and y index
  int xi,yi;
  
  Vertex(float tempX, float tempY, int tempxindex, int tempyindex) {
    x = tempX;
    y = tempY;
    xi = tempxindex;
    yi = tempyindex;
  }
}
