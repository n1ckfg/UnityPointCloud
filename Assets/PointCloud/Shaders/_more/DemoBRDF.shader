// https://www.youtube.com/watch?v=_Y_0cgWu5bQ

Shader "Custom/DemoBRDF" {
	
	Properties {
		_Ramp2D("BRDF Ramp", 2D) = "gray" {}
		_Color("Color", color) = (1,1,1,1)
	}

	SubShader{
		Tags { "RenderType" = "Opaque" }
		LOD 200

		CGPROGRAM
		#pragma surface surf Ramp
		#pragma target 3.0

		sampler2D _Ramp2D;
		half4 _Color;

		struct Input {
			float2 uv_MainTex;
		};

		half4 LightingRamp(SurfaceOutput s, half3 lightDir, half3 viewDir, half atten) {
			float NdotL = dot(s.Normal, lightDir);
			float NdotE = dot(s.Normal, viewDir);

			// do diffuse wrap here
			float diff = (NdotL * 0.5) + 0.5;
			float2 brdfUV = float2(NdotE, diff);
			float3 BRDF = tex2D(_Ramp2D, brdfUV.xy).rgb;


			float4 c;
			c.rgb = BRDF * _Color;
			c.a = s.Alpha;
			return c;
		}

		void surf(Input IN, inout SurfaceOutput o) {
			half4 c = float4(0.5, 0.5, 0.5, 1);
			o.Albedo = c.rgb;
			o.Alpha = c.a;
		}
		ENDCG
	}

	Fallback "Diffuse"

}
