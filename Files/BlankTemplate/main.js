// INITIATING 
// Initiate the toolbox once at the start of your project
const IST = new InteractiveSearchToolbox({/* Add settings here */})
await IST.init();

const timeline = [];

// PRELOADING
// Now we can begin by loading in our stimuli - note that for the sake of quicker loading, we only load two stimuli - we can copy these master stimuli and change their appearence at runtime instead
IST.preLoadModels(['Models/TARGET_CUBE.glb'])

// We also load in a HDRI file for some quick and easy lighting
IST.preloadHDRI(['Textures/smallStudio.hdr'], true) // Setting the second arguement to true automatically applies the HDRI to our scene.

// PRELOAD FINISHED
// Due to the asynchronous nature of loading files, we use the onPreloadFinished callback to ensure we only begin doing things AFTER the models, HDRIs and any other textures we need have loaded
IST.onPreloadFinished(function () {
    
    // Enable the interactive controls
    IST.enableOrbitControls();

    const INTERACTIVE_SEARCH_TRIAL = {
        type: jsPsychHtmlKeyboardResponse,
        on_start() {
            const T_CUBE = IST.findLoadedObject('TARGET_CUBE')
            IST.addStimulusToScene(T_CUBE)
            IST.camera.position.set(0,0,100);
            IST.camera.lookAt(0,0,0);

            IST.startTrial(); // Finally we call this to start the trial - This is extremely important.
        },
        stimulus: '', // We tell jspsych not to show anything for the trial, we handle that with the IST instead. 
        on_finish() {
            IST.endTrial(); // Call this at the end of every trial - This is extremely important. 
        },
        choices: ['z', 'm']
    }

     const DEBREIF_TRIAL = {
        type: jsPsychHtmlButtonResponse,

        stimulus: `
        <h3>This is the end of the experiment!</h3>
        Thank you for taking time to complete this study, your participation is greatly appreciated.
        `,
        choices: ['Finish Experiment']
    }

    // NOW WE SETUP THE ACTUAL TRIAL TIMELINE
    timeline.push(INTERACTIVE_SEARCH_TRIAL,DEBREIF_TRIAL)

    // Run the jsPsych timeline
    jsPsych.run(timeline); // Experiment begins now
})