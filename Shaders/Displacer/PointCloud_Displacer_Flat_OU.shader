Shader "PointCloud/Displacer/Flat_OU"{

	Properties{
		_MainTex("Texture", 2D) = "white" {}
		_Displacement("Displacement", float) = 0.1
		_BaselineLength("Baseline Length", float) = 0.5
		_FocalLength("Focal Length", float) = 90.0
	}

		SubShader{
		Tags{ "RenderType" = "Opaque" }
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
	float _FocalLength;

	struct Input {
		float2 uv_MainTex;
	};

	inline float getDepthFlat(float d) {
		return _FocalLength * _BaselineLength / d;
	}

	void disp(inout appdata_full v) {
		v.vertex.xyz += v.normal * getDepthFlat(tex2Dlod(_MainTex, float4(v.texcoord.xy * float2(1, 0.5), 0, 0)).r) * _Displacement;
	}

	void surf(Input IN, inout SurfaceOutput o) {
		fixed4 mainTex = tex2D(_MainTex, IN.uv_MainTex * float2(1, 0.5) + float2(0, 0.5));
		o.Emission = mainTex.rgb;
	}

	ENDCG
	}

		FallBack "Diffuse"

}