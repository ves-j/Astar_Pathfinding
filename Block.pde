import java.util.ArrayList;
import java.util.Random;

int cols = 20;
int rows = 20;
int cellSize = 30;
int[][] grid = new int[cols][rows];

// start node and end node
int startCol = 0;
int startRow = 0;
int endCol = 17;
int endRow = 15;

class Node {
  int col;
  int row;
  float cost;
  Node parent;

  Node(int col, int row, float cost, Node parent) {
    this.col = col;
    this.row = row;
    this.cost = cost;
    this.parent = parent;
  }
}

ArrayList<Node> openList = new ArrayList<>();
ArrayList<Node> closedList = new ArrayList<>();
ArrayList<Node> path = new ArrayList<>();

// Manhattan
float heuristic(int col, int row) {
  return abs(col - endCol) + abs(row - endRow);
}

public void drawGrid() {
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      if (grid[j][i] == 1) {
        fill(255, 0, 0); // Red color for blocked cells
      } else {
        fill(255); // Default white color
      }
      rect(j * cellSize, i * cellSize, cellSize, cellSize);
    }
  }
}


void setup() {
  size(800, 800);
  background(255);

  for (int i = 0; i < 100; i++) {
    int randomCol = (int) Math.floor(Math.random() * cols);
    int randomRow = (int) Math.floor(Math.random() * rows);
    
    if (randomCol != endCol && randomRow != endRow){
      grid[randomCol][randomRow] = 1; // Mark cell as blocked
    }
  }
  
  drawGrid();

  // Init A*
  Node startNode = new Node(startCol, startRow, 0, null);
  openList.add(startNode);
}

void draw() {
  // A* logic
  if (openList.isEmpty()) {
    // No path
    return;
  }

  // Get the node with the lowest cost from openList
  Node currentNode = openList.get(0);
  int currentIndex = 0;
  for (int i = 1; i < openList.size(); i++) {
    if (openList.get(i).cost < currentNode.cost) {
      currentNode = openList.get(i);
      currentIndex = i;
    }
  }
  
  // Remove the current node from the open list and add it to the closed list
  openList.remove(currentIndex);
  closedList.add(currentNode);
  
  // Visualize the current nodes and ignore the blocks
  if(grid[currentNode.col][currentNode.row] != 1) {
    fill(150);
    rect(currentNode.col * cellSize, currentNode.row * cellSize, cellSize, cellSize);
  }

  // Check if the current node is the goal node
  if (currentNode.col == endCol && currentNode.row == endRow) {
    // Create the path by following the parent node
    Node pathNode = currentNode;
    while (pathNode != null) {
      path.add(0, pathNode);
      pathNode = pathNode.parent;
    }

    // Visualize the path
    for (Node node : path) {
      fill(0, 255, 0);
      rect(node.col * cellSize, node.row * cellSize, cellSize, cellSize);
    }

    // Visualize the start point
    fill(255, 255, 0);
    rect(startCol * cellSize, startRow * cellSize, cellSize, cellSize);

    // Visualize the end point
    fill(0, 0, 255);
    rect(endCol * cellSize, endRow * cellSize, cellSize, cellSize);

    // End the A* algorithm
    noLoop();
    return;
  }
  
  // Generate neighboring nodes
  ArrayList<Node> neighbors = new ArrayList<>();
  int[][] directions = {
    { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 }, // UP, DOWN, LEFT, RIGHT
    { -1, -1 }, { 1, -1 }, { -1, 1 }, { 1, 1 } // DIAGONAL
  };

  for (int[] dir : directions) {
    int neighborCol = currentNode.col + dir[0];
    int neighborRow = currentNode.row + dir[1];

    // Check if the neighboring node is within the grid bounds
    if (neighborCol >= 0 && neighborCol < cols && neighborRow >= 0 && neighborRow < rows) {
      // Check if the neighboring node is not in closed list and not blocked
      boolean isClosed = false;
      for (Node closedNode : closedList) {
        if (closedNode.col == neighborCol && closedNode.row == neighborRow) {
          isClosed = true;
          break;
        }
      }

      if (!isClosed && grid[neighborCol][neighborRow] == 0) {
        float cost = currentNode.cost + 1;

        // Create neighboring node and calculate its cost
        Node neighborNode = new Node(neighborCol, neighborRow, cost, currentNode);
        neighborNode.cost += heuristic(neighborCol, neighborRow);

        neighbors.add(neighborNode);
      }
    }
  }

  // Update the neighboring nodes
  for (Node neighbor : neighbors) {
    // Check if the neighboring node is already in the open list
    boolean isOpen = false;
    int openIndex = -1;
    for (int i = 0; i < openList.size(); i++) {
      if (openList.get(i).col == neighbor.col && openList.get(i).row == neighbor.row) {
        isOpen = true;
        openIndex = i;
        break;
      }
    }

    if (isOpen) {
      // Update the cost and parent if the new path is shorter
      if (neighbor.cost < openList.get(openIndex).cost) {
        openList.get(openIndex).cost = neighbor.cost;
        openList.get(openIndex).parent = currentNode;
      }
    } else {
      // Add the neighboring node to the open list
      openList.add(neighbor);
    }
  }
}
