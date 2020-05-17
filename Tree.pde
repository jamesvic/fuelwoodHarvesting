abstract class Tree { 

  //Public Parameters
  PVector pos;
  TreeType treeType;
  float treeAge;
  float DBH;
  float crownRadius;
  float treeDensity;
  float DBHGROW;
  float siteAge;
  float treeHeight;
  float treeHeightFeet;
  float currentTreeHeight;
  float treeGrowth;
  float treeVolume;
  float abgWoodyBiomass;
  float harvestableBiomass;
  boolean shadeTolerant = false;
  boolean reached = false;
  boolean over = false;
  color col;

  //Growth control
  boolean growthStop = false;
  //Disease control
  boolean treeDiseased = false;

  //Reaching Tree Obect
  void reached() {
    reached = true;
  }
  //DBH
  public void growDBH() {
  }
  //Height
  public void getTreeHeight(float DBHIN) {
  }
  public void getCurrentTreeHeight() {
  }

  //Biomass
  public float availableBiomass(boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {
    return availableBiomass;
  }
  public void getCurrentHarvestableBiomass () {
  }

  //Harvesting
  public boolean canBeHarvested(float minHarvest, float maxHarvest, boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {
    return false;
  }
  public boolean canBeRemoved() {
    return false;
  }

  //Info
  public String getInfo() {
    return null;
  }
  public String getBiomassInfo() {
    return null;
  }

  //Show Object on Screen
  public void getcrownRadius() {
  }
  void show() {
    if (over) {
    }
  }
  //User Interface
  void rollover(float px, float py) {
    float d = dist(px, py, pos.x, pos.y);
    if (d < 10) {
      over = true;
    } else {
      over = false;
    }
  }
}
