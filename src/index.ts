import { Elm } from './Main.elm';
import { Keyboard } from './controllers/keyboard';
import { Luna } from './audio/luna';
import { Midi } from './controllers/midi';

const flags = {
  oscillator: 'square',
  ampEnvAttack: 0.05,
  ampEnvDecay: 0.05,
  ampEnvSustain: 1,
  ampEnvRelease: 0.5,
  filter: 'lowpass',
  filterFreq: 2000,
  filterQ: 2,
  filterEnvAttack: 0.05,
  filterEnvDecay: 0.05,
  filterEnvSustain: 1,
  filterEnvRelease: 0.5,
  gain: 0.5,
  keyboardEnabled: true,
  midiEnabled: false,
  midiDevices: [],
  selectedMidiDevice: '',
  tuningPanelVisible: false,
  temperamentInput: '12',
  baseFrequencyInput: '261.625',
  baseMidiNoteInput: '60',
  assetsPath: './assets/'
};

/*
 * Instantiate the Elm user interface and Luna with flags.
 * Create computer keyboard and midi controls, and set keyboard as the default.
 */
const app = Elm.Main.init({
  node: document.querySelector('main'),
  flags: flags
});
const luna = new Luna(flags);
const keyboard = new Keyboard();
const midi = new Midi();
keyboard.enable(luna);

/*
 * Handle updates from the user interface.
 */
app.ports.updateAudioParam.subscribe(data => {
  console.log(JSON.stringify(data));
  switch (data.name) {
    case 'oscillatorType':
      luna.oscillatorOptions.type = data.val;
      break;
    case 'ampEnvAttack':
      luna.ampEnvOptions.attackTime = data.val;
      break;
    case 'ampEnvDecay':
      luna.ampEnvOptions.decayTime = data.val;
      break;
    case 'ampEnvSustain':
      luna.ampEnvOptions.sustainLevel = data.val;
      break;
    case 'ampEnvRelease':
      luna.ampEnvOptions.releaseTime = data.val;
      break;
    case 'filterType':
      luna.filterOptions.type = data.val;
      break;
    case 'filterFreq':
      luna.filterOptions.frequency = data.val;
      break;
    case 'filterQ':
      luna.filterOptions.Q = data.val;
      break;
    case 'filterEnvAttack':
      luna.filterEnvOptions.attackTime = data.val;
      break;
    case 'filterEnvDecay':
      luna.filterEnvOptions.decayTime = data.val;
      break;
    case 'filterEnvSustain':
      luna.filterEnvOptions.sustainLevel = data.val;
      break;
    case 'filterEnvRelease':
      luna.filterEnvOptions.releaseTime = data.val;
      break;
    case 'masterGain':
      luna.updateMasterGain(data.val);
      break;
    case 'edo':
      luna.edo = data.val;
      break;
    case 'baseFrequency':
      luna.baseFrequency = data.val;
      break;
    case 'baseMidiNote':
      luna.baseMidiNote = data.val;
      break;
    default:
      console.log('unknown parameter adjustment');
  }
});

/*
 * Enable and disable computer keyboard controls from the user interface.
 */
app.ports.enableKeyboard.subscribe(() => {
  keyboard.enable(luna);
  midi.disable();
});

app.ports.disableKeyboard.subscribe(() => {
  keyboard.disable();
});

/*
 * Enable midi controls from the user interface.
 * getMidiDevices enables midi and sends a list of available devices to the
 * user interface.
 */
app.ports.getMidiDevices.subscribe(() => {
  console.log(midi.getInputNames());
  console.log(midi.getSelectedInputName());
  midi.enable(luna);
  keyboard.disable();
  app.ports.onMidiDevicesRequest.send({
    midiDevices: midi.getInputNames(),
    selectedMidiDevice: midi.getSelectedInputName()
  });
});

/*
 * Select a midi device from the user interface.
 */
app.ports.setMidiDevice.subscribe(data => {
  console.log(JSON.stringify(data));
  midi.setInput(data);
});
