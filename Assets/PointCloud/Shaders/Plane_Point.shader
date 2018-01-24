// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Plane_Point" {

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

            VertexOutput vert(VertexInput v) {
				VertexOutput o;
                float3 tex1 = tex2Dlod(_MainTex, v.v);
                float3 tex2 = tex2Dlod(_DepthTex, v.v);
                float4 p = float4(tex2.xyz * _Displacement, 1);
				o.pos = UnityObjectToClipPos(v.v * p); 
				o.col = float4(tex1,1);
				o.normal = o.pos;//normal;
				return o;
			}

            float4 frag(VertexOutput o) : COLOR {
                return o.col * _Color;
            }

			ENDCG
		}
	}

}