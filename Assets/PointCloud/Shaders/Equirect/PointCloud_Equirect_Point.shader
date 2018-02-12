// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "PointCloud/Equirect/Point" {

    Properties {
		_MainTex("Diffuse RGBA", 2D) = "gray" {}
		_DepthTex("Depth", 2D) = "gray" {}
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
		_Displacement("Displacement", float) = 1.0
	}

	SubShader {
        Pass {
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
            #include "UnityCG.cginc"

			struct VertexInput {
				float4 v : POSITION;
				float4 color: COLOR;
				float3 normal: NORMAL;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			sampler2D _DepthTex;
			float4 _Color;
			float _Displacement;

			#define PI 3.141592653589793

			inline float2 RadialCoords(float3 a_coords) {
				float3 a_coords_n = normalize(a_coords);
				float lon = atan2(a_coords_n.z, a_coords_n.x);
				float lat = acos(a_coords_n.y);
				float2 sphereCoords = float2(lon, lat) * (1.0 / PI);
				return float2(sphereCoords.x * 0.5 + 0.5, 1 - sphereCoords.y);
			}

			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				float2 equiUV = RadialCoords(v.normal);
                float4 tex1 = tex2Dlod(_MainTex, float4(equiUV, 0, 0));
                float3 tex2 = tex2Dlod(_DepthTex, float4(equiUV, 0, 0));
                float4 p = float4(v.normal + tex2.xyz * _Displacement, 1);
				o.pos = UnityObjectToClipPos(v.v * p);
                o.col = tex1;
				o.normal = o.pos;
				return o;
			}

			float4 frag(VertexOutput o) : COLOR {
                return float4(o.normal,1) * _Color;
			}

			ENDCG
		}
	}

}