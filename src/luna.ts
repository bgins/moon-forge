import EnvGen from "fastidious-envelope-generator";
import {
  AudioContext,
  IOscillatorNode,
  IAudioContext,
  IGainNode,
  IBiquadFilterNode,
  IOscillatorOptions,
  IBiquadFilterOptions,
  IGainOptions
} from "standardized-audio-context";
import webmidi, { INoteParam, IMidiChannel } from "webmidi";

interface INote {
  oscillator: IOscillatorNode;
  ampGainNode: IGainNode;
  ampEnv: any;
  filterNode: IBiquadFilterNode;
  filterEnv: any;
}

interface IEnvelopeOptions {
  mode: string;
  attack: number;
  decay: number;
  sustain: number;
  release: number;
}

class Luna {
  audioContext: IAudioContext;
  masterGainNode: IGainNode;
  notes: INote[] = [];
  oscillatorOptions: IOscillatorOptions = {
    type: "triangle",
    detune: 0,
    frequency: 440,
    channelCount: 2,
    channelCountMode: "max",
    channelInterpretation: "speakers"
  };
  ampGainOptions: IGainOptions = {
    gain: 0.05,
    channelCount: 2,
    channelCountMode: "max",
    channelInterpretation: "speakers"
  };
  ampEnvOptions: IEnvelopeOptions = {
    mode: "ADSR",
    attack: 0.5,
    decay: 0.5,
    sustain: 0.1,
    release: 0.2
  };
  filterOptions: IBiquadFilterOptions = {
    type: "lowpass",
    frequency: 1000,
    Q: 1,
    detune: 0,
    gain: 25,
    channelCount: 2,
    channelCountMode: "max",
    channelInterpretation: "speakers"
  };
  filterEnvOptions: IEnvelopeOptions = {
    mode: "ADSR",
    attack: 0.1,
    decay: 0.2,
    sustain: 0.5,
    release: 0.5
  };
  masterGainOptions: IGainOptions = {
    gain: 0.3,
    channelCount: 2,
    channelCountMode: "max",
    channelInterpretation: "speakers"
  };

  setupAudio(): void {
    this.audioContext = new AudioContext();

    this.masterGainNode = this.audioContext.createGain();
    this.masterGainNode.gain.setValueAtTime(
      this.masterGainOptions.gain,
      this.audioContext.currentTime
    );
    this.masterGainNode.connect(this.audioContext.destination);
  }

  updateMasterGain(gain: number): void {
    this.masterGainOptions.gain = gain;
    this.masterGainNode.gain.setValueAtTime(
      this.masterGainOptions.gain,
      this.audioContext.currentTime
    );
  }

  playNote(midiNote: number): void {
    let freq = (440 / 32) * 2 ** ((midiNote - 9) / 12);
    console.log(freq);

    let oscillator = this.audioContext.createOscillator();
    oscillator.type = this.oscillatorOptions.type;
    oscillator.frequency.setValueAtTime(freq, this.audioContext.currentTime);

    const ampGainNode = this.audioContext.createGain();
    ampGainNode.gain.setValueAtTime(
      this.ampGainOptions.gain,
      this.audioContext.currentTime
    );

    const ampEnv = new EnvGen(this.audioContext, ampGainNode.gain);
    ampEnv.mode = this.ampEnvOptions.mode;
    ampEnv.attackTime = this.ampEnvOptions.attack;
    ampEnv.decayTime = this.ampEnvOptions.decay;
    ampEnv.sustainLevel = this.ampEnvOptions.sustain;
    ampEnv.releaseTime = this.ampEnvOptions.release;

    const filterNode = this.audioContext.createBiquadFilter();
    filterNode.type = this.filterOptions.type;
    filterNode.Q.setValueAtTime(
      this.filterOptions.Q,
      this.audioContext.currentTime
    );
    filterNode.frequency.setValueAtTime(
      this.filterOptions.frequency,
      this.audioContext.currentTime
    );
    filterNode.gain.setValueAtTime(
      this.filterOptions.gain,
      this.audioContext.currentTime
    );

    const filterEnv = new EnvGen(this.audioContext, filterNode.gain);
    filterEnv.mode = this.filterEnvOptions.mode;
    filterEnv.attackTime = this.filterEnvOptions.attack;
    filterEnv.decayTime = this.filterEnvOptions.decay;
    filterEnv.sustainLevel = this.filterEnvOptions.sustain;
    filterEnv.releaseTime = this.filterEnvOptions.release;

    oscillator.connect(ampGainNode);
    ampGainNode.connect(filterNode);
    filterNode.connect(this.masterGainNode);

    oscillator.start();
    ampEnv.gateOn();

    const note = {
      oscillator: oscillator,
      ampGainNode: ampGainNode,
      ampEnv: ampEnv,
      filterNode: filterNode,
      filterEnv: filterEnv
    };
    this.notes[midiNote] = note;
  }

  stopNote(midiNote: number): void {
    const oscillator = this.notes[midiNote].oscillator;
    const ampEnv = this.notes[midiNote].ampEnv;
    const filterEnv = this.notes[midiNote].filterEnv;

    ampEnv.gateOff();
    filterEnv.gateOff();
    oscillator.stop(this.audioContext.currentTime + ampEnv.releaseTime + 2.0);

    this.notes[midiNote] = null;
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

export { Luna };
