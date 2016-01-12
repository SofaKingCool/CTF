
float3 color : flagColor;

// Copied from shader_tex_names
technique colors
{
    pass P0
    {
        MaterialAmbient = color;

        AmbientMaterialSource = Material;
        DiffuseMaterialSource = Material;
        EmissiveMaterialSource = Material;
        SpecularMaterialSource = Material;
        
        ColorOp[0] = SELECTARG1;
        ColorArg1[0] = Diffuse;
        
        AlphaOp[0] = SELECTARG1;
        AlphaArg1[0] = Diffuse;

        Lighting = true;
    }
}
