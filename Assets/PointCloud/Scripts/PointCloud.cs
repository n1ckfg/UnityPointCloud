// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/

using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.IO;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
[ExecuteInEditMode]
public class PointCloud : MonoBehaviour {

    public enum ShapeMode { CUBE, SPHERE, PLANE, FILE };
    public ShapeMode shapeMode = ShapeMode.SPHERE;
    public string fileName = "";
    public string splitChar = " ";
    public int numPoints = 60000;
    public Color color;

    private Mesh mesh;
    private MeshFilter meshFilter;
    private float size = 1f;
    private string url;
    private List<Vector3> pointsFromFile;

    private void Awake() {
        pointsFromFile = new List<Vector3>();

        if (mesh == null) mesh = new Mesh();
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
            string extension = fileNameExt[fileNameExt.Length-1];

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
                    float y = System.BitConverter.ToSingle(bytes, i+4);
                    float z = System.BitConverter.ToSingle(bytes, i+8);
                    float w = System.BitConverter.ToSingle(bytes, i+12);
                    pointsFromFile.Add(new Vector3(x, y, z));
                }
            } else {
                string[] lines = www.text.Split('\n');
                for (int i = 0; i < lines.Length - 1; i++) {
                    string[] vRaw = lines[i].Split(splitChar.ToCharArray()[0]);
                    if (i < 10) Debug.Log(vRaw[0] + " " + vRaw[1] + " " + vRaw[2]);
                    string xS = vRaw[0];
                    string yS = vRaw[1];
                    string zS = vRaw[2];
                    float x = float.Parse(xS);
                    float y = float.Parse(yS);
                    float z = float.Parse(zS);
                    pointsFromFile.Add(new Vector3(x, y, z));
                }
            }

            numPoints = pointsFromFile.Count;
        }

        Vector3[] points = new Vector3[numPoints];
        int[] indices = new int[numPoints];
        Color[] colors = new Color[numPoints];

        for (int i = 0; i < points.Length; ++i) {
            if (shapeMode == ShapeMode.CUBE) {
                points[i] = randomPoint(size);
            } else if (shapeMode == ShapeMode.SPHERE) {
                points[i] = Random.insideUnitSphere * size;
            } else if (shapeMode == ShapeMode.PLANE) {
                Vector3 p = randomPoint(size);
                points[i] = new Vector3(p.x, 0f, p.z);
            } else if (shapeMode == ShapeMode.FILE) {
                points[i] = pointsFromFile[i];
            }

            indices[i] = i;
            colors[i] = color; // new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f);
        }

        mesh.vertices = points;
        mesh.colors = colors;
        mesh.SetIndices(indices, MeshTopology.Points, 0);
        meshFilter.mesh = mesh;
        createMeshNormals(mesh);

        yield return null;
    }

    private Vector3 randomPoint(float size) {
        return new Vector3(Random.Range(-size, size), Random.Range(-size, size), Random.Range(-size, size));
    }

    private void createMeshNormals(Mesh mesh) {
        Vector3[] normals = mesh.normals;

        //Quaternion rotation = Quaternion.AngleAxis(Time.deltaTime * 0.1f, Vector3.up);
        for (int i = 0; i < normals.Length; i++) {
            //normals[i] = rotation * normals[i];
            normals[i] = randomPoint(1f);
        }
        mesh.normals = normals;
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