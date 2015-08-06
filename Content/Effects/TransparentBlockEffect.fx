float myDamping = 0.4f;  
float myPixelWidth;  
float myPixelHeight;  
 
Texture myBufferOne;  
   
sampler samplerBufferOne = sampler_state {   
texture = <myBufferOne>;  
 magfilter = NONE;   
 minfilter = NONE;   
 mipfilter = NONE;   
 AddressU = clamp;   
 AddressV = clamp;  
};  
 
Texture myBufferTwo;  
   
sampler samplerBufferTwo = sampler_state {   
texture = <myBufferTwo>;  
 magfilter = NONE;   
 minfilter = NONE;   
 mipfilter = NONE;   
 AddressU = clamp;   
 AddressV = clamp;  
};  
 
 struct VS_INPUT   
 {   
    float4	Position	:	SV_POSITION;  
    float2	Texcoord	:	TEXCOORD0;  
 };  
   
 VS_INPUT VertexShaderFunction(VS_INPUT Input)  
 {   
    VS_INPUT Output;  
    Output.Position = Input.Position;  
    Output.Texcoord = Input.Texcoord;  
    return Output;   
 }   
       
 float4 PixelShaderFunction(VS_INPUT Input) : COLOR0  
 {                      
    float bufferOneLeft = tex2D(samplerBufferOne, float2(Input.Texcoord.x-myPixelWidth, Input.Texcoord.y)).r;  
    float bufferOneRight = tex2D(samplerBufferOne, float2(Input.Texcoord.x+myPixelWidth, Input.Texcoord.y)).r;  
    float bufferOneUp = tex2D(samplerBufferOne, float2(Input.Texcoord.x, Input.Texcoord.y-myPixelHeight)).r;  
    float bufferOneDown = tex2D(samplerBufferOne, float2(Input.Texcoord.x, Input.Texcoord.y+myPixelHeight)).r;  
      
    float bufferTwo = tex2D(samplerBufferTwo, Input.Texcoord).r;  
      
    bufferTwo = (bufferOneLeft + bufferOneRight + bufferOneDown + bufferOneUp) / 2 - bufferTwo;  
    bufferTwo *= myDamping;  
     
    if (Input.Texcoord.x < myPixelWidth || Input.Texcoord.y < myPixelHeight || Input.Texcoord.x > (1.0f - myPixelWidth) || Input.Texcoord.y > (1.0f - myPixelHeight))  
    {  
        return 0;  
    }  
    else 
    {  
        return float4(bufferTwo, bufferTwo, bufferTwo, 1);  
    }  
 }   
        
 technique WaterTexture   
 {  
    pass P0   
    {  
        VertexShader = compile vs_4_0_level_9_1 VertexShaderFunction();  
        PixelShader = compile ps_4_0_level_9_1 PixelShaderFunction();   
    }   
 }  