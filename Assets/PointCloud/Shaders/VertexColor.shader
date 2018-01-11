// http://www.kamend.com/2014/05/rendering-a-point-cloud-inside-unity/
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/VertexColor" {

    Properties {
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
				float4 color: COLOR;
			};

			struct VertexOutput {
				float4 pos : SV_POSITION;
				float4 col : COLOR;
			};

			VertexOutput vert(VertexInput v) {
				VertexOutput o;
				o.pos = UnityObjectToClipPos(v.v);
				o.col = v.color;
				return o;
			}

            float4 _Color;

			float4 frag(VertexOutput o) : COLOR{
				return o.col * _Color;
			}
			ENDCG
		}
	}

}