 Shader "Tessellation/Standard Smooth" {
        Properties {
            _EdgeLength ("Edge length", Range(2,50)) = 5
            _Phong ("Phong Strengh", Range(0,1)) = 0.5
            _MainTex ("Base (RGB)", 2D) = "white" {}
            _MOS ("Metallic (R), Occlussion (G), Smoothness (B)", 2D) = "white" {}
            _Color ("Color", color) = (1,1,1,0)
            _Metallic ("Metallic", Range(0, 1)) = 0.5
            _Glossiness ("Smoothness", Range(0, 1)) = 0.5
        }
        SubShader {
            Tags { "RenderType"="Opaque" }
            LOD 300
            
            CGPROGRAM
            #pragma surface surf Standard addshadow fullforwardshadows vertex:dispNone tessellate:tessEdge tessphong:_Phong
            #include "FreeTess_Tessellator.cginc"

            struct appdata {
                float4 vertex : POSITION;
                float4 tangent : TANGENT;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
                float2 texcoord1 : TEXCOORD1;
                float2 texcoord2 : TEXCOORD2;
            };

            void dispNone (inout appdata v) { }

            float _Phong;
            float _EdgeLength;

            float4 tessEdge (appdata v0, appdata v1, appdata v2)
            {
                return FTSphereProjectionTessNoClip (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
            }

            struct Input {
                float2 uv_MainTex;
                float2 uv_MOS;
            };

            sampler2D _MainTex;
            sampler2D _MOS;
            sampler2D _NormalMap;
            fixed4 _Color;
            float _Metallic;
            float _Glossiness;

            void surf (Input IN, inout SurfaceOutputStandard o) {
                half4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
                half4 mos = tex2D (_MOS, IN.uv_MOS);

                o.Albedo = c.rgb;
                o.Metallic = mos.r * _Metallic;
                o.Smoothness = mos.b *_Glossiness;
                o.Occlusion = mos.g;
                o.Normal = UnpackNormal(tex2D(_NormalMap, IN.uv_MainTex));
            }
            ENDCG
        }
        FallBack "Standard"
    }