import {
  AudioContext,
  IOscillatorNode,
  IAudioContext,
  IGainNode
} from "standardized-audio-context";
import webmidi, { INoteParam, IMidiChannel } from "webmidi";

export class Luna {
  audioContext: IAudioContext;
  gate: IGainNode;
  voices: IOscillatorNode[] = [];

  setupAudio(): void {
    this.audioContext = new AudioContext();

    this.gate = this.audioContext.createGain();
    this.gate.gain.setValueAtTime(0.1, this.audioContext.currentTime);
    this.gate.connect(this.audioContext.destination);
  }

  playNote(midiNote: number): void {
    let freq = (440 / 32) * 2 ** ((midiNote - 9) / 12);
    console.log(freq);

    let voice = this.audioContext.createOscillator();
    voice.frequency.setValueAtTime(freq, this.audioContext.currentTime);
    voice.connect(this.gate);
    voice.start();

    this.voices[midiNote] = voice;
  }

  stopNote(midiNote: number): void {
    let voice = this.voices[midiNote];
    voice.stop();

    this.voices[midiNote] = null;
  }

  setupMidi(): void {
    webmidi.enable(err => {
      if (!err) {
        console.log("WebMidi enabled!");
      } else {
        console.log("WebMidi could not be enabled.", err);
      }
      console.log(webmidi.inputs);
      console.log(webmidi.outputs);

      let input = webmidi.inputs[2];
      console.log(input);

      input.addListener("noteon", "all", event => {
        this.playNote(event.note.number);
        console.log("noteon: " + event.note.number);
      });

      input.addListener("noteoff", "all", event => {
        this.stopNote(event.note.number);
        console.log("noteoff: " + event.note.number);
      });

      input.addListener("pitchbend", "all", event => {
        console.log("pitchbend: ", event);
      });

      input.addListener("controlchange", "all", event => {
        console.log("controlchange: ", event);
      });
    });
  }

  load(): void {
    this.setupMidi();
    this.setupAudio();
  }
}
