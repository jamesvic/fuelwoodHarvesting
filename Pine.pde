public class Pine extends Tree {

  //Pine
  float domHeightIN;
  float W_wpine;
  float W_bpine;
  float W_brpine;
  float W_fpine;   
  float w_totalPine;
  float a_pine  = 0.01753;
  float g1_pine = 1.82610;
  float g2_pine = 1.28397;
  float b_pine  = 0.02898;
  float g3_pine = 2.08978;
  float c_pine  = 0.00948;
  float g5_pine = 2.74930;
  float d_pine  = 0.04163;
  float g7_pine = 1.93601;

  //Tree Height
  float alpha = 1.0491;
  float beta = 0.2172;
  float delta = 0.2541;
  float Dq = 11.6;
  float lambda = 4.0543;
  float b0=1.0301;
  float b1=0.4664;
  float Asig = 0.0109;

  //Site Index
  float SI;
  float b1SI=-0.76119;
  float b2SI=0.01473;
  float b3SI=6.96878;
  float A = standAge; //age of the stand/plot at the start.

  //growDBH
  ///From Tech and Hilt 1991 Individual tree growth model for the northeast USA.///
  float b1PBAG = 0.0006634;
  float b2PBAG = 0.1083470;
  float DBH10= 16; //top 10 percent of fast growers.//need to sort the arraylist to pick up the top 10 in inches.
  float PotentialBasalAreaGrowth;
  //Modifier function BAG = POTBAG(exp(-b3(BAL)))
  float b3PBAG=0.016835;
  float BAL= 5;//cubic foot per acre converted to cubic meter per hectare //this could be obtained by the values of other trees surroinding the tree in question. A tree distance to its neighboors would be able to be calculated.
  float BAGinches;
  float DGROWinches;

  //Constructor for Pine Object
  Pine (TreeType _type) {
    treeType = _type;
    pos = new PVector(random(140, width-10), random(10, height-20));
    col=color(58, 164, 34);
    DBH = random(base1TreeModel.minDBHpine, base1TreeModel.maxDBHpine);
    domHeightIN =  random(20, 24.8);
    getTreeHeight(DBH);
    getharvestableBiomass(DBH, treeHeight);
  }

  //Height
  //@Override
  //void getTreeHeight(float DBH) {
  //  //from pine allometry
  //  float DBHinches = DBH*0.393701;
  //  float HdFeet = domHeightIN*3.28084;

  //  treeHeightFeet = 4.5 + (HdFeet - 4.5)*alpha*(float)Math.pow((Math.pow((DBHinches-0.5)/Dq, delta))/(beta + (Math.pow((DBHinches-0.5)/Dq, delta))), lambda);
  //  treeHeight = (treeHeightFeet/3.28084);
  //}
  @Override
    void getTreeHeight(float DBHIN) {
    treeHeight = 1.3 + (float)Math.exp(b0+Asig)*(float)(Math.pow(DBHIN, b1));
  }
  @Override
    void getCurrentTreeHeight() {
    //from tropical trees allometry
    currentTreeHeight = 1.3 + (float)Math.exp(b0+Asig)*(float)(Math.pow(DBH, b1));
    treeGrowth = currentTreeHeight - treeHeight;
    treeHeight = currentTreeHeight;
  }

  //DBH
  @Override
    public void growDBH() {
    // Site Index equation to reflect the conditions of growth in the local areas. From the Site index and height (Stiff, 1989)
    SI = (float)(1.3+treeHeight+b1SI*(Math.log(Math.pow(A, 2))-Math.log(Math.pow(15, 2))) + b2SI*(A*Math.log(A)-15*Math.log(15)) + b3SI*((treeHeight/A)-(treeHeight/15)));
    float DBHinches = DBH*0.393701; // conversion of 
    PotentialBasalAreaGrowth = b1PBAG*SI*(1-(float)Math.exp(-b2PBAG*(DBH10)));
    BAGinches = PotentialBasalAreaGrowth*(float)(Math.exp(-b3PBAG*(BAL)));
    //Diameter growth DGROW =[{0.00545415(DBH)^2 + BAG} / 0.00545415]^(0.5)-DBH
    DGROWinches = (float)Math.pow((float)(((0.00545415)*Math.pow(DBHinches, 2) + BAGinches)/0.00545415), 0.5)-(DBHinches);
    //Daily growth rate for DBH
    DBHGROW = (((DGROWinches/0.393701)/(52))/7); // *(86400)to convert back into centimeters * days, weeks, seconds.
    float currdiameter = DBH;
    if (growthStop == false ) {//&& DBH<=maxDBH) {
      DBH+= DBHGROW;
      //println(DBH);
      //      //age++;
    } else {
      DBH = currdiameter;
      //      //age++;
      growthStop = true;
    }
    getCurrentTreeHeight();
    getCurrentHarvestableBiomass();
  }

  //Biomass
  void getharvestableBiomass (float DBHIN, float treeHeightIN) {
    W_wpine = a_pine*(float)Math.pow(DBHIN, g1_pine)*(float)Math.pow(treeHeightIN, g2_pine);
    W_bpine =  b_pine*(float)Math.pow(DBHIN, g3_pine);
    W_brpine = c_pine*(float)Math.pow(DBHIN, g5_pine);
    W_fpine = d_pine*(float)Math.pow(DBHIN, g7_pine);   
    w_totalPine = W_wpine + W_bpine + W_brpine + W_fpine;    
    abgWoodyBiomass = w_totalPine;
  }
  @Override
    void getCurrentHarvestableBiomass() {
    float current_W_wpine = a_pine*(float)Math.pow(DBH, g1_pine)*(float)Math.pow(treeHeight, g2_pine);
    float current_W_bpine =  b_pine*(float)Math.pow(DBH, g3_pine);
    float current_W_brpine = c_pine*(float)Math.pow(DBH, g5_pine);
    float current_W_fpine = d_pine*(float)Math.pow(DBH, g7_pine);   

    if (this.W_brpine == 0) {
      current_W_brpine = 0;
    }
    if (this.W_wpine == 0) {
      current_W_wpine = 0;
    }

    float current_w_totalPine = current_W_wpine + current_W_bpine + current_W_brpine + current_W_fpine;    
    this.w_totalPine = current_w_totalPine;
    abgWoodyBiomass = this.w_totalPine;
  }

  //Harvesting
  @Override
    public boolean canBeHarvested(float minHarvest, float maxHarvest, boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {
    if (wbranchLow == true && this.W_brpine > minHarvest && this.W_brpine < maxHarvest) { 
      return true;
    } 
    if (wbranchLow == true && wbranchMid == true && wbranchHigh== true && this.W_wpine > minHarvest && this.W_wpine<maxHarvest) { //this.canBeRemoved() ==true 
      return true;
    } else {
      return false;
    }
  }

  @Override
    public float availableBiomass(boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {
    if (wbranchLow == true) {
      availableBiomass = this.W_brpine;
      this.W_brpine = 0;
    } 
    if (wbranchLow == true && wbranchMid == true && wbranchHigh==true) {
      availableBiomass = this.W_wpine;
      this.W_wpine = 0;
      this.col = color(255, 0, 0);
    }
    return availableBiomass;
  }

  @Override
    public boolean canBeRemoved() {
    if (W_brpine == 0);
    return true;
  }

  //Show Object on Screen
  @Override
    public void getcrownRadius() {
    float b0Crown = 1.0;
    float b1Crown = 0.03;
    //Crown radius un meters
    crownRadius = b0Crown + b1Crown*DBH;
  }
  @Override
    void show() {
    fill(col, 200);
    noStroke();
    ellipse(pos.x, pos.y, crownRadius*2*3, crownRadius*2*3); //the circles are that of the DBH representation.

    if (over) {
      fill(1);
      textAlign(LEFT);
      text(String.format("  agb: %.2f", abgWoodyBiomass), 5, 100+10);
      text(String.format("  crownRadius: %.2f", crownRadius), 5, 100+25);
      text(String.format("  pos: %.2f , %.2f", pos.x, pos.y), 5, 100+40);
      text(String.format("  pineBranch: %.2f", W_brpine), 5, 100+55);
      text(String.format("  wood: %.2f", W_wpine), 5, 100+70);
      text(String.format("  tree Height: %.2f", treeHeight), 5, 100+85);
    }
  }
}
