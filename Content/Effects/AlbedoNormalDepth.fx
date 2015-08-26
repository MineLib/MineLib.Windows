struct PSO
{
	float4	Albedo		:	COLOR0;
	float4	Normals		:	COLOR1;
	float4	Depth		:	COLOR2;
};

float4 VS(float3 Position : POSITION0) : POSITION0
{
	return float4(Position, 1);
}

//Normal Encoding Function
float3 encode(float3 n)
{
	n = normalize(n);
	n.xyz = 0.5f * (n.xyz + 1.0f);
	return n;
}

PSO PS()
{
	PSO output;
	
	//Clear Albedo to Transperant Black
	output.Albedo = 0.0f;
	
	//Clear Normals to 0(encoded value is 0.5 but can't use normalize on 0, compile error)
	output.Normals.xyz = 0.5f;
	output.Normals.w = 0.0f;
	
	//Clear Depth to 1.0f
	output.Depth = 1.0f;
	
	//Return
	return output;
}

technique Technique1
{
	pass Pass1
	{
		VertexShader	=	compile	vs_2_0	VS();
		PixelShader		=	compile	ps_2_0	PS();
	}
}