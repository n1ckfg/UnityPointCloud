import peasy.*;

PeasyCam cam;
PImage img;
int scaleImg = 4;
int depth = 0;
ArrayList<Dot> dots;

void setup() {
  size(50, 50, P3D);
  imageMode(CENTER);
  
  img = loadImage("desert_depth.png");
  img.loadPixels();
  dots = new ArrayList<Dot>();

  surface.setSize(img.width, img.height);
  depth = (img.width + img.height) / 2;
  
  cam = new PeasyCam(this, 300);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(1000);
  
  for (int x = 0; x < img.width; x += scaleImg) {
    for (int y = 0; y < img.height; y += scaleImg) {
      int loc = x + y * (img.width);
      float xf = float(x);
      float yf = float(y);
      float zf = (red(img.pixels[loc]) / 255 * depth) - (depth/2);
      println(xf + " " + yf + " " + zf);
      PVector p = new PVector(xf, yf, zf);
      dots.add(new Dot(p, color(img.pixels[loc])));
    }
  }
}

void draw() {
  background(0);
  pushMatrix();
  scale(0.1, 0.1);
  translate(width/2, height/2, 0);
  image(img, 0, 0);
  popMatrix();
  
  for (int i=0; i<dots.size(); i++) {
    dots.get(i).draw();
  }
}