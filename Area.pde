class Area extends Rectangle {
  int index;
  ArrayList<Item> items = new ArrayList();
  String text = "";

  Area(int x, int y, int w, int h) {
    super(x, y, w, h);
  }
  
  Area(Area a) {
    super(a.x, a.y, a.width, a.height);
  }

  void set(int x, int y) {
    this.x = x;
    this.y = y;
  }

  void moveBy(int x, int y) {
    this.x += x;
    this.y += y;
  }

  void resize(int w, int h) {
    this.width = w;
    this.height = h;
  }

  void set(int x, int y, int w, int h) {
    set(x, y);
    resize(w, h);
  }

  void drawRect() {
    rect(x, y, width, height);
  }

  boolean intersectsLine(Line l) {
    return intersectsLine(l.start.x, l.start.y, l.end.x, l.end.y);
  }

  boolean intersectsAnyLine(ArrayList<Line> lines) {
    for (Line l : lines) if (intersectsLine(l)) return true;
    return false;
  }
}
