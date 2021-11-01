class Item {
  int x, y, top, left, right, bottom, w, h, conf;
  String text;
  int index;
  int psm; //the psm that was used for this item

  Item(TableRow row) {
    this.x = row.getInt("left");
    this.y = row.getInt("top");
    this.w = row.getInt("width");
    this.h = row.getInt("height");
    this.text = row.getString("text");
    this.conf = row.getInt("conf");
    this.left = x;
    this.top = y;
    this.right = x+w;
    this.bottom = y+h;
  }
  
  float dist(Item b) {
    return PApplet.dist(lerp(left,right,.5),lerp(top,bottom,.5),
      lerp(b.left,b.right,.5),lerp(b.top,b.bottom,.5));
  }
  
  float dist(float x2, float y2) {
    return PApplet.dist(lerp(left,right,.5),lerp(top,bottom,.5),x2,y2);
  }
  
  boolean contains(int x, int y) {
    return x>=left && x<=right && y>=top && y<=bottom;
  }
}
