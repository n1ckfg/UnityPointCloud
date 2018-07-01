// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Custom/vertexShader_program" {
 
     Properties {
         _MainTex ("Base (RGB)", 2D) = "white" {}
         _Amount ("Height", Float) = 1.0 //this will be incremented in script
         _xPos ("xPos", float) = 5.0 //just to test, these can be filled from script with desired values.
         _zPos ("zPos", float) = 3.0 //It might be wise to optimise this to a float2
     }

     SubShader {
         Tags { "RenderType"="Opaque" }
         LOD 200
         
         CGPROGRAM
         #pragma surface surf Lambert vertex:vert
 
         sampler2D _MainTex;
         float _Amount;
         float _xPos;
         float _zPos;
         
         struct Input {
             float2 uv_MainTex;
         };
         
          void vert(inout appdata_full v) {         
              float3 castToWorld = round(mul(unity_ObjectToWorld, v.vertex));
              if (castToWorld.x == 5.0 && castToWorld.y < _Amount && castToWorld.z == -1.0) {
                  v.vertex.y += _Amount;
              }
           }
 
         void surf(Input IN, inout SurfaceOutput o) {
             half4 c = tex2D(_MainTex, IN.uv_MainTex);
             o.Albedo = tex2D(_MainTex, IN.uv_MainTex).rgb;
             o.Alpha = c.a;
         }
         ENDCG
     } 

     FallBack "Diffuse"

 }

