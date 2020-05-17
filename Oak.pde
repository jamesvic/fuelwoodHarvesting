public class Oak extends Tree {

  //Oak
  float W_woak;
  float W_boak;
  float W_broak;
  float W_branchOakDB;
  float W_branchOak01;
  float W_branchOak14;
  float W_branchOak47;
  float W_branchOak714;
  float W_broakMain;
  float W_foak;   
  float w_totalOak;
  float a_oak  = 0.11618;
  float g1_oak = 1.77395;
  float g2_oak = 0.68708;
  float b_oak  = 0.00827;
  float g3_oak = 2.54489;
  float c_oak  = 0.05020;
  float g5_oak = 1.97638;
  float g6_oak = 0.34229;
  float d_oak  = 0.08234;
  float g7_oak = 1.59396;

  //from tropical trees allometry
  float alpha = 1.0491;
  float beta = 0.2172;
  float delta = 0.2541;
  float Dq = 11.6;
  float lambda = 4.0543;

  float b0=1.0301;
  float b1=0.4664;
  float Asig = 0.0109;

  float SI;
  float b1SI=-0.76119;
  float b2SI=0.01473;
  float b3SI=6.96878;
  float A = standAge; //age of the stand/plot at the start.

  //Potential Basal Area Growth POTBAG = b1*SI(1.0-exp(-b2DBH10)
  float b1PBAG = 0.0009567;
  float b2PBAG = 0.1038458;
  float DBH10= 16; //top 10 percent of fast growers.//need to sort the arraylist to pick up the top 10 in inches.
  float PotentialBasalAreaGrowth;
  float b3PBAG=0.020653;
  float BAL= 3;//cubic foot per acre converted to cubic meter per hectare //this could be obtained by the values of other trees surroinding the tree in question. A tree distance to its neighboors would be able to be calculated.
  float BAGinches;



  //Constructor
  Oak (TreeType _type) {
    treeType = _type;
    pos = new PVector(random(140, width-10), random(10, height-20));
    DBH = random(base1TreeModel.minDBHoak, base1TreeModel.maxDBHoak);
    col=color(20, 53, 26);
    getTreeHeight(DBH);
    getharvestableBiomass(DBH, treeHeight);
  }

  //Height
  @Override
    void getTreeHeight(float DBHIN) {
    treeHeight = 1.3 + (float)Math.exp(b0+Asig)*(float)(Math.pow(DBHIN, b1));
  }
  @Override
    void getCurrentTreeHeight() {
    currentTreeHeight = 1.3 + (float)Math.exp(b0+Asig)*(float)(Math.pow(DBH, b1));
    treeGrowth = currentTreeHeight - treeHeight;
    treeHeight = currentTreeHeight;
  }

  //DBH
  @Override
    public void growDBH() {

    // Site Index equation to reflect the conditions of growth in the local areas. From the Site index and height (Stiff, 1989)
    SI = (float)(1.3+treeHeight+b1SI*(Math.log(Math.pow(A, 2))-Math.log(Math.pow(15, 2))) + b2SI*(A*Math.log(A)-15*Math.log(15)) + b3SI*((treeHeight/A)-(treeHeight/15)));

    ///From Tech and Hilt 1991 Individual tree growth model for the northeast USA.///
    float DBHinches = DBH*0.393701; // conversion 
    PotentialBasalAreaGrowth = b1PBAG*SI*(1-(float)Math.exp(-b2PBAG*(DBH10)));
    BAGinches = PotentialBasalAreaGrowth*(float)(Math.exp(-b3PBAG*(BAL)));
    float DGROWinches = (float)Math.pow((float)(((0.00545415)*Math.pow(DBHinches, 2) + BAGinches)/0.00545415), 0.5)-(DBHinches);

    //Daily growth rate for DBH
    DBHGROW = (((DGROWinches/0.393701)/(52))/7); // *(86400)to convert back into centimeters * days, weeks, seconds.
    float currdiameter = DBH;
    if (growthStop == false ) {//&& DBH<=maxDBH) {
      DBH+= DBHGROW;
    } else {
      DBH = currdiameter;
      growthStop = true;
    }
    getCurrentTreeHeight();
    getCurrentHarvestableBiomass();
  }

  //Biomass
  void getharvestableBiomass(float DBHIN, float treeHeightIN) {
    //wood
    W_woak = a_oak*(float)Math.pow(DBHIN, g1_oak)*(float)Math.pow(treeHeightIN, g2_oak);
    W_boak =  b_oak*(float)Math.pow(DBHIN, g3_oak);
    //branches
    W_broakMain = c_oak*(float)Math.pow(DBHIN, g5_oak)*(float)Math.pow(treeHeightIN, g6_oak);
    W_branchOakDB = (W_broakMain)*((float)1/21);
    W_branchOak01 = (W_broakMain)*((float)2/21);
    W_branchOak14 = (W_broakMain)*((float)7/21);
    W_branchOak47 = (W_broakMain)*((float)9/21);
    W_branchOak714 = (W_broakMain)*((float)2/21);
    //foliage
    W_foak = d_oak*(float)Math.pow(DBHIN, g7_oak);  
    //totalbiomass
    w_totalOak = W_woak + W_boak + W_branchOakDB + W_branchOak01 + W_branchOak14 + W_branchOak47+ W_branchOak714 + W_foak;
    abgWoodyBiomass = w_totalOak;
  }

  @Override
    void getCurrentHarvestableBiomass() {
    //wood
    float current_W_woak = a_oak*(float)Math.pow(DBH, g1_oak)*(float)Math.pow(treeHeight, g2_oak);
    float current_W_boak =  b_oak*(float)Math.pow(DBH, g3_oak);
    //branches
    float current_W_broakMain = c_oak*(float)Math.pow(DBH, g5_oak)*(float)Math.pow(treeHeight, g6_oak);
    float current_W_branchOakDB = (current_W_broakMain)*((float)1/21);
    float current_W_branchOak01 = (current_W_broakMain)*((float)2/21);
    float current_W_branchOak14 = (current_W_broakMain)*((float)7/21);
    float current_W_branchOak47 = (current_W_broakMain)*((float)9/21);
    float current_W_branchOak714 = (current_W_broakMain)*((float)2/21);
    //foliage
    float current_W_foak = d_oak*(float)Math.pow(DBH, g7_oak);  

    if (this.W_branchOak14 == 0) {
      current_W_branchOak14 =0;
    } 
    if (this.W_branchOak47 ==0) {
      current_W_branchOak47 = 0;
    } 
    if (this.W_branchOak714 ==0) {
      current_W_branchOak714 = 0;
    }
    if (this.W_woak == 0) {
      current_W_woak = 0;
    }
    //totalbiomass
    float current_w_totalOak = current_W_woak + current_W_boak + current_W_branchOakDB + current_W_branchOak01 + current_W_branchOak14 + current_W_branchOak47+ current_W_branchOak714 + current_W_foak;
    this.w_totalOak = current_w_totalOak;
    abgWoodyBiomass = this.w_totalOak;
  }

  //Harvesting
  @Override
    public boolean canBeHarvested(float minHarvest, float maxHarvest, boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {

    if (wbranchLow == true && this.W_branchOak14 > minHarvest && this.W_branchOak14 < maxHarvest) { 
      return true;
    }
    if (wbranchMid == true && this.W_branchOak47 > minHarvest && this.W_branchOak47 < maxHarvest) {
      return true;
    }
    if (wbranchHigh== true && this.W_branchOak714 > minHarvest && this.W_branchOak714 < maxHarvest) {
      return true;
    }
    if (wbranchLow == true && wbranchMid == true && wbranchHigh== true && this.W_woak > minHarvest && this.W_woak<maxHarvest) { //this.canBeRemoved() ==true 
      return true;
    } else {
      return false;
    }
  }

  @Override
    public float availableBiomass(boolean wbranchLow, boolean wbranchMid, boolean wbranchHigh) {
    if (wbranchLow == true) {
      availableBiomass= this.W_branchOak14;
      this.W_branchOak14 = 0;
    } 
    if (wbranchMid == true) {
      availableBiomass = W_branchOak47;
      this.W_branchOak47 = 0;
    } 
    if (wbranchHigh == true) {
      availableBiomass = W_branchOak714;
      this.W_branchOak714 = 0;
    } 
    if (wbranchLow == true && wbranchMid == true && wbranchHigh==true) {
      availableBiomass = W_woak;
      this.W_woak = 0;
      //this.col = color(255, 0, 0);
    }
    return availableBiomass;
  }

  @Override
    public boolean canBeRemoved() {
    if (W_branchOak14 == 0 && W_branchOak47 == 0 && W_branchOak714 == 0) {
      return true;
    } else {
      return false;
    }
  }

  //Info
  @Override
    public String getInfo() {
    String info = String.format("  agb: %.2f", abgWoodyBiomass); 
    return info;
  }
  @Override
    public String getBiomassInfo() {
    String biomassinfo = String.format("  TreeInfo:  ", w_totalOak, W_woak, W_boak, W_branchOakDB, W_branchOak01, W_branchOak14, W_branchOak47, W_branchOak714, W_foak);
    return biomassinfo;
  }

  //Show Object on Screen
  @Override
    public void getcrownRadius() {
      //from: https://www.fws.gov/GISdownloads/R4/Louisiana%20ESO/Walther/WVA/Tree%20Growth%20Spreadsheets/oak%20crown%20dbh%20literature/CrownRadius_DBH_literature.pdf
    float b0Crown = 0.717;
    float b1Crown = 0.076;
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
      text(String.format("  wood: %.2f", W_woak), 5, 100+55);
      text(String.format("  bark: %.2f", W_boak), 5, 100+70);
      text(String.format("  deadBranches: %.2f", W_branchOakDB), 5, 100+85);
      text(String.format("  1-4Branches: %.2f", W_branchOak14), 5, 100+100);
      text(String.format("  4-7Branches: %.2f", W_branchOak47), 5, 100+115);
      text(String.format("  7-14Branches: %.2f", W_branchOak714), 5, 100+130);
      text(String.format("  foilage: %.2f", W_foak), 5, 100+145);
    }
  }
}
