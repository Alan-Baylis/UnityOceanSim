﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShadedOceanSurface : MonoBehaviour {

	// Use this for initialization
	void Start () {
		
	}
	
	// Update is called once per frame
	void Update () {
        Shader.SetGlobalFloat("_WaterTime", Time.time);

        var mesh = GetComponent<MeshFilter>().mesh;
    }
}
