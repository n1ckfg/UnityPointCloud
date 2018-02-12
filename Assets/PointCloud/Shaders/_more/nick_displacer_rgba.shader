Shader "Nick/DisplacerRGBA"{
    
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Displacement ("Displacement", float) = 0.1
		_BaselineLength("Baseline Length", float) = 0.5
		_SphericalAngle("Spherical Angle", float) = 10.0 
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
 
        sampler2D _MainTex;
        float _Displacement;
		float _BaselineLength;
		float _SphericalAngle;

        struct Input{
			float2 uv_MainTex;
        };
 
		inline float getDepth(float d) {
			float baseline_length = _BaselineLength;
			float spherical_angle = _SphericalAngle;
			return asin(baseline_length * sin(spherical_angle)) / asin(d);
		}

        void disp (inout appdata_full v){
            v.vertex.xyz = v.normal * getDepth(tex2Dlod(_MainTex, float4(v.texcoord.xy, 0, 0)).a) * _Displacement;
        }
 
		void surf(Input IN, inout SurfaceOutput o){
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			o.Emission = mainTex.rgb;
		}
        
        ENDCG
    }

    FallBack "Diffuse"

}