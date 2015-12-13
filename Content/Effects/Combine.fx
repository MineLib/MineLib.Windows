float4	SunColor;
float	TimeOfDay;

// Half of a pixel for aligning pixels to texels.
float2	HalfPixel;

texture	ColorMap;
sampler colorSampler = sampler_state
{
	Texture		=	<ColorMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	CLAMP;
	AddressV	=	CLAMP;
};

texture	NormalMap;
sampler normalSampler = sampler_state
{
	Texture		=	<NormalMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	CLAMP;
	AddressV	=	CLAMP;
};

texture	LocalLightMap;
sampler localLightSampler = sampler_state
{
	Texture		=	<LocalLightMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	CLAMP;
	AddressV	=	CLAMP;
};

texture	SkyLightMap;
sampler skyLightSampler = sampler_state
{
	Texture		=	<SkyLightMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	CLAMP;
	AddressV	=	CLAMP;
};

struct VertexShaderInput
{
	float3	Position	:	POSITION0;
	float2	TexCoord	:	TEXCOORD0;
};

struct VertexShaderOutput
{
	float4	Position	:	POSITION0;
	float2	TexCoord	:	TEXCOORD0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
	VertexShaderOutput output;

	output.Position						=	float4(input.Position,1);

	// Align pixels to texels.
	output.TexCoord						=	input.TexCoord - HalfPixel;

	return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	// Get the diffuse color from the color map.
	float3 diffuseColor					=	tex2D(colorSampler, input.TexCoord).rgb;

	if (tex2D(colorSampler, input.TexCoord).a == 0.0f && tex2D(normalSampler, input.TexCoord).a == 0.0f && tex2D(skyLightSampler, input.TexCoord).a == 0.0f)
	{
		clip(-1);
	}
	
	// Get the light from the light map (diffuse in rgb, specular in alpha).
	float4 localLight					=	tex2D(localLightSampler, input.TexCoord);
	float3 diffuseLocalLight			=	localLight.rgb;
	float specularLocalLight			=	localLight.a;
	
	float4 sColor						=	SunColor;
	if(TimeOfDay <= 12)
	{
		sColor							*=	TimeOfDay / 12;    
	}
	else
	{
		sColor							*=	(TimeOfDay - 24) / -12;    
	}
	float4 skyLight						=	tex2D(skyLightSampler, input.TexCoord);
	if(skyLight.r > 0.0f)
	{
		float3 diffuseColorSkyLight		=	diffuseColor * sColor.rgb * skyLight.r;
		float3 diffuseColorLocalLight	=	diffuseColor * (diffuseLocalLight + specularLocalLight);
		return float4(diffuseColorSkyLight + diffuseColorLocalLight, 1);
	}
	else
	{
		return float4(diffuseColor.rgb * (diffuseLocalLight + specularLocalLight), 1);
	}
}

technique Combine
{
	pass Pass1
	{
		VertexShader	=	compile	vs_3_0	VertexShaderFunction();
		PixelShader		=	compile	ps_3_0	PixelShaderFunction();
	}
}