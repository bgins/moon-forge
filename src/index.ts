import * as webnative from 'webnative';

// @ts-expect-error
import { Elm } from './Main.elm';
import { Keyboard } from './controllers/keyboard';
import { Luna } from './audio/luna';
import { Midi } from './controllers/midi';

/*
 * Instatiate computer keyboard and midi controls.
 */
const app = Elm.Main.init({
  node: document.querySelector('main'),
});
const keyboard = new Keyboard();
const midi = new Midi();
const instruments = ['luna'];
let instrument = null;
let patches = [];
let fs = null;

// fetch and load factory patches
fetch("public/patches.json")
  .then(response => response.json())
  .then(ps => {
    patches = ps;
    app.ports.onPatches.send(patches);
  })

const fissionInit = {
  permissions: {
    app: {
      name: 'moon-forge',
      creator: 'bgins'
    }
  }
};

webnative.initialize(fissionInit).then(async state => {
  switch (state.scenario) {
    case webnative.Scenario.AuthSucceeded:
    case webnative.Scenario.Continuation:
      app.ports.onAuthChange.send({
        type: "user",
        name: state.username
      })

      fs = state.fs;

      const appPath = fs.appPath();
      const appDirectoryExists = await fs.exists(appPath);

      if (!appDirectoryExists) {
        await fs.mkdir(appPath);
        await fs.publish();
      }

      // load user patches
      const userPatches = await Promise.all(
        instruments
          .map(async instrument => {
            const directory = fs.appPath([`${instrument}`, 'patches'])
            if (await fs.exists(directory)) {
              const directoryListing = await fs.ls(directory);
              const patches = await Promise.all(Object.keys(directoryListing).map(async filename => {
                const path = fs.appPath([`${instrument}`, 'patches', `${filename}`]);
                return JSON.parse(await fs.read(path));
              }));
              return patches;
            } else {
              return [];
            }
          })
      )
      const allPatches = patches.concat(userPatches.flatMap(ps => ps, []));
      app.ports.onPatches.send(allPatches);

      break;

    case webnative.Scenario.NotAuthorised:
    case webnative.Scenario.AuthCancelled:
      app.ports.onAuthChange.send(null);
      break;
  }

  app.ports.login.subscribe(() => {
    webnative.redirectToLobby(state.permissions);
  });


  /* PERSISTENCE */

  app.ports.loadPatch.subscribe(async metadata => {
    let patch;

    switch (metadata.creator.type) {
      case "user":
        const path = fs.appPath([
          `${metadata.instrument}`,
          'patches',
          `${metadata.name}.json`
        ]);
        patch = JSON.parse(await fs.read(path));
        app.ports.onPatch.send(patch);
        break;

      case "factory":
      case "community":
        patch =
          patches
            .filter(p => p.creator.type === metadata.creator.type)
            .find(p => p.name === metadata.name)
        app.ports.onPatch.send(patch);
    }
  });

  app.ports.storePatch.subscribe(async ({ metadata, patch }) => {
    const path = fs.appPath([
      `${metadata.instrument}`,
      'patches',
      `${metadata.name}.json`
    ]);

    await fs.write(path, JSON.stringify({ ...metadata, patch }));
    await fs.publish();
    app.ports.onPatchStored.send(metadata);
  });

  app.ports.deletePatch.subscribe(async metadata => {
    const path = fs.appPath([
      `${metadata.instrument}`,
      'patches',
      `${metadata.name}.json`
    ]);

    await fs.rm(path);
    await fs.publish();
    app.ports.onPatchDeleted.send(metadata);
  });
});


/* PATCH */

app.ports.patchInstrument.subscribe(options => {
  switch (options.instrument) {
    case 'luna':
      instrument = new Luna(options.patch);
      patchController(options.controller, instrument);
      break;

    default:
      console.log('unknown instrument');
  }
});

const patchController = (controller, instrument) => {
  switch (controller) {
    case 'midi':
      midi.enable(instrument);
      break;

    case 'keyboard':
      keyboard.enable(instrument);
      break;

    default:
      keyboard.enable(instrument);
      break;
  }
}

app.ports.updateAudioParam.subscribe(param => {
  instrument.updateAudioParam(param);
});



/* CONTROLS */

/*
 * Enable or disable computer keyboard controls from the user interface.
 */
app.ports.enableKeyboard.subscribe(() => {
  keyboard.enable(instrument);
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
  midi.enable(instrument);
  keyboard.disable();

  app.ports.onMidiDevices.send({
    selected: midi.getSelectedInputName(),
    available: midi.getInputNames()
  });
});

/*
 * Select a midi device from the user interface.
 */
app.ports.setMidiDevice.subscribe(device => {
  midi.setInput(device);
});
