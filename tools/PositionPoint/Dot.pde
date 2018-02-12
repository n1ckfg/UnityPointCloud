class Dot {

  PVector p, n, r, pn;
  color c;
  float normalLength = 40;
 
  Dot(PVector _p, color _c) {
    p = _p;
    c = _c;

    r = radialCoords(p);
    n = calcNormal(r);
    p = new PVector((p.x * width) - (width/2), (p.y * height) - (height/2), getDepth(p.z));
    pn = n.mult(normalLength);
    
  }
  
  void draw() {
    strokeWeight(8);
    stroke(c);
    
    pushMatrix();
    translate(p.x, p.y, p.z);
    point(0,0);

    strokeWeight(1);
    stroke(255, 0, 255, 63);
    line(0, 0, 0, pn.x, pn.y, pn.z);
    popMatrix();
  }
 
  // https://stackoverflow.com/questions/47886195/360videoplayer-warped-in-unity
  PVector radialCoords(PVector a_coords) {
    PVector a_coords_n = a_coords.normalize();
    float lon = atan2(a_coords_n.z, a_coords_n.x);
    float lat = acos(a_coords_n.y);
    PVector sphereCoords = new PVector(lon, lat).mult(1.0 / PI);
    return new PVector(sphereCoords.x * 0.5 + 0.5, 1 - sphereCoords.y);
  }
  
  float getDepth(float d) {
    float baseline_length = 0.5;
    float spherical_angle = 10;
    return asin(baseline_length * sin(spherical_angle)) / asin(d);
  }
  
  // https://stackoverflow.com/questions/39292925/glsl-calculating-normal-on-a-sphere-mesh-in-vertex-shader-using-noise-function-b
  PVector calcNormal(PVector pos) {
    float theta = 0.00001; 
    PVector vecTangent = pos.cross(new PVector(1.0, 0.0, 0.0)).add(pos.cross(new PVector(0.0, 1.0, 0.0))).normalize();
    PVector vecBitangent = vecTangent.cross(pos).normalize();
    PVector ptTangentSample = getPos(vecTangent.normalize().mult(theta).add(pos).normalize());
    PVector ptBitangentSample = getPos(vecBitangent.normalize().mult(theta).add(pos).normalize());
  
     return ptTangentSample.sub(pos).cross(ptBitangentSample.sub(pos)).normalize();
  }
  
  PVector getPos(PVector p) {
    return new PVector(noise(p.x), noise(p.y), noise(p.z));
  }

}