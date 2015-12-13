float4x4	World;
float4x4	View;
float4x4	Projection;

float		FarPlane;

bool		IsLightned;

texture		ColorMap;
sampler	textureSampler	=	sampler_state
{
    Texture		=	<ColorMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

texture		NormalMap;
sampler	normalSampler	=	sampler_state
{
    Texture		=	<NormalMap>;
	
	MipFilter	=	LINEAR;
	MinFilter	=	LINEAR;
	MagFilter	=	LINEAR;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

texture		TerrainMap;
sampler	terrainSampler	=	sampler_state
{
    Texture		=	<TerrainMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

struct	VertexShaderInput
{
	float4		Position	:	POSITION0;
	float3		Normal		:	NORMAL0;
	float2		TexCoord	:	TEXCOORD0;
	float3		Binormal	:	BINORMAL0;
	float3		Tangent		:	TANGENT0;
	float		SkyLight	:	COLOR0;
};

struct	VertexShaderOutput
{
	float4		Position	:	POSITION0;
	float2		TexCoord	:	TEXCOORD0;
	float		Depth		:	TEXCOORD1;
	float3x3	TangentW	:	TEXCOORD2;
	float		SkyLight	:	COLOR0;
};

struct	PixelShaderOutput
{
	float4		Color		:	COLOR0;
	float4		Normals		:	COLOR1;
	float4		Depth		:	COLOR2;
	float4		SkyLight	:	COLOR3;
};

VertexShaderOutput	VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

	float4 worldPosition		=	mul(input.Position, World);
    float4 viewPosition			=	mul(worldPosition, View);
	
    output.Position				=	mul(viewPosition, Projection);
	
    output.TexCoord				=	input.TexCoord;
	
	output.Depth.x				=	viewPosition.z;

	output.TangentW[0]			=	mul(input.Tangent, World);
	output.TangentW[1]			=	mul(input.Binormal, World);
	output.TangentW[2]			=	mul(input.Normal, World);
	
	output.SkyLight				=	input.SkyLight;
	
    return output;
}

PixelShaderOutput	PixelShaderFunction(VertexShaderOutput input)
{
	PixelShaderOutput output;

	output.Color				=	tex2D(textureSampler, input.TexCoord);


	float3 normalFromMap		=	tex2D(normalSampler, input.TexCoord).rgb;

	// Transform to [-1,1].
	// Transform into world space.
	// Normalize the result.
	normalFromMap				=	2.0f * normalFromMap - 1.0f;
	normalFromMap				=	mul(normalFromMap, input.TangentW);
	normalFromMap				=	normalize(normalFromMap);

	// Output the normal, in [0,1] space.
	output.Normals				=	float4(0.5f * (normalFromMap + 1.0f), 1);	
	
	// Negate and divide by distance to far-clip plane, (so that depth is in range [0,1]).
	// This is for right-handed coordinate system.
//	float depth					=	-input.Depth.x / FarPlane;
	float depth					=	-input.Depth.x;
	output.Depth.r				=	depth;
	
	float isLit					=	IsLightned;
	output.Depth.g				=	isLit; // 1.0 if will be lightning pass, 0.0f otherwise.
	output.Depth.ba				=	0.0f;
	
	output.SkyLight				=	float4(input.SkyLight, 0, 0, 1);

    return output;
	
	
//	output.Color.rgb			=	saturate(output.Color + specularAttributes).rgb;
//	output.Color				=	tex2D(textureSampler, input.TexCoord);
//	output.Color.rgb			=	tex2D(textureSampler, input.TexCoord).rgb;
//	output.Color.a				=	specularAttributes.r; // Specular intensity.
	
//	output.Normals.rgb			=	0.5f * (normalFromMap + 1.0f);
//	output.Normals.rgb			=	0.5f * (normalize(input.tangentToWorld[2]) + 1.0f);
//	output.Normals.a			=	specularAttributes.a; // Specular power.
}
technique Technique1
{
    pass Pass1
    {
        VertexShader	=	compile	vs_3_0	VertexShaderFunction();
        PixelShader		=	compile	ps_3_0	PixelShaderFunction();
    }
}