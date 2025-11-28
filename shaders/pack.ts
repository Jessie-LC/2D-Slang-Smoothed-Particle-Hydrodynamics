export function configureRenderer(renderer: RendererConfig): void {
    renderer.sunPathRotation = 0.0;
    renderer.ambientOcclusionLevel = 0.0;
    renderer.mergedHandDepth = false;
    renderer.disableShade = false;

    renderer.render.sun = false;
    renderer.render.horizon = false;
    renderer.render.clouds = false;
    renderer.render.moon = false;
    renderer.render.vignette = false;
    renderer.render.waterOverlay = false;
    renderer.render.entityShadow = false;
    renderer.render.stars = false;
}

const numCellsX = 16;
const numCellsY = 16;
const cellCount = numCellsX * numCellsY;

const particleGroupSize = 96;
const particleGroupCount = 96;
const particleCount = particleGroupSize * particleGroupCount;
const particleBufferSize = 84 * particleCount;

const renderBufferWidth = 512;
const renderBufferHeight = 512;
const renderBufferSize = 8 * renderBufferWidth * renderBufferHeight;

export function configurePipeline(pipeline: PipelineConfig): void {
    const mainTexture = pipeline.createTexture('mainTexture')
                        .format(Format.RGBA16F)
                        .width(renderBufferWidth)
                        .height(renderBufferHeight)
                        .mipmap(false)
                        .clear(false)
                        .build();

    const globalDefines = pipeline.createExportList()
                          .addInt('PARTICLE_COUNT', particleCount)
                          .addInt('PARTICLE_GROUP_SIZE', particleGroupSize)
                          .build();

    pipeline.setGlobalExport(globalDefines);

    pipeline.createBuffer('particles', particleBufferSize, false);
    pipeline.createBuffer('pixelbuffer', renderBufferSize, true);

    const preRenderStage = pipeline.forStage(Stage.SCREEN_SETUP);

    preRenderStage.createCompute('initialize-particles')
    .location("programs/initialize.slang", 'InitializeParticles')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    preRenderStage.createCompute('initialize-density')
    .location("programs/simulation/density.slang", 'CalculateDensity')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    preRenderStage.createCompute('initialize-gradh')
    .location("programs/simulation/gradh.slang", 'CalculateGradH')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    preRenderStage.end();

    const simulationStage = pipeline.forStage(Stage.PRE_RENDER);

    //simulationStage.createCompute('calculate-acceleration-1')
    //.location("programs/simulation/acceleration.slang", 'calculateAcceleration')
    //.workGroups(particleGroupCount, 1, 1)
    //.compile();

    simulationStage.createCompute('calculate-density-1')
    .location("programs/simulation/density.slang", 'CalculateDensity')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-gradh-1')
    .location("programs/simulation/gradh.slang", 'CalculateGradH')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-acceleration-1')
    .location("programs/simulation/acceleration.slang", 'CalculateAcceleration')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-velocity-1')
    .location("programs/simulation/integrate-velocity.slang", 'IntegrateVelocity')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    simulationStage.createCompute('calculate-position')
    .location("programs/simulation/integrate-position.slang", 'IntegratePosition')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    simulationStage.createCompute('calculate-density-2')
    .location("programs/simulation/density.slang", 'CalculateDensity')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-gradh-2')
    .location("programs/simulation/gradh.slang", 'CalculateGradH')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-acceleration-2')
    .location("programs/simulation/acceleration.slang", 'CalculateAcceleration')
    .workGroups(particleGroupCount, 1, 1)
    .compile();
    simulationStage.createCompute('calculate-velocity-2')
    .location("programs/simulation/integrate-velocity.slang", 'IntegrateVelocity')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    simulationStage.end();

    const renderStage = pipeline.forStage(Stage.POST_RENDER);

    renderStage.createCompute('draw-particles')
    .location("programs/rendering/draw-particles.slang", 'DrawParticles')
    .workGroups(particleGroupCount, 1, 1)
    .compile();

    renderStage.createComposite('copy-pixelbuffer')
    .location("programs/rendering/copy.slang", 'CopyPixelbuffer')
    .target(0, mainTexture)
    .compile();

    renderStage.end();

    pipeline.createCombinationPass('programs/post/combination.slang')
    .compile();
}