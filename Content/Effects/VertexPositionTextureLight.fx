float4x4	World;
float4x4	View;
float4x4	Projection;

float		TimeOfDay;

float4		SunColor;       


texture		Texture;
sampler textureSampler = sampler_state
{
    Texture		=	<Texture>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

texture		SpecularMap;
sampler specularSampler = sampler_state
{
    Texture		=	<SpecularMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

texture		NormalMap;
sampler normalSampler = sampler_state
{
    Texture		=	<NormalMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

struct VertexShaderInput
{
	float4		Position	:	POSITION0;
	float3		Normal		:	NORMAL0;
	float2		TexCoord	:	TEXCOORD0;
	float		SunLight	:	COLOR0;
	float3		Binormal	:	BINORMAL0;
	float3		Tangent		:	TANGENT0;
};

struct VertexShaderOutput
{
	float4		Position	:	POSITION0;
	float4		Color		:	COLOR0;
	float2		TexCoord	:	TEXCOORD0;
	float		Depth		:	TEXCOORD1;
	float3x3	TangentW	:	TEXCOORD2;
};

struct PixelShaderOutput
{
	float4		Color		:	COLOR0;
	float4		Normals		:	COLOR1;
	float4		Depth		:	COLOR2;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    //float4 worldPosition		=	mul(float4(input.Position.xyz,1), World);
	float4 worldPosition		=	mul(input.Position, World);
    float4 viewPosition			=	mul(worldPosition, View);
    output.Position				=	mul(viewPosition, Projection);
	
	float4 sColor				=	SunColor;
	if(TimeOfDay <= 12)
	{
		sColor					*=	TimeOfDay / 12;    
	}
	else
	{
		sColor					*=	(TimeOfDay - 24) / -12;    
	}
	//output.Color				=	(sColor * input.SunLight);
	output.Color.a				= 	sColor.a;
	output.Color				=	sColor;

    output.TexCoord				=	input.TexCoord;
	
	// Calculate tangent space to world space matrix using the world space tangent,
	// binormal, and normal as basis vectors.
	output.TangentW[0]			=	mul(input.Tangent, World);
	output.TangentW[1]			=	mul(input.Binormal, World);
	output.TangentW[2]			=	mul(input.Normal, World);
	
	output.Depth.x				=	viewPosition.z;
	
    return output;
}

PixelShaderOutput PixelShaderFunction(VertexShaderOutput input)
{
	PixelShaderOutput output;

	float4 specularAttributes	=	tex2D(specularSampler, input.TexCoord);
	
    output.Color.rgb			=	tex2D(textureSampler, input.TexCoord).rgb * input.Color;
	//output.Color.rgb			=	tex2D(textureSampler, input.TexCoord).rgb;
	//output.Color.a				=	specularAttributes.r;
	output.Color.a				=	1.0f;

	// Normals.
	float3 normalFromMap		=	tex2D(normalSampler, input.TexCoord);

	// Transform to [-1,1].
	normalFromMap				=	2.0f * normalFromMap - 1.0f;

	// Transform into world space.
	normalFromMap				=	mul(normalFromMap, input.TangentW);

	// Normalize the result.
	normalFromMap				=	normalize(normalFromMap);

	// Output the normal, in [0,1] space.
	output.Normals.rgb			=	0.5f * (normalFromMap + 1.0f);
	//output.Normals.rgb		=	0.5f * (normalize(input.TangentW[2]) + 1.0f);
	output.Normals.a			=	specularAttributes.a; // Specular power.
	
	
	
	// Depth.
	// Negate and divide by distance to far-clip plane, (so that depth is in range [0,1]).
	// This is for right-handed coordinate system.
	output.Depth.r				=	-input.Depth.x;
	output.Depth.g				=	0.0f; // 1.0f if the pixel will be lighted in the lightning pass, 0.0f otherwise.
	output.Depth.ba				=	0.0f;

    return output;
}
technique Technique1
{
    pass Pass1
    {
        VertexShader	=	compile	vs_3_0	VertexShaderFunction();
        PixelShader		=	compile	ps_3_0	PixelShaderFunction();
    }
}