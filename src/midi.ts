import webmidi, { Input } from "webmidi";

import { IInstrument } from "./audio";

class Midi {
  input: Input;
  inputs: Input[] = [];
  instrument: IInstrument;

  getInputNames(): string[] {
    return this.inputs.map(input => input.name);
  }

  setInput(name: string): void {
    if (webmidi.enabled) {
      const newInput = webmidi.getInputByName(name);
      if (newInput) {
        this.removeListeners(this.input);
        this.input = newInput;
        this.addListeners(this.input);
      } else {
        console.log("Device not found.");
      }
    }
  }

  addListeners(input: Input): void {
    input.addListener("noteon", "all", event => {
      this.instrument.playNote(event.note.number);
      console.log("noteon: " + event.note.number);
    });

    input.addListener("noteoff", "all", event => {
      this.instrument.stopNote(event.note.number);
      console.log("noteoff: " + event.note.number);
    });

    input.addListener("pitchbend", "all", event => {
      console.log("pitchbend: ", event);
    });

    input.addListener("controlchange", "all", event => {
      console.log("controlchange: ", event);
    });
  }

  removeListeners(input: Input): void {
    input.removeListener("noteon");
    input.removeListener("noteoff");
    input.removeListener("pitchbend");
    input.removeListener("controlchange");
  }

  load(instrument: IInstrument) {
    this.instrument = instrument;

    webmidi.enable(err => {
      if (!err) {
        console.log("WebMidi enabled!");
      } else {
        console.log("WebMidi could not be enabled.", err);
      }

      console.log(webmidi.inputs);
      console.log(webmidi.outputs);

      this.inputs = webmidi.inputs;

      if (this.inputs.length !== 0) {
        this.input = webmidi.inputs[0];
        this.addListeners(this.input);
      } else {
        console.log("No Midi devices available.");
      }
    });
  }
}

export { Midi };
