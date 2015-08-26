//-----------------------------------------------------------------------------
// This effect combines the results of the g buffer and the light accumulation render target to create the final image.
//-----------------------------------------------------------------------------

// Effect parameters.
texture colorMap;
texture lightMap;
texture normalMap;

sampler colorSampler = sampler_state
{
	Texture = <colorMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

 
sampler normalSampler = sampler_state
{
	Texture = <normalMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

sampler lightSampler = sampler_state
{
	Texture = <lightMap>;

	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;

	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

// Half of a pixel for aligning pixels to texels.
float2 halfPixel;


struct VertexShaderInput
{
	float3	Position	:	POSITION0;
	float2	texCoords	:	TEXCOORD0;
};

struct VertexShaderOutput
{
	float4	Position	:	POSITION0;
	float2	TexCoord	:	TEXCOORD0;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
	VertexShaderOutput output;

	output.Position			=	float4(input.Position,1);

	// Align pixels to texels.
	output.TexCoord			=	input.texCoords - halfPixel;

	return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	// Get the diffuse color from the color map.
	float3 diffuseColor		=	tex2D(colorSampler, input.TexCoord).rgb;

	if (tex2D(colorSampler, input.TexCoord).a == 0.0f && tex2D(normalSampler, input.TexCoord).a == 0.0f)
	{
		clip(-1);
	}

	// Get the light from the light map (diffuse in rgb, specular in alpha).
	float4 light			=	tex2D(lightSampler,input.TexCoord);
	float3 diffuseLight		=	light.rgb;
	float specularLight		=	light.a;

	// Return final color as DiffuseColor * DiffuseLight + SpecularLight.
	return float4(diffuseColor * (diffuseLight + specularLight), 1);
}

technique Combine
{
	pass Pass1
	{
		VertexShader	=	compile	vs_3_0	VertexShaderFunction();
		PixelShader		=	compile	ps_3_0	PixelShaderFunction();
	}
}