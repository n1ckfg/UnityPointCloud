Shader "PointCloud/Displacer/Spherical_OU"{
    
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Displacement ("Displacement", float) = 0.1
		_Maximum("Maximum", float) = 99.0
		_BaselineLength("Baseline Length", float) = 0.5
        _SphericalAngle("Spherical Angle", float) = 10.0 
        _FocalLength("Focal Length", float) = 90.0 
	}
 
    SubShader{
        Tags { "RenderType"="Opaque" }
        Cull Back
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
        float _FocalLength;
		float _Maximum;

        struct Input{
			float2 uv_MainTex;
        };
 
        inline float getDepthSpherical(float d) {
            return asin(_BaselineLength * sin(_SphericalAngle)) / asin(d);
        }

        inline float getDepthFlat(float d) {
            return (_FocalLength / -100.0) * _BaselineLength / d;
        }

        void disp (inout appdata_full v){
            v.vertex.xyz = v.normal * clamp(getDepthSpherical(tex2Dlod(_MainTex, float4(v.texcoord.xy * float2(1, 0.5), 0, 0)).r), -_Maximum, 0) * _Displacement;
        }
 
        void surf(Input IN, inout SurfaceOutput o){
            fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex * float2(1, 0.5) + float2(0, 0.5));
            o.Emission = mainTex.rgb;
        }
        
        ENDCG
    }

    FallBack "Diffuse"

}