Shader "PointCloud/Displacer/RGBA_SphericalAlt"{
    
    Properties{
        _MainTex ("Texture", 2D) = "white" {}
		_Displacement("Displacement", float) = 10.0
		_Maximum("Maximum", float) = 99.0
		_Fov("Field of View", float) = 1.0
		_SupersampleScale("Supersample Scale", float) = 1.0
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
		float _Maximum;
		float _Fov;
		float _SupersampleScale;

        struct Input{
			float2 uv_MainTex;
        };
 
		void disp(inout appdata_full v) {
			float fov = 3.14159 *_Fov / 360;

			v.texcoord.xy = (v.texcoord.xy * float2(1,-1) * _SupersampleScale * 2) - _SupersampleScale;

			float phi = fov * v.texcoord.x;
			float theta = fov * v.texcoord.y;

			float tanFov = tan(fov);

			v.texcoord.x = tan(phi) / tanFov;
			v.texcoord.y = tan(theta) / (cos(phi) * tanFov);

			v.texcoord.xy = (v.texcoord.xy * 0.5) + 0.5;

			float linearDepth = Linear01Depth(tex2Dlod(_MainTex, float4(v.texcoord.xy, 0, 0)).a);
			float linearDistance = linearDepth / abs(cos(phi) * cos(theta));
			float logisticDistance = 2 / (1 + exp(-10 * linearDistance)) - 1;
			
			v.vertex.xyz = v.normal * clamp(logisticDistance, 0, _Maximum / 100000) * (_Displacement * 100);
		}
 
		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex.xy);
			o.Emission = mainTex.rgb;
		}
        
        ENDCG
    }

    FallBack "Diffuse"

}