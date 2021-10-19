void keyPressed() {
  if (key=='a') load("a.jpg");
  if (key=='B') load("b.jpg");
  if (key=='b') drawBoxes=!drawBoxes;
  if (key=='i') drawItems=!drawItems;
  if (key=='v') load("v.jpg"); //-eigenlijk-a.jpg");
  if (key=='c') areas.clear();
  if (key==8) if (areas.size()>0) areas.remove(areas.size()-1);
  if (key=='l') loadSettings();
  if (key=='s') saveSettings();
  if (key=='e') startExport();
  if (key=='r') ocr();
  if (key=='o') ocr();

  if (key==27) {
    stopExport();
    PrintWriter out = createWriter("frame.txt");
    out.println(frame);
    out.flush();
    out.close();
  }

  if (keyCode==RIGHT) { gotoFrame(frame+1); }
  if (keyCode==LEFT) { gotoFrame(frame-1); }
  if (keyCode==36) { gotoFrame(0); }
  if (keyCode==35) { gotoFrame(filenames.length-1); }
  if (key==']') { gotoFrame(frame+10); }
  if (key=='[') { gotoFrame(frame-10); }  
  
  println(keyCode);
  //if (key=='o') ocr.run(); ///ocr(folder+filenames[frame]);
}

void mouseMoved() {
  selected = null;
  for (Area a : areas) {
    if (a.contains(mouseX, mouseY)) {
      selected = a;
    }
  }
}

void mousePressed() {
  if (selected==null) {
    resizing = true;
    selected = new Area(mouseX, mouseY, 0, 0);
    areas.add(selected);
  } else {
    if (dist(mouseX, mouseY, selected.x+selected.width, selected.y+selected.height) < 25) {
      resizing = true;
    } else {
      moving = true;
    }
  }
}

void mouseDragged() {
  if (moving) selected.moveBy(mouseX-pmouseX, mouseY-pmouseY); //move
  else if (resizing) selected.resize(mouseX-selected.x, mouseY-selected.y);
}

void mouseReleased() {
  if (selected!=null && resizing) {
    if (selected.width<10) areas.remove(areas.size()-1);
  }
  resizing = false;
  moving = false;
  selected = null;
}
