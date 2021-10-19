
void loadSettings() {
  areas.clear();
  Table table = loadTable("data/areas.csv", "header");
  for (TableRow row : table.rows()) {
    int x = row.getInt("x");
    int y = row.getInt("y");
    int w = row.getInt("w");
    int h = row.getInt("h");
    Area area = new Area(x, y, w, h);
    area.index = areas.size();
    areas.add(area);
  }
}

void saveSettings() {
  Table table = new Table();
  table.addColumn("x");
  table.addColumn("y");
  table.addColumn("w");
  table.addColumn("h");
  for (Area a : areas) {
    TableRow row = table.addRow();
    row.setInt("x", a.x);
    row.setInt("y", a.y);
    row.setInt("w", a.width);
    row.setInt("h", a.height);
  }
  saveTable(table, "data/areas.csv");
}
