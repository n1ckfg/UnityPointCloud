using UnityEngine;
using System.Collections;

[RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
[ExecuteInEditMode]
public class PointCloud : MonoBehaviour {

    public int numPoints = 60000;
    public float size = 5f;
    public Color color;

    private Mesh mesh;

    private void Start() {
        mesh = new Mesh();
        GetComponent<MeshFilter>().mesh = mesh;
        CreateMesh();
    }

    private void CreateMesh() {
        Vector3[] points = new Vector3[numPoints];
        int[] indecies = new int[numPoints];
        Color[] colors = new Color[numPoints];
        for (int i = 0; i < points.Length; ++i) {
            points[i] = new Vector3(Random.Range(-size, size), Random.Range(-size, size), Random.Range(-size, size));
            indecies[i] = i;
            colors[i] = color; // new Color(Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), Random.Range(0.0f, 1.0f), 1.0f);
        }

        mesh.vertices = points;
        mesh.colors = colors;
        mesh.SetIndices(indecies, MeshTopology.Points, 0);
    }

}