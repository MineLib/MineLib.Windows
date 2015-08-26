float4x4	World;
float4x4	View;
float4x4	Projection;

float3		CameraPosition;

float		TimeOfDay;

float4		SunColor;    


float4 AmbientColor = float4(1, 1, 1, 1);
float AmbientIntensity = 0.1;

float4x4 WorldInverseTranspose;

float3 DiffuseLightDirection = float3(1, 0, 0);
float4 DiffuseColor = float4(1, 1, 1, 1);
float DiffuseIntensity = 1.0;

float Shininess = 200;
float4 SpecularColor = float4(1, 1, 1, 1);    
float SpecularIntensity = 1;
float3 ViewVector = float3(1, 0, 0);


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

float BumpConstant = 1;
texture NormalMap;
sampler normalSampler = sampler_state
{
    Texture		=	<NormalMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

texture SpecularMap;
sampler specularSampler = sampler_state
{
    Texture		=	<SpecularMap>;
	
	MipFilter	=	POINT;
	MinFilter	=	POINT;
	MagFilter	=	POINT;
	
	AddressU	=	WRAP;
	AddressV	=	WRAP;
};

struct VertexShaderInput
{
	float4	Position	:	POSITION0;
	float3	Normal		:	NORMAL0;
	float3	Tangent		:	TANGENT0;
	float3	Binormal	:	BINORMAL0;
	float2	TexCoord	:	TEXCOORD0;
	float	SunLight	:	COLOR0;
};

struct VertexShaderOutput
{
	//float4		Position		:	POSITION0;
	//float4		Color			:	COLOR0;
	//float2		TexCoord		:	TEXCOORD0;
	//float2		Depth			:	TEXCOORD1;
	//float3x3	tangentToWorld	:	TEXCOORD2;
	
	float4		Position		:	POSITION0;
	//float4		Color			:	COLOR0;
	float2		TexCoord		:	TEXCOORD0;
	float3		Normal			:	TEXCOORD1;
	float3		Tangent			:	TEXCOORD2;
	float3		Binormal		:	TEXCOORD3;
};

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
    VertexShaderOutput output;

    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);
    output.Position = mul(viewPosition, Projection);

	//float4 sColor			=	SunColor;
	//if(TimeOfDay <= 12)
	//{
	//	sColor				*=	TimeOfDay / 12;    
	//}
	//else
	//{
	//	sColor				*=	(TimeOfDay - 24) / -12;    
	//}
	
	//output.Color.rgb		=	(sColor * input.SunLight);
	//output.Color.a			= 	1.0f;
	
    output.Normal = normalize(mul(input.Normal, WorldInverseTranspose));
    output.Tangent = normalize(mul(input.Tangent, WorldInverseTranspose));
    output.Binormal = normalize(mul(input.Binormal, WorldInverseTranspose));

    output.TexCoord = input.TexCoord;
    return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
    // Calculate the normal, including the information in the bump map
    float3 bump = BumpConstant * (tex2D(normalSampler, input.TexCoord) - (0.5, 0.5, 0.5));
    float3 bumpNormal = input.Normal + (bump.x * input.Tangent + bump.y * input.Binormal);
    bumpNormal = normalize(bumpNormal);

    // Calculate the diffuse light component with the bump map normal
    float diffuseIntensity = dot(normalize(DiffuseLightDirection), bumpNormal);
    if(diffuseIntensity < 0)
        diffuseIntensity = 0;

    // Calculate the specular light component with the bump map normal
    float3 light = normalize(DiffuseLightDirection);
    float3 r = normalize(2 * dot(light, bumpNormal) * bumpNormal - light);
    float3 v = normalize(mul(normalize(ViewVector), World));
    float dotProduct = dot(r, v);

    float4 specular = SpecularIntensity * SpecularColor * max(pow(dotProduct, Shininess), 0) * diffuseIntensity;

    // Calculate the texture color
    float4 textureColor = tex2D(textureSampler, input.TexCoord);
	//textureColor.rgb			=	textureColor.rgb * input.Color.rgb;
    textureColor.a = 1;

    // Combine all of these values into one (including the ambient light)
    return saturate(textureColor * (diffuseIntensity) + AmbientColor * AmbientIntensity + specular);
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 VertexShaderFunction();
        PixelShader = compile ps_2_0 PixelShaderFunction();
    }
}
