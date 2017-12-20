//Table cities;
ArrayList<City> places;

float threshold = 0.5;
float targetLat = -1;
float lonThresh = 45;

float maxLat = 85;

float jiggle = 0.5;

int buffer = 100;

void setup()
{
  size(1080, 720);
  places = new ArrayList<City>();

  Table cities =loadTable("cities.csv", "header");
  //println(cities.getStringColumn("Latitude"));
  for (int i = 0; i<cities.getRowCount(); i++)
  {
    TableRow r = cities.getRow(i);

    String slat = r.getString("Latitude");
    String [] s = split(slat, "°");
    float lat = float(s[0]);
    s = split(s[1], "'");
    lat += float(s[0])/160;
    if (s[1].equals("S")) lat*=-1;

    String slon = r.getString("Longitude");
    s = split(slon, "°");
    float lon = float(s[0]);
    s = split(s[1], "'");
    lon += float(s[0])/160;
    if (s[1].equals("W")) lon*=-1;

    float x = map(lon, -180, 180, 0, width-buffer);
    float y = map(lat, -maxLat, maxLat, height, 0);

    String name = " " + r.getString("City") + "\n" + r.getString("Country");

    City c = new City();
    c.p = new PVector(x, y);
    c.latlon = new PVector(lon, lat);
    c.name = name;

    places.add(c);
  }
  findNearest();
}

void draw()
{
  background(200,200,255);
  targetLat = -91;
  for (City c : places)
  {
    c.display();
  }

  
  if (targetLat>-91)
  {
    fill(200,200,255,150);
    noStroke();
    rect(0,0,width,height);
    for (City c : places)
    {
      c.showInfo();
    }
  }
  
  float mouseLon = map(mouseX, 0, width-buffer,-180, 180);
  float mouseLat = map(mouseY, height, 0, -maxLat, maxLat);
  
  noFill();
  stroke(0,0,255);
  ellipse(map(((mouseLon+360)%360)-180, -180, 180, 0, width-buffer), map(-mouseLat, -maxLat, maxLat, height, 0),5,5);
  //if (targetLat>-1)
  //{
  //    fill(0);
  //    text(((mouseLon+360)%360)-180 + ", " + (-mouseLon), map(((mouseLon+360)%360)-180, -180, 180, 0, width-100),map(-mouseLat, -70, 85, height, 0));
  //}
  ////places.get(i).anaP = new PVector(((lon+360)%360)-180, -lat);
}

class City
{
  String name, country;
  PVector latlon;
  PVector p, anaP;
  int radius = 6;
  boolean compare = false;
  int nearestHem, nearestOtherHem, nearestAnaNg;
  
  void showInfo()
  {
        if (PVector.dist(p, new PVector(mouseX, mouseY))<radius*0.5)
        {
          fill(0);
          text(name, p.x, p.y);
          text(int(100*latlon.x)/100.0 + ", " + int(100*latlon.y)/100.0, p.x, p.y+30);
          //targetLat = latlon.y;
          
          if(nearestHem>-1) {
            places.get(nearestHem).compare = true;
            
            stroke(0);
            line(p.x,p.y, p.x, places.get(nearestHem).p.y);
            line(places.get(nearestHem).p.x,places.get(nearestHem).p.y, p.x, places.get(nearestHem).p.y);
            
            fill(0);
            ellipse(places.get(nearestHem).p.x,places.get(nearestHem).p.y, 3,3);
            
            strokeWeight(10);
            stroke(0,0,255,100);
            line(0, p.y, width, p.y);
            strokeWeight(1);
          
          }
          if(nearestOtherHem>-1){
            places.get(nearestOtherHem).compare = true;
            stroke(0);
            line(p.x,p.y, p.x, places.get(nearestOtherHem).p.y);
            line(places.get(nearestOtherHem).p.x,places.get(nearestOtherHem).p.y, p.x, places.get(nearestOtherHem).p.y);
            
            ellipse(places.get(nearestOtherHem).p.x,places.get(nearestOtherHem).p.y, 3,3);
            
            strokeWeight(10);
            stroke(255,0,0,100);
            line(0, places.get(nearestOtherHem).p.y, width, places.get(nearestOtherHem).p.y);
            strokeWeight(1);
          }
          
          noFill();
          fill(200,100,0);
          ellipse(places.get(nearestAnaNg).p.x, places.get(nearestAnaNg).p.y,2*radius, 2*radius);
          text(places.get(nearestAnaNg).name, places.get(nearestAnaNg).p.x, places.get(nearestAnaNg).p.y);
          text(int(100*places.get(nearestAnaNg).latlon.x)/100.0+ ", " + int(places.get(nearestAnaNg).latlon.y*100)/100.0, places.get(nearestAnaNg).p.x, places.get(nearestAnaNg).p.y+30);
          noStroke();
          
          ellipse(p.x, p.y, radius, radius);
        }
        
        
        if(compare)
        {
            fill(0);
            text(name, p.x, p.y);
            text(int(100*latlon.x)/100.0 + ", " + int(100*latlon.y)/100.0, p.x, p.y+30);
            compare = false;
        }
        
  }
  
  void display()
  {
    noStroke();
    fill(255);
    ellipse(p.x, p.y, radius, radius);
    
    if (PVector.dist(p, new PVector(mouseX, mouseY))<radius*0.5)
    {
      targetLat = latlon.y;
      //println(name);
    }
    
  }
}

void findNearest()
{
  for (int i= 0; i<places.size(); i++)
  {
    places.get(i).nearestHem = -1;
    places.get(i).nearestOtherHem = -1;
    places.get(i).nearestAnaNg = -1;
    float lat = places.get(i).latlon.y;
    float lon = places.get(i).latlon.x;
    
    float nearestLat = 180;
    float nearestOppLat = 180;
    float anaDist = 180;
    places.get(i).anaP = new PVector(((lon+360)%360)-180, -lat);
    
    for(int j = 0; j<places.size(); j++)
    {
       
        if(i!=j)
        {
          City c = places.get(j);
          
          if(abs(lat-c.latlon.y)<nearestLat && abs(lon-c.latlon.x)>lonThresh) 
          {
              nearestLat =abs(lat-c.latlon.y)+random(jiggle);
              places.get(i).nearestHem = j;
          }
          
          if(abs(lat+c.latlon.y)<nearestOppLat) 
          {
              nearestOppLat =abs(lat+c.latlon.y)+random(jiggle);
              places.get(i).nearestOtherHem = j;
          }
          
          float thisDist = pow(places.get(i).anaP.y-c.latlon.y,2);
          float dx = cos(radians(places.get(i).anaP.y))*(places.get(i).anaP.x-c.latlon.x);
          thisDist += pow(dx,2);
          thisDist = sqrt(thisDist);
          
          if(thisDist<anaDist)
          //if( places.get(i).anaP.x-c.latlon.x)<anaDist*anaDist)
          {
              //anaDist =PVector.dist(places.get(i).anaP, c.latlon);
              anaDist =thisDist;
              places.get(i).nearestAnaNg = j;
          }
        }
    }
  }
}

void keyPressed()
{
    if(key=='r') setup();
    if(key=='f') findNearest();
    if(key=='p') saveFrame("images/####.jpg");
}