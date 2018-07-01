// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/

Shader "PointCloud/Equirect/Surface" {

    Properties {
		_MainTex("Diffuse (RGB) Alpha (A)", 2D) = "gray" {}
		_DispTex("Displacement Texture", 2D) = "gray" {}
		_Displacement("Displacement", float) = 0.1
		_Color("Color", Color) = (1.0, 1.0, 1.0, 1.0)
    }

	SubShader {
		Pass {
			LOD 200

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct VertexInput {
				float4 v : POSITION;
				//float4 color: COLOR;
				float3 normal: NORMAL;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				//float4 col : COLOR;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _Color;

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
				o.pos = UnityObjectToClipPos(v.v);
				//o.col = v.color;
				o.normal = v.normal;
				return o;
			}

			float4 frag(VertexOutput o) : COLOR {
				float2 equiUV = RadialCoords(o.normal);
				return tex2D(_MainTex, equiUV) * _Color;
			}

			ENDCG
		}
	}

}