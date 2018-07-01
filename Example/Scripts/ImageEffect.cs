using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class ImageEffect : MonoBehaviour {

    public Material mat;

    private void OnRenderImage(RenderTexture source, RenderTexture dest) {
        Graphics.Blit(source, dest, mat);
    }

}
