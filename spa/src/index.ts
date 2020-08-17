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

/* PATCH */

app.ports.initializeInstrument.subscribe(patch => {
  console.log(patch);
  switch (patch.instrument) {
    case 'luna':
      const luna = new Luna(patch.settings);
      keyboard.enable(luna);
      app.ports.updateAudioParam.subscribe(param => {
        luna.updateAudioParam(param);
      });
      break;

    default:
      console.log('unknown instrument');
  }
});

/* CONTROLS */

/*
 * Enable and disable computer keyboard controls from the user interface.
 */
// app.ports.enableKeyboard.subscribe(() => {
//   keyboard.enable(luna);
//   midi.disable();
// });

// app.ports.disableKeyboard.subscribe(() => {
//   keyboard.disable();
// });

/*
 * Enable midi controls from the user interface.
 * getMidiDevices enables midi and sends a list of available devices to the
 * user interface.
 */
// app.ports.getMidiDevices.subscribe(() => {
//   console.log(midi.getInputNames());
//   console.log(midi.getSelectedInputName());
//   midi.enable(luna);
//   keyboard.disable();
//   app.ports.onMidiDevicesRequest.send({
//     midiDevices: midi.getInputNames(),
//     selectedMidiDevice: midi.getSelectedInputName()
//   });
// });

/*
 * Select a midi device from the user interface.
 */
// app.ports.setMidiDevice.subscribe(data => {
//   console.log(JSON.stringify(data));
//   midi.setInput(data);
// })

