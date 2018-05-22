using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Slideshow : MonoBehaviour {

    public Texture2D[] pics;
    public float picDelay = 1f;
    public Renderer ren;
    public int picCounter = 0;
    public bool runSlideshow = true;

    private Material mat;

	private void Start() {
        mat = ren.sharedMaterial;
        mat.mainTexture = pics[picCounter];
        if (runSlideshow) startSlideshow();
	}
	
    private IEnumerator picAdvance() {
        while (runSlideshow) {
            yield return new WaitForSeconds(picDelay);
            picForward();
        }
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
        mat.mainTexture = pics[picCounter];
    }

    public void picBack() {
        picCounter--;
        if (picCounter < 0) picCounter = pics.Length - 1;
        mat.mainTexture = pics[picCounter];
    }

}
