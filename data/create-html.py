#!/usr/bin/env python3
import json,csv,sys,glob
from sys import argv

if len(argv)<2:
  print("Usage: ./create-html.py INPUT.csv")
  sys.exit()
fieldnames=["filename","model","gender","fname","prefix","sname","bdate","byear","bmonth","bday","bplace"]
with open(argv[1]) as f:
  reader = csv.DictReader(f, fieldnames=fieldnames)

  print('<html>')
  print('<head>')
  print('<link rel="stylesheet" href="//cdn.datatables.net/1.11.3/css/jquery.dataTables.min.css" />')
  print('<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>')
  print('<link href="css/jquery.fancybox.min.css" rel="stylesheet">')
  print('<script src="//cdn.datatables.net/1.11.3/js/jquery.dataTables.min.js"></script>')
  print('<style>td.col0 { width:250px; } td.col4 { width:80px; } a:link { color:black; } body,td,th,a { font-family: sans-serif; }</style>')
  print('</head>')
  print("<body><table class='compact hover stripe' border=1><thead><tr><th>" + ("</th><th>".join(fieldnames)) + "</th>")
  # print("<th>img</th>")
  print("</tr></thead><tbody>")

  for row in reader:
    print("<tr>")
    i=0
    for colValue in row.values():
      if colValue==None:
        colValue=""

      if i==0:
        colValue = '<a data-fancybox="gallery" href="debug/' + colValue + '">'+colValue+'</a>'

      print("<td class='col"+str(i)+"'>" + colValue + "</td>")
      i=i+1

    # print("<td><img width=800 src='../debug/"+row["filename"]+"'></td>")
    print("</tr>");

  print("</tbody></table></body>")

  print("<script>$(document).ready( function () {  $('table').DataTable({pageLength:50}); } );</script>")

  # print('<script src="js/jquery-3.3.1.min.js"></script>')
  print('<script src="js/jquery.fancybox.min.js"></script>')




