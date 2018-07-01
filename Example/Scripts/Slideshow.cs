using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slideshow : MonoBehaviour {

    [System.Serializable]
    public struct PicInfo {

        public Texture2D tex;
        public float displacement;
        public float maximum;

    }

    public PicInfo[] pics;
    public float picDelay = 1f;
    public Renderer ren;
    public int picCounter = 0;
    public bool runSlideshow = true;

    private Material mat;

	private void Start() {
        mat = ren.sharedMaterial;
        mat.mainTexture = pics[picCounter].tex;
        if (runSlideshow) startSlideshow();
	}
	
    private IEnumerator picAdvance() {
        while (runSlideshow) {
            yield return new WaitForSeconds(picDelay);
            picForward();
        }
    }

    private void usePicProperties() {
        mat.mainTexture = pics[picCounter].tex;
        mat.SetFloat("_Displacement", pics[picCounter].displacement);
        mat.SetFloat("_Maximum", pics[picCounter].maximum);
    }

    public void startSlideshow() {
        runSlideshow = true;
        StartCoroutine(picAdvance());
    }

    public void stopSlideshow() {
        runSlideshow = false;
    }

    public void picForward() {
        picCounter++;
        if (picCounter > pics.Length - 1) picCounter = 0;
        usePicProperties();
    }

    public void picBack() {
        picCounter--;
        if (picCounter < 0) picCounter = pics.Length - 1;
        usePicProperties();
    }

}
