Shader "Toocanzs/Vertical Billboard/Cutout"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Cutout("Cutout Threshold", Range(0,1)) = 0
	}
	SubShader
	{
		Tags
		{
			"RenderType" = "Opaque"
			"DisableBatching" = "True"
		}
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			#include "VerticalBillboard.cginc"
			float _Cutout;
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);
				clip(col.a - _Cutout);
				return col;
			}
			ENDCG
		}
	}
}
