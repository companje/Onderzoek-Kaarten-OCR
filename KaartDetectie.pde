import gab.opencv.*;
import java.awt.Rectangle;
OpenCV opencv;
PImage img, bw, debugImg;
ArrayList<Area> areas = new ArrayList();
ArrayList<Line> vlines = new ArrayList();
ArrayList<Item> items = new ArrayList();
ArrayList<Box> boxes = new ArrayList();
Area selected = null;
boolean resizing, moving;
String model = "";
boolean exporting;
PrintWriter csvExport;
String folder = "/Users/rickcompanje/CBG/crop-breed-1000/";
//String folder = "z:\\CBG\\crop-breed-1000\\";
String ocrEngine = "tesseract"; // "easyocr"
String filenames[];
int frame = 0;
int saturation;
String geslacht = "";
int psm = 11; // 7; //11; //7;
int fontSize = 40;
int AREA_OCR=4;
int AREA_SNAME=5;
int AREA_FNAME=6;
int AREA_BDATE=7;
int AREA_BPLACE=8;
boolean drawItems, drawBoxes;
String fname, prefix="", sname, bdate, bplace;
int bday, bmonth, byear;

void setup() {
  size(2800, 1000);
  opencv = new OpenCV(this, width, 500);
  frameRate(60);
  surface.setLocation(0, 0);
  textSize(fontSize);
  filenames = loadStrings("filenames.txt");
  loadSettings();

  try {
    String lines[] = loadStrings("frame.txt");
    frame = int(lines[0]);
    if (frame>=filenames.length) frame=0;
  } 
  catch (Exception e) {
  }

  load(folder+filenames[frame]);
}

void draw() {
  //pre-draw
  if (exporting) {
    load(folder+filenames[frame]);
    //htmlExport.println("<h1>"+filenames[frame]+"</h1><table border=1><tr><th>model</th><th>geslacht</th><th>fname</th><th>sname</th><th>bdate</th><th>bplace</th><tr><td>"+model+"</td><td>"+geslacht+"</td><td>"+fname+"</td><td>"+sname+"</td><td>"+bdate+"</td><td>"+bplace+"</td></tr></table><img width=\"50%\" src=\"../debug/"+filenames[frame]+"\">");
    csvExport.println(filenames[frame] + "," + model + 
      "," + geslacht + "," + fname + "," + prefix + "," + sname + "," + 
      bdate + "," + byear + "," + bmonth + "," + bday + "," + bplace);
  }

  background(0);
  if (img!=null) image(img, 0, 0);
  if (bw!=null) image(bw, 0, 500);
  if (debugImg!=null) image(debugImg, 0, 0);

  for (Line line : vlines) {
    stroke(0, 255, 0);
    line(line.start.x, line.start.y, line.end.x, line.end.y);
  }

  for (Area area : areas) {
    //if (area.index<5) continue;

    strokeWeight(area==selected ? 3 : 1);
    stroke(255);
    colorMode(HSB);
    fill(float(area.index)/areas.size()*255, 255, 255, 100);
    area.drawRect();
    colorMode(RGB);
    fill(255);
    textSize(20);
    textAlign(CENTER);
    text(area.text, area.x+area.width/2, area.y+area.height/2+10);
    textAlign(RIGHT);
    text(area.index, area.x+area.width-5, area.y+20);
    textAlign(LEFT);
    if (area==selected) {
      fill(255);
      rect(area.x+area.width-8, area.y+area.height-8, 8, 8);
    }
    strokeWeight(1);

    ////// show red/green dots for area-line intersection 
    if (area.index<4) { //only first 4 are used for model detection
      noStroke();
      if (area.intersectsAnyLine(vlines)) {
        fill(0, 255, 0);
      } else {
        fill(255, 0, 0);
      }
      ellipse(area.x+area.width/2, area.y+area.height/2, 12, 12);
    }

    //show model
    fill(255, 255, 0);
    noStroke();
    textSize(20);
    textAlign(CENTER);
    text("frame="+frame+", model=" + model + ", geslacht=" + geslacht + ", fname="+fname+", prefix="+prefix+", sname="+sname+", bdate="+bdate+", byear="+byear+", bmonth="+bmonth+", bday="+bday+", bplace="+bplace, width/2, height-5);
    textAlign(LEFT);

    if (exporting) {
      fill(255, 0, 0, 50);
      rect(0, 0, width, 30);
      fill(255, 255, 0);
      noStroke();
      textSize(40);
      text(frame, 50, height-10);
    }
  }

  if (drawItems) {
    stroke(255);
    for (Item item : items) {
      //item.index/float(items.size())*255, 255, 255);
      noFill();
      rect(item.x, item.y, item.w, item.h);
      textAlign(CENTER);
      fill(255, 255, 0);
      text(item.text, item.x+item.w/2, item.y+10+item.h/2); //"\n(" + item.conf + ")"§
      textAlign(LEFT);
    }
  }

  if (drawBoxes) {
    colorMode(HSB);
    noFill();
    for (Box box : boxes) {
      stroke(box.hue, 255, 255);
      rect(box.x, box.y, box.w, box.h);
    }
    colorMode(RGB);
  }

  //blendMode(DIFFERENCE);
  //image(imgMarker3, mouseX, mouseY);
  //blendMode(BLEND);

  //post-draw
  if (exporting) {
    save("data/debug/"+filenames[frame]);

    frame++;
    if (frame>=filenames.length) {
      stopExport();
    }
  }
}

void gotoFrame(int fr) {
  frame = constrain(fr, 0, filenames.length-1);
  resetOCR();
  load(folder+filenames[frame]);
}

void load(String s) {
  println("load", s);
  img = loadImage(s);
  findLines(); 
  detectModel();
  detectGeslacht();
  ocr();
}

void resetOCR() {
  for (Area a : areas) a.text = "";
  items.clear();
  boxes.clear();
}

void detectModel() {
  if (areas.size()<4) return; //cannot detect

  if (!areas.get(3).intersectsAnyLine(vlines)) {
    model = "V";
  } else if (areas.get(0).intersectsAnyLine(vlines) &&
    areas.get(1).intersectsAnyLine(vlines)  &&
    areas.get(2).intersectsAnyLine(vlines)) {
    model = "B";
  } else {
    model = "A";
  }
}

void detectGeslacht() {
  PImage img2 = img.copy(); 
  img2.resize(1, 1);
  saturation = (int)saturation(img2.get(0, 0));
  geslacht = saturation>=75 ? "Man" : saturation<70 ? "Vrouw" : "?";
}

void findLines() {
  //opencv.loadImage(img);
  opencv = new OpenCV(this, img);
  opencv.blur(1);
  opencv.adaptiveThreshold(3, 4);
  //opencv.close(3);
  //debugImg = opencv.getSnapshot();
  opencv.findCannyEdges(20, 75); //(20, 75);
  vlines.clear();
  ArrayList<Line> lines = opencv.findLines(30, 50, 20); //threshold, minLengthLength, maxLineGap
  for (Line line : lines) {
    if (line.angle >= radians(-20) && line.angle < radians(20)) {
      vlines.add(line);
    }
  }
}

void detectMarker3() {
}

void startExport() {
  frame=0;
  exporting = true;
  csvExport = createWriter("data/out.csv");
  //htmlExport = createWriter("data/out.html");
}

void stopExport() {
  if (!exporting) return;
  exporting = false;
  //htmlExport.flush();
  //htmlExport.close();
  csvExport.flush();
  csvExport.close();
}

void ocrRandomOffset() {
  int maxRnd = 10; 
  Area area = new Area(areas.get(AREA_OCR));
  area.x += (int)random(-maxRnd, maxRnd);
  area.y += (int)random(-maxRnd, maxRnd);
  println(area);
  ocrArea(area);
}

void ocr() { //default
  ocrArea(areas.get(AREA_OCR));
}

void ocrArea(Area area) {
  println("ocr frame ", frame);
  resetOCR();
  //Area area = areas.get(AREA_OCR);
  println(area.x, area.y, area.width, area.height);
  
  PImage crop = img.get(area.x, area.y, area.width, area.height);
  crop.save("crop.png");
  String scriptPath = dataPath("script.sh").replace("data/", "");
  //String scriptPath = dataPath("script.bat").replace("data\\", "");
  Process p = exec(scriptPath, "crop.png", ocrEngine, psm+"");
  try {
    int result = p.waitFor();
    bw = loadImage("tmp/tmp_bw.png");

    Table table = loadTable("tmp/tmp.tsv", "header, tsv");
    for (TableRow row : table.rows()) {
      int conf = row.getInt("conf");
      if (conf==-1) continue;
      String id = row.getString("text");
      Item item = new Item(row);
      item.index = items.size();
      item.x += area.x; //offset
      item.y += area.y; //offset

      if (!isOnBlacklist(item)) {
        items.add(item);
      }
    }
    int i=0;
    for (String line : loadStrings("tmp/tmp.box")) {
      Box box = new Box(line, crop);
      box.hue = ((i++)*13)%255;
      box.x += area.x; //offset
      box.y += area.y; //offset
      box.psm = psm;
      boxes.add(box);
    }
  }
  catch (Exception e) {
    println("error in ocr()", e);
    background(255, 0, 0);
  }

  updateTextFromItems(areas.get(AREA_SNAME), "sname.tsv");
  updateTextFromItems(areas.get(AREA_FNAME), "fname.tsv");
  updateTextFromItems(areas.get(AREA_BDATE), "bdate.tsv");
  updateTextFromItems(areas.get(AREA_BPLACE), "bplace.tsv");

  sname = areas.get(AREA_SNAME).text;
  fname = areas.get(AREA_FNAME).text;
  bdate = areas.get(AREA_BDATE).text;
  bplace = areas.get(AREA_BPLACE).text;

  String maanden_afk[] = {"nua", "bru", "aar", "pri", "ei", "uni", "uli", "gus", "tem", "tob", "vem", "cem"}; // needle in chars

  String bdate2 = bdate.replaceAll(" ", ""); //remove all spaces

  bmonth = 0;
  for (int i=0; i<maanden_afk.length; i++) {
    if (bdate2.indexOf(maanden_afk[i])>-1) {
      bmonth = i+1;
      break;
    }
  }

  byear = 0;
  String[] m1 = match(bdate2, "\\d{4}");
  if (m1 != null) {
    byear = int(m1[0]);
  } 

  bday = 0;
  m1 = match(bdate2, "^\\d{1,2}");
  if (m1 != null) {
    bday = int(m1[0]);
  }

  //prefixes
  println(sname);
  prefix="";
  String lines[] = loadStrings("prefix.tsv");
  for (String line : lines) {
    String items[] = split(line, "\t");
    String regex = items[0]; //colomn 0 in the tsv file
    if (regex.isEmpty()) continue; //skip empty regex'es
    m1 = match(sname, regex);
    if (m1!=null) {
      prefix = m1[0];
      break; //stop matching. make sure order in tsv is from complex to simple (van der ..to.. van)
    }
    //String by = (items.length==2) ? items[1] : "";
    //a.text = a.text.replaceAll(regex, by);
  }
  //sname =
}

void applyRegexes(Area a, String filename) { //problem calling applyRegexes(String s because of loosing reference
  a.text = trim(a.text);
  String lines[] = loadStrings(filename);
  for (String line : lines) {
    String items[] = split(line, "\t");
    String regex = items[0];
    if (regex.isEmpty()) continue; //skip empty regex'es
    String by = (items.length==2) ? items[1] : "";
    a.text = a.text.replaceAll(regex, by);
    a.text = trim(a.text); //do this after every step
    //println(a.text);
  }
  //a.text = trim(a.text);
}

void applyRegexes(String s, String filename) {
  println("Wordt applyRegexes(String s, String filename)  wel gebruikt?");
  exit();
  //s = s.trim();
  //String lines[] = loadStrings(filename);
  //for (String line : lines) {
  //  String items[] = split(line, "\t");
  //  String regex = items[0];
  //  String by = (items.length==2) ? items[1] : "";
  //  s = s.replaceAll(regex, by);
  //  s = trim(s);
  //  println(s);
  //}
}

void updateTextFromItems(Area area, String filename) {
  area.text = "";

  /////ITEMS MOETEN NOG HORIZONTAAL GESORTEERD WORDEN
  for (Item item : items) {
    Rectangle t = new Rectangle(item.x, item.y, item.w, item.h);
    if (area.intersects(t)) {
      Rectangle i = area.intersection(t);
      float overlap = float(i.width*i.height)/(t.width*t.height);

      ///EN HIER OOK KIJKEN OF DE Y-COORD OVEREENKOMT MET DE ANDERE Y-COORDS
      if (overlap>.5) {
        //println(i, overlap, item.text);
        area.text += item.text + " ";
      }
    }
  }
  applyRegexes(area, filename);
}

boolean isOnBlacklist(Item item) {
  String s = item.text;
  if (item.h<10) return true; //to low

  String blacklist[] = { 
    "Gem"
  };

  for (String b : blacklist) {
    if (b.equals(s)) return true;
  }
  return false;
}

void saveCurrentFrameSettings() {
  PrintWriter out = createWriter("frame.txt");
  out.println(frame);
  out.flush();
  out.close();
}
