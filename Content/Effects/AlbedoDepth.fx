struct VertexShaderInput
{
	float3 Position : POSITION0;
};
 
struct VertexShaderOutput
{
	float4 Position : POSITION0;
};
 
VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
	VertexShaderOutput output;
	output.Position = float4(input.Position,1);
	return output;
}
 
struct PixelShaderOutput
{
	float4	Color	:	COLOR0;
	float4	Depth	:	COLOR1;
};
PixelShaderOutput PixelShaderFunction(VertexShaderOutput input)
{
	PixelShaderOutput output;
	
	//black color
	output.Color = float4(0,0,0,0);
	
	//max depth
	output.Depth = 0.0f;
	return output;
}
technique ClearGBuffer
{
	pass Pass1
	{
		VertexShader	=	compile	vs_2_0	VertexShaderFunction();
		PixelShader		=	compile	ps_2_0	PixelShaderFunction();
	}
}