class Box {
  String symbol;
  int left, bottom, right, top, page;
  int x, y, w, h;
  int hue;
  int psm; //the psm that was used for this item
  ArrayList<Box> twins = new ArrayList();
  float area,aspect;

  Box(String s, PImage img) {
    String[] items = s.split(" ");
    symbol = items[0];
    left = int(items[1]);
    bottom = img.height-int(items[2]);
    right = int(items[3]);
    top = img.height-int(items[4]);
    page = int(items[5]);
    x = left;
    y = top;
    w = right-left;
    h = bottom-top;
    area = w*h;
    aspect = float(w)/h;
    hue = (int)random(255);
  }
  
  float dist(Box b) {
    return PApplet.dist(lerp(left,right,.5),lerp(top,bottom,.5),
      lerp(b.left,b.right,.5),lerp(b.top,b.bottom,.5));
  }
  
  float dist(float x2, float y2) {
    return PApplet.dist(lerp(left,right,.5),lerp(top,bottom,.5),x2,y2);
  }
}
