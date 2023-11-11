struct appdata
{
	float4 vertex : POSITION;
	float2 uv : TEXCOORD0;

	UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct v2f
{
	float2 uv : TEXCOORD0;
	float4 vertex : SV_POSITION;

	UNITY_VERTEX_OUTPUT_STEREO
};

sampler2D _MainTex;
float4 _MainTex_ST;

v2f vert(appdata v)
{
	v2f o;

	UNITY_SETUP_INSTANCE_ID(v);
	UNITY_INITIALIZE_OUTPUT(v2f, o);
	UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

	#if defined(USING_STEREO_MATRICES)
		float3 cameraPos = lerp(unity_StereoWorldSpaceCameraPos[0], unity_StereoWorldSpaceCameraPos[1], 0.5);
	#else
		float3 cameraPos = _WorldSpaceCameraPos;
	#endif

	float3 forward = normalize(cameraPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz);
	float3 right = cross(forward, float3(0, 1, 0));
	float yawCamera = atan2(right.x, forward.x) - UNITY_PI / 2;//Add 90 for quads to face towards camera
	float s, c;
	sincos(yawCamera, s, c);

	float3x3 transposed = transpose((float3x3)unity_ObjectToWorld);
	float3 scale = float3(length(transposed[0]), length(transposed[1]), length(transposed[2]));

	float3x3 newBasis = float3x3(
		float3(c * scale.x, 0, s * scale.z),
		float3(0, scale.y, 0),
		float3(-s * scale.x, 0, c * scale.z)
		);//Rotate yaw to point towards camera, and scale by transform.scale

	float4x4 objectToWorld = unity_ObjectToWorld;
	//Overwrite basis vectors so the object rotation isn't taken into account
	objectToWorld[0].xyz = newBasis[0];
	objectToWorld[1].xyz = newBasis[1];
	objectToWorld[2].xyz = newBasis[2];
	//Now just normal MVP multiply, but with the new objectToWorld injected in place of matrix M
	o.vertex = mul(UNITY_MATRIX_VP, mul(objectToWorld, v.vertex));
	o.uv = TRANSFORM_TEX(v.uv, _MainTex);
	return o;
}
