Shader "Custom/DepthRenderSphere2" {

	Properties {
		_MainTex ("Texture", 2D) = "white" {}
		//_DepthTex ("Texture", 2D) = "white" {}
		_Size ("Size", Float) = 1
		_Depth ("Depth", Float) = 1
		_Alpha ("Alpha", Float) = 1
	}

	SubShader {
		Tags { "RenderType"="Transparent" "Queue"="Transparent +1" }
		LOD 100
		//Cull Off
		Cull Back
		Blend One OneMinusSrcAlpha
		ZWrite Off

		Pass {
			CGPROGRAM
			#pragma vertex VertexProgram
			#pragma fragment FragmentProgram
			
			#include "UnityCG.cginc"

			struct VertexInput {
				float4 position : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
			};

			struct VertexToFragment {
				float4 position : SV_POSITION;
				float2 uv : TEXCOORD0;
				float sliceDepth : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
			};

			float4    _Undistortion;
			float     _MaxRadSq;
			float     _NearClip;
			float4x4  _RealProjection;
			float4x4  _FixProjection;

			// Convert point from world space to undistorted camera space.
			float4 undistort(float4 pos) {
			  // Go to camera space.
			  pos = mul(UNITY_MATRIX_MV, pos);
			  if (pos.z <= -_NearClip) {  // Reminder: Forward is -Z.
			    // Undistort the point's coordinates in XY.
			    float r2 = clamp(dot(pos.xy, pos.xy) / (pos.z*pos.z), 0, _MaxRadSq);
			    pos.xy *= 1 + (_Undistortion.x + _Undistortion.y*r2)*r2;
			  }
			  return pos;
			}

			// Multiply by no-lens projection matrix after undistortion.
			float4 undistortVertex(float4 pos) {
			  return mul(_RealProjection, undistort(pos));
			}

			// Surface shader hides away the MVP multiplication, so we have
			// to multiply by _FixProjection = inverse(MVP)*_RealProjection.
			float4 undistortSurface(float4 pos) {
			  return mul(_FixProjection, undistort(pos));
			}

			float4 undistortWorld(float4 pos) {
			  // Go to camera space.
			  pos = mul(UNITY_MATRIX_V, pos);
			  if (pos.z <= -_NearClip) {  // Reminder: Forward is -Z.
			    // Undistort the point's coordinates in XY.
			    float r2 = clamp(dot(pos.xy, pos.xy) / (pos.z*pos.z), 0, _MaxRadSq);
			    pos.xy *= 1 + (_Undistortion.x + _Undistortion.y*r2)*r2;
			  }
			  return pos;
			}

			float4 undistortVertexWorld(float4 pos) {
			  return mul(_RealProjection, undistortWorld(pos));
			}

			// Calculates UV offset for parallax bump mapping
			//inline float2 ParallaxOffset(half h, half height, half3 viewDir) {
				//h = h * height - height/2.0;
				//float3 v = normalize(viewDir);
				//v.z += 0.42;
				//return h * (v.xy / v.z);
			//}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			//sampler2D _DepthTex;
			//float4 _AlphaTex_ST;
			float _Depth;
			float _Size;
			float _Alpha;

			VertexToFragment VertexProgram(VertexInput v) {
				VertexToFragment output;


				v.position.xyz *= (1-.2*_Depth  * v.uv2.x);

				// http://answers.unity3d.com/questions/1190649/basic-water-shader-error-message.html
				//float4 worldPosition = mul(unity_ObjectToWorld, v.position);
				float4 worldPosition = mul(unity_ObjectToWorld, v.position);
				//worldPosition.xyz += worldSpritePosition.xyz;

				//#if defined(GVR_DISTORTION)
				output.position = undistortVertexWorld(worldPosition);
				//#else
				//output.position = mul(UNITY_MATRIX_VP, worldPosition);
				//#endif

				output.uv = TRANSFORM_TEX(v.uv, _MainTex);

				output.uv3 = output.uv * float2(1, 0.5);
				output.uv = output.uv * float2(1, 0.5) + float2(0, 0.5);
				output.sliceDepth = v.uv2.x;
				return output;
			}

			float4 FragmentProgram(VertexToFragment i) : SV_Target {
				
				//float2 offset = ParallaxOffset (h, _Parallax, IN.viewDir);

				float3 col = tex2D(_MainTex, i.uv);
				float depth = tex2D(_MainTex, i.uv3).r;

				float depthFadeScale = depth * depth;
				float alpha = _Alpha * .5 * saturate((1.+ 4 * depthFadeScale) * ((.2)-abs(i.sliceDepth - depth )));
				//alpha = .1 * saturate(2. * (.5-abs(i.uv2.x - depth)));
				//alpha = saturate(10. * (.1-abs(i.uv2.x - depth)));

				float2 dist = 2 * abs(i.uv - 0.5);
				float len = saturate(_Size-dist.x * dist.x - dist.y * dist.y);   //length(dist));
				return float4( alpha * len * col,alpha * len);
			}
			ENDCG
		}
	}

}
