// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/

using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
[ExecuteInEditMode]
public class PointCloud : MonoBehaviour {

    public enum ShapeMode { CUBE, SPHERE, PLANE };
    public ShapeMode shapeMode = ShapeMode.SPHERE;
    public int numPoints = 60000;
    public Color color;

    private Mesh mesh;
    private MeshFilter meshFilter;
    private float size = 1f;

    private void Awake() {
        if (mesh == null) mesh = new Mesh();
        meshFilter = GetComponent<MeshFilter>();
    }

    private void Start() {
        CreateMesh();
    }

    private void CreateMesh() {
        Vector3[] points = new Vector3[numPoints];
        int[] indices = new int[numPoints];
        Color[] colors = new Color[numPoints];

        for (int i = 0; i < points.Length; ++i) {
            Vector3 p = new Vector3(Random.Range(-size, size), Random.Range(-size, size), Random.Range(-size, size));

            if (shapeMode == ShapeMode.CUBE) {
                points[i] = p;
            } else if (shapeMode == ShapeMode.SPHERE) {
                points[i] = sphereCoords(p); 
            } else if (shapeMode == ShapeMode.PLANE) {
                points[i] = new Vector3(p.x, 0f, p.z);
            }

            indices[i] = i;
            colors[i] = color; // new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f);
        }

        mesh.vertices = points;
        mesh.colors = colors;
        mesh.SetIndices(indices, MeshTopology.Points, 0);
        meshFilter.mesh = mesh;
    }

    private Vector3 sphereCoords(Vector3 a_coords_n) {
        a_coords_n = Vector3.Normalize(a_coords_n);
        float lon = Mathf.Atan2(a_coords_n.z, a_coords_n.x);
        float lat = Mathf.Acos(a_coords_n.y);
        Vector2 radialCoords = new Vector2(lon, lat) * (1f / Mathf.PI);
        return new Vector3(radialCoords.x, radialCoords.y, a_coords_n.z);
    }

}