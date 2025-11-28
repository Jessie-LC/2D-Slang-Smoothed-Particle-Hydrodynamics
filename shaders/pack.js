// pack.ts
function configureRenderer(renderer) {
  renderer.sunPathRotation = 0;
  renderer.ambientOcclusionLevel = 0;
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
var numCellsX = 16;
var numCellsY = 16;
var cellCount = numCellsX * numCellsY;
var particleGroupSize = 96;
var particleGroupCount = 96;
var particleCount = particleGroupSize * particleGroupCount;
var particleBufferSize = 84 * particleCount;
function configurePipeline(pipeline) {
  const mainTexture = pipeline.createTexture("mainTexture").format(Format.RGBA16F).width(screenWidth).height(screenHeight).mipmap(false).clear(false).build();
  const globalDefines = pipeline.createExportList().addInt("PARTICLE_COUNT", particleCount).addInt("PARTICLE_GROUP_SIZE", particleGroupSize).build();
  pipeline.setGlobalExport(globalDefines);
  pipeline.createBuffer("particles", particleBufferSize, false);
  const preRenderStage = pipeline.forStage(Stage.SCREEN_SETUP);
  preRenderStage.createCompute("initialize-particles").location("programs/initialize.slang", "InitializeParticles").workGroups(particleGroupCount, 1, 1).compile();
  preRenderStage.createCompute("initialize-density").location("programs/simulation/density.slang", "CalculateDensity").workGroups(particleGroupCount, 1, 1).compile();
  preRenderStage.createCompute("initialize-gradh").location("programs/simulation/gradh.slang", "CalculateGradH").workGroups(particleGroupCount, 1, 1).compile();
  preRenderStage.end();
  const simulationStage = pipeline.forStage(Stage.PRE_RENDER);
  simulationStage.createCompute("calculate-density-1").location("programs/simulation/density.slang", "CalculateDensity").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-gradh-1").location("programs/simulation/gradh.slang", "CalculateGradH").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-acceleration-1").location("programs/simulation/acceleration.slang", "CalculateAcceleration").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-velocity-1").location("programs/simulation/integrate-velocity.slang", "IntegrateVelocity").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-position").location("programs/simulation/integrate-position.slang", "IntegratePosition").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-density-2").location("programs/simulation/density.slang", "CalculateDensity").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-gradh-2").location("programs/simulation/gradh.slang", "CalculateGradH").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-acceleration-2").location("programs/simulation/acceleration.slang", "CalculateAcceleration").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.createCompute("calculate-velocity-2").location("programs/simulation/integrate-velocity.slang", "IntegrateVelocity").workGroups(particleGroupCount, 1, 1).compile();
  simulationStage.end();
  pipeline.createCombinationPass("programs/post/combination.slang").compile();
}
export {
  configurePipeline,
  configureRenderer
};
//# sourceMappingURL=pack.js.map
