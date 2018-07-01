Shader "PointCloud/Displacer/RGBA"{
    
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
        _Displacement ("Displacement", float) = 0.1
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

        struct Input{
			float2 uv_MainTex;
        };

        void disp (inout appdata_full v){
            v.vertex.xyz += v.normal * tex2Dlod(_MainTex, float4(v.texcoord.xy, 0, 0)).a * _Displacement;
        }
 
		void surf(Input IN, inout SurfaceOutput o){
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			o.Emission = mainTex.rgb;
		}
        
        ENDCG
    }

    FallBack "Diffuse"

}