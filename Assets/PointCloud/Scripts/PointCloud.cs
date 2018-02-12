// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
[ExecuteInEditMode]
public class PointCloud : MonoBehaviour {

    public enum ShapeMode { CUBE, SPHERE, PLANE, FILE, MESH };
    public ShapeMode shapeMode = ShapeMode.SPHERE;
    public string fileName = "";
    public Mesh referenceMesh;
    public int numPoints = 60000;
    public Color color;

    private Mesh mesh;
    private MeshFilter meshFilter;
    private float size = 1f;
    private string url;
    private List<Vector3> pointsFromFile;
    private string splitChar = " ";

    private Vector3[] points;
    private Vector3[] normals;
    private int[] indices;
    private Color[] colors;
    private Vector2[] uvs;

    private void Awake() {
        pointsFromFile = new List<Vector3>();
        mesh = new Mesh();
        meshFilter = GetComponent<MeshFilter>();

        StartCoroutine(CreateMesh());
    }

    private IEnumerator CreateMesh() {
        if (shapeMode == ShapeMode.FILE) {
            url = "file://" + Path.Combine(Application.streamingAssetsPath, fileName);

            Debug.Log("Loading point cloud data from: \n" + url);
            WWW www = new WWW(url);
            yield return www;

            string[] fileNameExt = fileName.Split('.');
            string extension = fileNameExt[fileNameExt.Length - 1];

            if (extension == "bin") {
                byte[] bytes = www.bytes;
                for (int i = 0; i < bytes.Length; i += 16) {
                    /*
                    byte[] bytesX = { bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3] };
                    byte[] bytesY = { bytes[i + 4], bytes[i + 5], bytes[i + 6], bytes[i + 7] };
                    byte[] bytesZ = { bytes[i + 8], bytes[i + 9], bytes[i + 10], bytes[i + 11] };
                    byte[] bytesW = { bytes[i + 12], bytes[i + 13], bytes[i + 14], bytes[i + 15] };

                    float x = System.BitConverter.ToSingle(bytesX, 0);
                    float y = System.BitConverter.ToSingle(bytesY, 0);
                    float z = System.BitConverter.ToSingle(bytesZ, 0);
                    float w = System.BitConverter.ToSingle(bytesW, 0);
                    */
                    float x = System.BitConverter.ToSingle(bytes, i);
                    float y = System.BitConverter.ToSingle(bytes, i + 4);
                    float z = System.BitConverter.ToSingle(bytes, i + 8);
                    float w = System.BitConverter.ToSingle(bytes, i + 12);
                    pointsFromFile.Add(new Vector3(x, y, z));
                }
            } else {
                string[] lines = www.text.Split('\n');
                if (extension == "csv") {
                    for (int i = 1; i < lines.Length - 1; i++) {
                        string[] vRaw = lines[i].Split(',');
                        string xS = vRaw[1];
                        string yS = vRaw[2];
                        string zS = vRaw[3];
                        float x = float.Parse(xS);
                        float y = float.Parse(yS);
                        float z = float.Parse(zS);
                        pointsFromFile.Add(new Vector3(x, y, z));
                    }
                } else { // assume asc
                    for (int i = 0; i < lines.Length - 1; i++) {
                        string[] vRaw = lines[i].Split(splitChar.ToCharArray()[0]);
                        string xS = vRaw[0];
                        string yS = vRaw[1];
                        string zS = vRaw[2];
                        float x = float.Parse(xS);
                        float y = float.Parse(yS);
                        float z = float.Parse(zS);
                        pointsFromFile.Add(new Vector3(x, y, z));
                    }
                }
            }

            numPoints = pointsFromFile.Count;
        } else if (shapeMode == ShapeMode.MESH) {
            numPoints = referenceMesh.vertices.Length;
        }

        points = new Vector3[numPoints];
        normals = new Vector3[numPoints];
        indices = new int[numPoints];
        colors = new Color[numPoints];
        uvs = new Vector2[numPoints];

        for (int i = 0; i < points.Length; ++i) {
            if (shapeMode == ShapeMode.CUBE) {
                points[i] = randomPoint(size);
            } else if (shapeMode == ShapeMode.SPHERE) {
                points[i] = Random.insideUnitSphere * size;
            } else if (shapeMode == ShapeMode.PLANE) {
                Vector3 p = randomPoint(size);
                points[i] = new Vector3(p.x, 0f, p.z);
            }

            indices[i] = i;
            colors[i] = color; // new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f);
        }

        if (shapeMode == ShapeMode.FILE) {
            points = pointsFromFile.ToArray();
        } else if (shapeMode == ShapeMode.MESH) {
            points = referenceMesh.vertices;
            normals = referenceMesh.normals;
            uvs = referenceMesh.uv;
        }

        mesh.vertices = points;
        mesh.normals = normals;
        mesh.colors = colors;
        mesh.uv = uvs;
        mesh.SetIndices(indices, MeshTopology.Points, 0);

        meshFilter.mesh = mesh;

        yield return null;
    }

    private Vector3 randomPoint(float size) {
        return new Vector3(Random.Range(-size, size), Random.Range(-size, size), Random.Range(-size, size));
    }

    private Vector2[] createMeshUvs(Mesh mesh) {
        Vector2[] returns = new Vector2[mesh.vertices.Length];
        for (int i = 0; i < returns.Length; i++) {
            returns[i] = new Vector2(mesh.normals[i].x, mesh.normals[i].y); // TODO replace temp
        }
        return returns;
    }

    private Vector3[] createMeshNormals(Mesh mesh) {
        Vector3[] returns = new Vector3[mesh.vertices.Length];
        for (int i = 0; i < returns.Length-1; i++) {
            returns[i] = calculateNormal(mesh.vertices[i], mesh.vertices[i + 1]);
        }
        return returns;
    }

    // https://www.khronos.org/opengl/wiki/Calculating_a_Surface_Normal
    private Vector3 calculateNormal(Vector3 v1, Vector3 v2) {
        Vector3 returns = Vector3.zero;
        //returns.x += (v1.y -v2.y) * (v1.z + v2.z);
        //returns.y += (v1.z -v2.z) * (v1.x + v2.x);
        //returns.z += (v1.x -v2.x) * (v1.y + v2.y);
        return Vector3.Normalize(returns);
    }

    private void CreateMeshFromReference() {
        mesh = new Mesh();
        mesh.vertices = referenceMesh.vertices;
        mesh.uv = referenceMesh.uv;
        mesh.normals = referenceMesh.normals;
        mesh.uv2 = referenceMesh.uv2;
        mesh.triangles = referenceMesh.triangles;
        meshFilter.mesh = mesh;
    }

    /*
    private Vector3 sphereCoords(Vector3 a_coords_n) {
        a_coords_n = Vector3.Normalize(a_coords_n);
        float lon = Mathf.Atan2(a_coords_n.z, a_coords_n.x);
        float lat = Mathf.Acos(a_coords_n.y); 
        Vector2 radialCoords = new Vector2(lon, lat) * (1f / Mathf.PI);
        return new Vector3(radialCoords.x, radialCoords.y, a_coords_n.z);
    }
 
    List<Vector3> pointsOnSphere(float n) {
        List<Vector3> points = new List<Vector3>();
        float inc = Mathf.PI * (3f - Mathf.Sqrt(5));
        float off = 2f / n;
        float x;
        float y;
        float z;
        float r;
        float phi;

        for (int k = 0; k < n; k++) {
            y = k * off - 1 + (off / 2);
            r = Mathf.Sqrt(1 - y * y);
            phi = k * inc;
            x = Mathf.Cos(phi) * r;
            z = Mathf.Sin(phi) * r;

            points.Add(new Vector3(x, y, z));
        }
        return points;
    }

    Vector3 pointOnSphere(float n) {
        float inc = Mathf.PI * (3f - Mathf.Sqrt(5));
        float off = 2f / n;
        float x;
        float y;
        float z;
        float r;
        float phi;

        int k = 0;
        y = k * off - 1 + (off / 2);
        r = Mathf.Sqrt(1 - y * y);
        phi = k * inc;
        x = Mathf.Cos(phi) * r;
        z = Mathf.Sin(phi) * r;

        return (new Vector3(x, y, z));
    }
    */

}