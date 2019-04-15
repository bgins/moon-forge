import { Elm } from "./Main.elm";
import { Luna } from "./luna";
import { Midi } from "./midi";

let app = Elm.Main.init({
  node: document.querySelector("main"),
  flags: { audioParams: [] }
});

const luna = new Luna();
const midi = new Midi();
midi.load(luna);

app.ports.updateAudioParam.subscribe(data => {
  console.log(JSON.stringify(data));
  switch (data.name) {
    case "oscillatorType":
      luna.oscillatorOptions.type = data.val;
      break;
    case "ampEnvAttack":
      luna.ampEnvOptions.attack = data.val;
      break;
    case "ampEnvDecay":
      luna.ampEnvOptions.decay = data.val;
      break;
    case "ampEnvSustain":
      luna.ampEnvOptions.sustain = data.val;
      break;
    case "ampEnvRelease":
      luna.ampEnvOptions.release = data.val;
      break;
    case "filterType":
      luna.filterOptions.type = data.val;
      break;
    case "filterFreq":
      luna.filterOptions.frequency = data.val;
      break;
    case "filterQ":
      luna.filterOptions.Q = data.val;
      break;
    case "filterEnvAttack":
      luna.filterEnvOptions.attack = data.val;
      break;
    case "filterEnvDecay":
      luna.filterEnvOptions.decay = data.val;
      break;
    case "filterEnvSustain":
      luna.filterEnvOptions.sustain = data.val;
      break;
    case "filterEnvRelease":
      luna.filterEnvOptions.release = data.val;
      break;
    case "masterGain":
      luna.updateMasterGain(data.val);
      break;
    default:
      console.log("unknown parameter adjustment");
  }
});

app.ports.getMidiDevices.subscribe(data => {
  console.log(midi.getInputNames());
  app.ports.onMidiDevicesRequest.send({ midiDevices: midi.getInputNames() });
});

app.ports.setMidiDevice.subscribe(data => {
  console.log(JSON.stringify(data));
  midi.setInput(data);
});