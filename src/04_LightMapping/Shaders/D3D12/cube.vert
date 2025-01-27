#define MAX_INSTANCES 8

cbuffer UniformData : register(b0)
{
	float4x4 view;
	float4x4 proj;
	float4x4 world[MAX_INSTANCES];
};

struct VSInput
{
    float4 Position : POSITION;
    float4 Normal : NORMAL;
    float2 TexCoord : TEXCOORD;
};

struct VSOutput {
	float4 Normal	: NORMAL;
	float4 FragPos	: POSITION;
	float4 Position : SV_POSITION;
    float2 TexCoord : TEXCOORD;
};

 float4x4 inverse(float4x4 input)
 {
     #define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
     //determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))
     
     float4x4 cofactors = float4x4(
          minor(_22_23_24, _32_33_34, _42_43_44), 
         -minor(_21_23_24, _31_33_34, _41_43_44),
          minor(_21_22_24, _31_32_34, _41_42_44),
         -minor(_21_22_23, _31_32_33, _41_42_43),
         
         -minor(_12_13_14, _32_33_34, _42_43_44),
          minor(_11_13_14, _31_33_34, _41_43_44),
         -minor(_11_12_14, _31_32_34, _41_42_44),
          minor(_11_12_13, _31_32_33, _41_42_43),
         
          minor(_12_13_14, _22_23_24, _42_43_44),
         -minor(_11_13_14, _21_23_24, _41_43_44),
          minor(_11_12_14, _21_22_24, _41_42_44),
         -minor(_11_12_13, _21_22_23, _41_42_43),
         
         -minor(_12_13_14, _22_23_24, _32_33_34),
          minor(_11_13_14, _21_23_24, _31_33_34),
         -minor(_11_12_14, _21_22_24, _31_32_34),
          minor(_11_12_13, _21_22_23, _31_32_33)
     );
     #undef minor
     return transpose(cofactors) / determinant(input);
 }

VSOutput main(VSInput input, uint InstanceID : SV_InstanceID)
{
	VSOutput result;
	result.Normal = mul(transpose(inverse(world[InstanceID])), input.Normal);  
	result.FragPos = mul(world[InstanceID], input.Position);
	result.Position = mul(proj, mul(view, result.FragPos));
	result.TexCoord = input.TexCoord;
	return result;
}