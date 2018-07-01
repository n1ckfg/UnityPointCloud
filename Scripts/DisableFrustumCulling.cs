// https://answers.unity.com/questions/36446/disable-frustum-culling.html
// http://allenwp.com/blog/2013/12/19/disabling-frustum-culling-on-a-game-object-in-unity/

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisableFrustumCulling : MonoBehaviour {

    private Mesh mesh;
    private float boundsVal = 99999f;

    private void Awake() {
        mesh = GetComponent<MeshFilter>().mesh;
        mesh.bounds = new Bounds(Vector3.zero, new Vector3(boundsVal, boundsVal, boundsVal));
    }

}
