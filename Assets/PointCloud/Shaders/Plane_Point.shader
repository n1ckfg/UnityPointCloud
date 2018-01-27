// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/

Shader "Custom/Plane_Point" { 

    Properties {
		_MainTex("Diffuse RGBA", 2D) = "gray" {}
		_DispTex("Depth", 2D) = "gray" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Displacement("Displacement", float) = 1.0
	}

	SubShader {
		Tags{ "RenderType" = "Opaque" }
		Cull Front
		Lighting Off
		LOD 300

		CGPROGRAM
		#pragma surface surf Lambert vertex:disp nolightmap
		#pragma target 3.0
		#pragma glsl

		sampler2D _MainTex;  
		sampler2D _DispTex;
		float4 _Color;
		float _Displacement;

		struct Input {
			float2 uv_MainTex;
			float2 uv_DispTex;
		};

		void disp(inout appdata_full v) {
			float3 dcolor = tex2Dlod(_DispTex, float4(v.texcoord.xy, 0, 0));
			float d = dcolor.r;
			v.vertex.xyz += v.normal * d * _Displacement;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex);
			o.Emission = mainTex.rgb; 
		}

		ENDCG
	}

	FallBack "Diffuse"

}