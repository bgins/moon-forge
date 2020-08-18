import { Elm } from './Main.elm';
import { Keyboard } from './controllers/keyboard';
import { Luna } from './audio/luna';
import { Midi } from './controllers/midi';


/*
 * Instantiate the Elm user interface.
 * Create computer keyboard and midi controls.
 */
const app = Elm.Main.init({
  node: document.querySelector('main'),
});
const keyboard = new Keyboard();
const midi = new Midi();
const instrument = null;

/* PATCH */

app.ports.initializeInstrument.subscribe(patch => {
  console.log(patch);
  switch (patch.instrument) {
    case 'luna':
      // const luna = new Luna(patch.settings);
      this.instrument = new Luna(patch.settings);
      keyboard.enable(this.instrument);
      break;

    default:
      console.log('unknown instrument');
  }
});

app.ports.updateAudioParam.subscribe(param => {
  this.instrument.updateAudioParam(param);
});

/* CONTROLS */

/*
 * Enable and disable computer keyboard controls from the user interface.
 */
app.ports.enableKeyboard.subscribe(() => {
  keyboard.enable(this.instrument);
  midi.disable();
});

// app.ports.disableKeyboard.subscribe(() => {
//   keyboard.disable();
// });

/*
 * Enable midi controls from the user interface.
 * getMidiDevices enables midi and sends a list of available devices to the
 * user interface.
 */
app.ports.getMidiDevices.subscribe(() => {
  console.log(midi.getInputNames());
  midi.enable(this.instrument);
  keyboard.disable();
  app.ports.onMidiDevices.send({
    // selected: null,
    selected: midi.getSelectedInputName(),
    available: midi.getInputNames()
  });
});

/*
 * Select a midi device from the user interface.
 */
app.ports.setMidiDevice.subscribe(device => {
  console.log(JSON.stringify(device));
  midi.setInput(device);
})

