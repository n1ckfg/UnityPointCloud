Shader "PointCloud/Displacer/RGBD_Basic" {
    
    Properties {
        _MainTex ("Texture", 2D) = "white" {}
        _DispTex ("Displacement Texture", 2D) = "gray" {}
	}
 
    SubShader{
        Tags { "RenderType"="Opaque" }
        Cull Front
        Lighting Off 
        LOD 300
 
        CGPROGRAM
        #pragma surface surf Lambert vertex:disp nolightmap
        #pragma target 3.0
        #pragma glsl
 
        sampler2D _DispTex;

        struct Input {
            float2 uv_DispTex;
			float2 uv_MainTex;
        };

		float3 uvd_to_xyz(float u, float v, float d) {
			float cx = 320. / 640.; // principal point x
			float cy = 240. / 480.; // principal point y
			float fx = 525. / 640.; // focal length x
			float fy = 525. / 480.; // focal length y

			float x_over_z = (cx - u) / fx;
			float y_over_z = (cy - v) / fy;

			float z = d / sqrt(1.0 + pow(x_over_z, 2.0) + pow(y_over_z, 2.0));
			float x = x_over_z * z;
			float y = y_over_z * z;

			return float3(x, y, z);
		}

        void disp (inout appdata_full v) {
            float3 dcolor = tex2Dlod(_DispTex, float4(v.texcoord.xy,0,0));
			v.vertex.xyz = uvd_to_xyz(v.texcoord.x, v.texcoord.y, 1.0 - dcolor.r);
		}
 
        sampler2D _MainTex;

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);

			o.Emission = mainTex.rgb;
		}
        
        ENDCG
    }

    FallBack "Diffuse"

}