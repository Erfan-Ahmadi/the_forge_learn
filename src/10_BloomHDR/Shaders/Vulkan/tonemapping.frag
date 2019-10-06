#version 450 core

#define TEX_DIM 256

layout(location = 0) in vec2 UV;

layout (binding = 1) uniform sampler								uSampler0;
layout (UPDATE_FREQ_PER_FRAME,  binding = 2) uniform texture2D		HdrTexture;
layout (UPDATE_FREQ_PER_FRAME,  binding = 3) uniform texture2D		BloomTexture;

layout(UPDATE_FREQ_PER_FRAME, set = 0, binding = 0) uniform ToneMappingData
{
	float inExposure;
	float inGamma;
	float bloomLevel;
	bool tonemap;
};

layout(location = 0) out vec4 outColor;

void main()
{    
	outColor = texture(sampler2D(BloomTexture, uSampler0), UV);
	return;

	// Vertical Blur
	float weight[5];
	weight[0] = 0.227027;
	weight[1] = 0.1945946;
	weight[2] = 0.1216216;
	weight[3] = 0.054054;
	weight[4] = 0.016216;
	
	vec2 tex_offset = vec2(1.0f / TEX_DIM);
	vec3 hblur = texture(sampler2D(BloomTexture, uSampler0), UV).rgb * weight[0];

	for(int i = 0; i < 5; ++i)
	{
		hblur += texture(sampler2D(BloomTexture, uSampler0), UV + vec2(tex_offset.x * i, 0.0)).rgb * weight[i] * 1.5f;
		hblur += texture(sampler2D(BloomTexture, uSampler0), UV - vec2(tex_offset.x * i, 0.0)).rgb * weight[i] * 1.5f;
	}

	const float gamma = inGamma;
  
	vec4 hdrColor = texture(sampler2D(HdrTexture, uSampler0), UV) + bloomLevel * vec4(hblur, 1.0f);
	vec3 mapped;

	if(tonemap)
	{
		// reinhard tone mapping
		mapped = hdrColor.xyz / (hdrColor.xyz + 1.0);
	}
	else
	{
		// Exposure tone mapping
		mapped = 1.0f - exp2(-hdrColor.xyz * inExposure);
	}
	
    // Gamma correction 
    mapped = pow(mapped, vec3(1.0 / gamma));

    outColor = vec4(mapped, hdrColor.a);
}