class TreeFarm {
  
  //use getShape method to get object of type shape 
  public Tree createTree(TreeType type) {

    if (type == null) {
      return null;
    }
    if (type == TreeType.Pine) {
      return new Pine(type);
    }
    if (type == TreeType.Oak ) {
      return new Oak(type);
    }
   
    return null;
  }
}
