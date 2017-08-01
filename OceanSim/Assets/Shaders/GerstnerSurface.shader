﻿Shader "Custom/GerstnerSurface" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf Standard vertex:vert addshadow

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;

		struct Input {
			float2 uv_MainTex;
			float3 worldPos;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		// Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
		// See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
		// #pragma instancing_options assumeuniformscaling
		UNITY_INSTANCING_CBUFFER_START(Props)
		// put more per-instance properties here
		UNITY_INSTANCING_CBUFFER_END

		int _WaveCount;
		float _WaveTime;
		float _Amplitude;
		float _DirectionX[20];
		float _DirectionZ[20];
		float _Q;
		float _Frequency;
		float _PhaseConstant;

		struct WaveResult {
			float3 pos;
			float3 normal;
			float2 uv;
		};

		WaveResult getWaveResult(float3 pos) {
			float3 posSum = float3(pos.x, 0.0, pos.z);
			float3 normalSum = float3(0.0, 0.0, 0.0);

			for (int i = 0; i < _WaveCount; i++) {
				float2 direction = float2(_DirectionX[i], _DirectionZ[i]);
				float constant = dot(direction, float2(pos.x, pos.z)) * _Frequency + _WaveTime * _PhaseConstant;
				float wa = _Frequency * _Amplitude;
				float s = sin(constant);
				float c = cos(constant);

				float3 iWavePos =
					float3(
						_Q * _Amplitude * direction.x * c,
						_Amplitude * s,
						_Q * _Amplitude * direction.y * c
						);

				float3 iNormal = 
					float3(
						direction.x * wa * c, 
						_Q * wa * s, 
						direction.y * wa * c
						);

				posSum += iWavePos;
				normalSum += iNormal;

			}


			WaveResult result;
			result.pos = posSum;// +float3(pos.x, 0.0, pos.z);
			result.normal = float3(-normalSum.x, 1 - normalSum.y, -normalSum.z);


			return result;
		}

		void vert(inout appdata_full IN) {
			//Get the global position of the vertex
			float4 worldPos = mul(unity_ObjectToWorld, IN.vertex);

			//Manipulate the position

			WaveResult result = getWaveResult(worldPos.xyz);

			float3 withWave = result.pos;

			//Convert the position back to local
			float4 localPos = mul(unity_WorldToObject, float4(withWave, worldPos.w));

			//Assign the modified vertex
			IN.vertex = localPos;
			IN.normal = result.normal;
			//World tiling
			IN.texcoord = float4(-worldPos.z, worldPos.x, 0.0, 0.0) / 20;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) {
			// Albedo comes from a texture tinted by color


			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			o.Albedo = c.rgb;
			// Metallic and smoothness come from slider variables
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}