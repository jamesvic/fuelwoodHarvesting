// Modified by Jaime V. Chavez
Table table1 = new Table();
Table table2 = new Table();
// Flowfield object
FlowField flowfield;
// Using this variable to decide whether to draw all the stuff
boolean debug = false;
boolean pureGrowth = false;
boolean flowfieldON = true;

//Second Window
PWindow win;

ArrayList<Tree> tree1 = new ArrayList<Tree>();
ArrayList<Branch> branches = new ArrayList<Branch>();
ArrayList<Float> optpaths = new ArrayList<Float>(); 
ArrayList<Float> efficiency = new ArrayList<Float>();
GPointsArray points = new GPointsArray();

//Input File
float initialPopulation = 1000;
static float minDBHoak = 15;
static float maxDBHoak = 90;
float percentagePine = 0.5;
float maxRange = 2000;
float treeSeed = 1100;
static float minDBHpine = 5;
static float maxDBHpine = 40;
float gradient = 0.55;
int fieldResolution = 30;
float seedNoise = 100;
float minHarvestBiomass = 22;
float maxHarvestBiomass; //maximum allowable DBH to be harvested.
float loadWeight = 55;
float attractor = 0;

//Outoputfile
int timer=0;
float AGBStandTotal;
float AGBTotal;
float biomassHarvested;
float biomassStock;
float netBiomassProduction;
float traceLength;
float harvestingEfficiency;
float harvestingEffortLoads;
int harvestingEvent = 0;
int growthEvent =0;
int harvestType = 0;

//Working values
float availableBiomass;

//Manual settings
float len = 3;
float minDist = 3;
float maxDist = 1100;
float maxCapacity = 100;
float standAge =15;
float maxBranches = 90000;
float dailyFuelwoodConsumption = 17;//in kilograms
float maxRange2;
float maxRange3;

//Initital conditions of Tree patch
PVector posIN;
color colSort;
Boolean pineSpecies = false;
Boolean oakSpecies = false;
float species;
float treeHeightInitial;

//Harvest
boolean type1Harvest = false;
boolean type2Harvest = false;
boolean type3Harvest = false;
boolean type4Harvest =false;
float currentharvestingEfficiency;
float newharvestingEfficiency;
float newAmountToHarvest;
float workingBiomass;
float surplus;

float currentbiomassOptimization;
float biomassOptimization;
float newbiomassOptimzation;

boolean wbranchLow = false;
boolean wbranchMid= false;
boolean wbranchHigh = false;

//Consumed Trees
PVector recordPos = new PVector();
int pineCount;
int oakCount;
PVector treePosition;

//Disease Probability
float diseaseProb = 0.8;//1/86400

//Timer
int fps = 60;

//direction of flow
int rowi = 0;

public void settings() {
  size(1000, 1000);
}

void setup() {

  win = new PWindow();

  //FlowField to show topography influences
  smooth();
  flowfield = new FlowField(fieldResolution);

  //Initializing Forest
  growNewTrees();


  Branch root = new Branch(new PVector(0, height/2), new PVector(0, 1));
  branches.add(root);
  Branch current = new Branch(root);
  while (!closeEnough(current)) {
    Branch trunk = new Branch(current);
    branches.add(trunk);
    current = trunk;
  }
}

boolean closeEnough(Branch b) {
  for (Tree btree1 : tree1) {
    float d = PVector.dist(b.pos, btree1.pos);
    if (d < maxDist) {
      return true;
    }
  }
  return false;
}

void draw() {
  background(255);
  //Show trees
  for (int i = 0; i< tree1.size(); i++) {
    Tree treeType1 = tree1.get(i);
    treeType1.show();
    treeType1.getcrownRadius();
  }

  // Display the flowfield in "debug" mode
  if (debug) flowfield.display();

  //Executing the functions of the path and its dependencies.
  harvestRoutine();

  // continue to grow without harvest
  if (pureGrowth) harvestTree(0.0) ;


  //Show path
  for (Branch b : branches) {
    if (b.parent != null) {
      stroke(1);//177
      smooth();
      line(b.pos.x, b.pos.y, b.parent.pos.x, b.parent.pos.y);
    }
  }
  //Show the a specific value when hovering over the tree object
  for (int k = 0; k < tree1.size(); k++) {
    Tree kpath1 = tree1.get(k);
    kpath1.rollover(mouseX, mouseY);
  }

  //Show instructions on screen
  textAlign(LEFT);
  fill(0);
  text("Frames: " + (timer) + "   Path Extent (mt.):  " + branches.size() + "    Harvesting Event:  " + harvestingEvent +  "  HarvestType:" + harvestType +  "  maxHarvestBiomass:" + maxHarvestBiomass, 10, height-10);
  stroke(1);

  drawGrid();
}

void drawGrid() {
  float x= 90;
  while (x<width) {
    line(x, 0, x, height-10);
    x= x +90;
  }

  float y= 90;
  while (y<height) {
    line(0, y, width-10, y);
    y= y +90;
  }
}

void keyPressed() {
  if (keyPressed) {
    if (key == 'p' || key == 'P') { //to pause the simulation
      type1Harvest = false;
      type2Harvest = false;
      type3Harvest = false;
      type4Harvest = false;
    }
  }
  if (key == 'f') {
    debug = !debug;
  }
  if (keyPressed) {
    if (key == 'r') {
      for (int i = 0; i < tree1.size(); i++) {
        Tree tpath1 = tree1.get(i); 
        if (tpath1.col == color(255, 0, 0)) {
          tree1.remove(tpath1);
        }
      }
    }
  }
  if (keyPressed) {
    if (key == '1') {
      type1Harvest = true;
      type2Harvest = false;
      type3Harvest = false;
      type4Harvest = false;
    }
  }
  if (keyPressed) {
    if (key == '2') {
      type1Harvest = false;
      type2Harvest = true;
      type3Harvest = false;
      type4Harvest = false;
    }
  }
  if (keyPressed) {
    if (key == '3') {
      type1Harvest = false;
      type2Harvest = false;
      type3Harvest = true;
      type4Harvest = false;
    }
  }
  if (keyPressed) {
    if (key == '4') {
      type1Harvest = false;
      type2Harvest = false;
      type3Harvest = false;
      type4Harvest = true;
    }
  }
  if (keyPressed) {
    if (key == '+') {
      //maxHarvestBiomass += minHarvestBiomass;
      loop();
    }
  }
  if (keyPressed) {
    if (key == '-') {
      maxHarvestBiomass -= minHarvestBiomass;
    }
  }
  if (keyPressed) {
    if (key == 'c') {
      //loop();
      removeBranches();
    }
  }
  if (keyPressed) {
    if (key == 'g') {
      pureGrowth = !pureGrowth;
    }
  }
  if (keyPressed) {
    if (key == 'n') {
      harvestTree(0.0);
    }
  }
}

void growNewTrees() {
  randomSeed((int)treeSeed);
  for (int p = 0; p <= initialPopulation; p++) { //number of trees
    float speciesType = random(0, 1);
    TreeFarm farmTree = new TreeFarm();
    if (speciesType<percentagePine) {
      Tree pine1  = farmTree.createTree(TreeType.Pine);
      tree1.add(pine1);
    } else {
      Tree oak1  = farmTree.createTree(TreeType.Oak);
      tree1.add(oak1);
    }
  }
}

void growYoungTrees() {
  float speciesType = random(0, 1);
  TreeFarm farmTree = new TreeFarm();
  if (speciesType<percentagePine) {
    minDBHpine = 0;
    maxDBHpine = 1;
    Tree pine1  = farmTree.createTree(TreeType.Pine);
    tree1.add(pine1);
  } else {
    minDBHoak = 0;
    maxDBHoak = 0.5;
    Tree oak1  = farmTree.createTree(TreeType.Oak);
    tree1.add(oak1);
  }
}



void harvestRoutine() {
  for (int i = 0; i < tree1.size(); i++) {
    Tree tpath1 = tree1.get(i); 
    wbranchLow = false;
    wbranchMid= false;
    wbranchHigh = false;

    if (type1Harvest == true) {
      harvestType = 1;
      maxHarvestBiomass = minHarvestBiomass*1.5;
      wbranchLow = true;
      if ((tpath1.treeType == TreeType.Pine && tpath1.canBeHarvested((minHarvestBiomass*0.75), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh) || tpath1.treeType == TreeType.Oak) && tpath1.canBeHarvested((minHarvestBiomass*0.75), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh)) {    
        findTree(tpath1, wbranchLow, wbranchMid, wbranchHigh);
      }
    }
    if (type2Harvest == true) {
      harvestType = 2;
      maxHarvestBiomass = minHarvestBiomass*2;
      wbranchMid = true;
      if (tpath1.treeType == TreeType.Oak && tpath1.canBeHarvested((minHarvestBiomass*0.75), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh)) {
        findTree(tpath1, wbranchLow, wbranchMid, wbranchHigh);
      }
    }
    if (type3Harvest == true) {
      harvestType = 3;
      maxHarvestBiomass = minHarvestBiomass*3;
      wbranchHigh = true;
      if ( tpath1.treeType == TreeType.Oak && tpath1.canBeHarvested((minHarvestBiomass*0.75), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh)) {
        findTree(tpath1, wbranchLow, wbranchMid, wbranchHigh);
      }
    } 
    if (type4Harvest == true) {
      harvestType = 4;
      maxHarvestBiomass = minHarvestBiomass*4;
      wbranchLow = true;
      wbranchMid = true;
      wbranchHigh = true;
      if (tpath1.treeType == TreeType.Pine && tpath1.canBeHarvested((minHarvestBiomass*0.36), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh)||tpath1.treeType == TreeType.Oak && tpath1.canBeHarvested((minHarvestBiomass*0.36), maxHarvestBiomass, wbranchLow, wbranchMid, wbranchHigh)) {
        findTree(tpath1, wbranchLow, wbranchMid, wbranchHigh);
      }
    }
    growBranches();
  }
}
void findTree(Tree tpath1, Boolean wbranchLowIN, Boolean wbranchMidIN, Boolean wbranchHighIN) {
  Branch closest = null;
  PVector closestDir = null;
  float record = -1;
  for (int i = 0; i< branches.size(); i++) {  //for (Branch b : branches) {
    Branch b = branches.get(i);
    // if (b.pos.y > (l.pos.y) ) {//&& l.pos.x < b.pos.x//conditioning the branch position below a threshold.
    PVector dir = PVector.sub(tpath1.pos, b.pos);
    float d = dir.mag();
    if (d <= minDist ) {
      tpath1.reached();
      //noLoop();
      growYoungTrees();
      if (tpath1.treeType == TreeType.Pine) {
        availableBiomass = tpath1.availableBiomass(wbranchLowIN, wbranchMidIN, wbranchHighIN);
      } 
      if (tpath1.treeType == TreeType.Oak) {
        availableBiomass = tpath1.availableBiomass(wbranchLowIN, wbranchMidIN, wbranchHighIN);
      }
      tracePath(branches.indexOf(b));
      harvestTree(availableBiomass);
      //removeBranches();

      closest = null;
      break;
    } else if (d > maxDist) {
    } else if (closest == null || d < record) { //if its not too far away and there is no closest branch yet, it is the closest branch
      closest = b;
      closestDir = dir;
      record = d; //record means the closest one or record to beat.
    }//end of distance to harvest if statements
  }//end of branches for loop
  if (closest != null) { //did you actually find the closest branch
    closestDir.normalize();
    closest.dir.add(closestDir);
    closest.count++;// a value of how many times the branch has been called on by the leaf.
  }
  wbranchLow = false;
  wbranchMid= false;
  wbranchHigh = false;
}//end of findTree 

void growBranches() {
  for (int k = branches.size()-1; k >= 0; k--) {
    Branch b = branches.get(k);
    if (b.count > 0) {//set the pulls on the branches called from the trees.
      b.dir.div(b.count);
      //PVector rand= PVector.random2D(); //add the random forces on the direction
      PVector terrain = flowfield.lookup(b.pos);
      //rand.setMag(0.03);    //add the random forces on the direction
      terrain.setMag(gradient);
      b.dir.add(terrain);     //add the random forces on the direction
      b.dir.normalize();
      if (branches.size()<maxBranches) {//set up the maximum length of the branches.
        Branch newB = new Branch(b);
        branches.add(newB);
      }
      //println(b.count);
      //Increase the timer by 1.
      timer++;
      b.reset();
    }
  }
}

void removeBranches() {
  for (int q = branches.size()-1; q>0; q--) {//added the amount of path not deleted
    branches.remove(q);// added
  }
}

float calcTotalStandBiomass() {
  AGBStandTotal = 0;
  for (int i = 0; i< tree1.size()-1; i++) {
    Tree AGBtotal = tree1.get(i);
    AGBStandTotal += AGBtotal.abgWoodyBiomass;
  }
  return AGBStandTotal;
}

void harvestTree(float availableBiomassIN) {
  workingBiomass = 0;
  surplus = 0;

  //Sum all the available biomass for comparison
  AGBTotal = calcTotalStandBiomass();
  netBiomassProduction = (AGBTotal- availableBiomassIN);

  //Harvesting Events
  harvestingEvent++;

  if (harvestingEvent % 365 == 0) {
    println(harvestingEvent/365);
  }

  //Household Consumption computation
  workingBiomass =(availableBiomassIN - minHarvestBiomass);
  if (workingBiomass>0) {
    newAmountToHarvest = 0;
    surplus = workingBiomass;
  } else {
    newAmountToHarvest = newAmountToHarvest + abs(workingBiomass);
  }

  //Add points to the plot
  updatePoints(harvestingEvent, netBiomassProduction);

  println(harvestingEvent, availableBiomassIN, newAmountToHarvest, surplus, harvestType, traceLength);
  updateTrees();
  ////Conditions to change HarvestType based on surplus
  pauseSimulation();
  //Check surplus and adjust harvestType
  //The conditions of the surplus depend on the type of forest found given the sizes and weights of the tree branches
  //noLoop();
}


void updateTrees() {
  //Grow trees given time
  for (int j = 0; j< tree1.size(); j++) {
    Tree treeGrow = tree1.get(j);
    treeGrow.growDBH(); //updates the diameter
  }
}

void tracePath(int branchIndexIN) {
  fill(255, 0, 0);
  traceLength =0;
  ellipse(branches.get(branchIndexIN).pos.x, branches.get(branchIndexIN).pos.y, 5, 5);
  int childIndex = branchIndexIN;
  //point of parent position to last bra10ch10  fill(255, 0, 0);
  ellipse(branches.get(childIndex).parent.pos.x, branches.get(childIndex).parent.pos.y, 5, 5);
  int parentIndex = branches.indexOf(branches.get(childIndex).parent);
  boolean found = false;  
  while (found == false) {
    fill(255, 0, 0);
    if (parentIndex == 0) {

      break;
    }
    ellipse(branches.get(parentIndex).parent.pos.x, branches.get(parentIndex).parent.pos.y, 5, 5);
    parentIndex = branches.indexOf(branches.get(parentIndex).parent);
    traceLength++;
    if (parentIndex == 0 || childIndex == -1) {
      break;
    }
  }//end of while loop
}

void filltable(int harvestingEventIN, float biomassStockIN, float biomassHarvestedIN, int pineCountIN, int oakCountIN, float netBiomassProductionIN, float traceLengthIN, float harvestingEfficiencyIN, float harvestingEffortLoadsIN, int harvestTypeIN, int simNumIN) { 
  table2 = loadTable("data2.csv", "header");
  //// Create a new row
  TableRow row = table2.addRow();
  // Set the values of that row
  row.setInt("timeHarvest", harvestingEventIN);
  row.setFloat("biomassStock", biomassStockIN);
  row.setFloat("biomassHarvestedIn", biomassHarvestedIN);
  row.setInt("pineCount", pineCountIN);
  row.setInt("oakCount", oakCountIN);
  row.setFloat("netBiomassProduction", netBiomassProductionIN);
  //row.setFloat("candidateRouteSize", branchesSizeIN);
  row.setFloat("directRoute", traceLengthIN);
  row.setFloat("harvestingEfficiency", harvestingEfficiencyIN);
  row.setFloat("harvestingEffortLoads", harvestingEffortLoadsIN);
  row.setInt("simNum", simNumIN);
  row.setInt("harvestType", harvestTypeIN);  

  saveTable(table2, "data2.csv");
}
void updatePoints(int harvestingEventIN, float netBiomassProductionIN) {
  int x = harvestingEventIN;
  int y = int(netBiomassProductionIN);
  points.add(x, y);
}

void pauseSimulation() {
  type1Harvest = false;
  type2Harvest = false;
  type3Harvest = false;
  type4Harvest = false;
}
