using UnityEngine;
using System.Collections;

public class DepthSphere : MonoBehaviour {

	public Mesh referenceSphere;
	public MeshFilter meshFilter;
	public MeshRenderer meshRenderer;

	Mesh particleMesh;

	public int sliceCount;
	public int tessellation =8;

	Vector3[] vertexPositions;
	Vector2[] vertexUVs;
	Vector2[] vertexData;
	int[] vertexTriangles;
	Vector3[] vNormals;


	void Start(){
		CreateTessellatedSphere();
		//CreateDepthSystem();
		CreateMesh();
	}
	void CreateTessellatedSphere(){
		

		Vector3[] s_vertices = referenceSphere.vertices;
		int[] s_triangles = referenceSphere.triangles;
		Vector2[] s_uv = referenceSphere.uv;
		Vector3[] s_normals = referenceSphere.normals;

		vertexPositions = new Vector3[sliceCount * s_vertices.Length];
		vertexTriangles = new int[sliceCount * s_triangles.Length];
		vertexUVs = new Vector2[sliceCount * s_uv.Length];
		vertexData = new Vector2[sliceCount * s_uv.Length];
		vNormals = new Vector3[sliceCount * s_vertices.Length];
		for(int i=0; i<sliceCount; i++){
			for(int v=0; v<s_vertices.Length; v++){
				int idx = v + s_vertices.Length * i;
				vertexPositions[idx] = s_vertices[v];
				vertexUVs[idx] = s_uv[v];
				vertexData[idx] = new Vector2((float)i/(float)(sliceCount-1),0);
				vNormals[idx] = s_normals[v];
			}

			for(int t=0; t<s_triangles.Length; t++){
				int idx = t + s_triangles.Length * i;
				vertexTriangles[idx] = s_triangles[t] + i*s_vertices.Length;
			}
		}
	}


	void CreateMesh(){
		particleMesh = new Mesh();
		particleMesh.vertices = vertexPositions;
		particleMesh.uv = vertexUVs;
		particleMesh.normals = vNormals;
		particleMesh.uv2 = vertexData;
		particleMesh.triangles = vertexTriangles;
		particleMesh.bounds = new Bounds(Vector3.zero, new Vector3(2,2,10));
		meshFilter.mesh = particleMesh;

	}

}
