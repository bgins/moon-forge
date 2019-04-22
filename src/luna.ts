import EnvGen from "fastidious-envelope-generator";
import {
  AudioContext,
  IAudioContext,
  IGainNode,
  IOscillatorOptions,
  IBiquadFilterOptions,
  IGainOptions
} from "standardized-audio-context";

import { IInstrument, INote, IEnvelopeOptions } from "./audio";

class Luna implements IInstrument {
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
    gain: 0,
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
  edo: number = 12;
  baseFrequency: number = 261.625;
  baseMidiNote: number = 60;

  constructor() {
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
    // let freq = 261.625565 * 2 ** ((midiNote - 60) / 12);
    let freq =
      this.baseFrequency * 2 ** ((midiNote - this.baseMidiNote) / this.edo);
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

    const filterFreqGainNode = this.audioContext.createGain();
    // filterFreqGainNode.gain.setValueAtTime(0, this.audioContext.currentTime);
    filterFreqGainNode.connect(filterNode.frequency);

    const filterEnv = new EnvGen(this.audioContext, filterFreqGainNode.gain);
    // const filterEnv = new EnvGen(this.audioContext, filterNode.gain);
    filterEnv.mode = this.filterEnvOptions.mode;
    filterEnv.attackTime = this.filterEnvOptions.attack;
    filterEnv.decayTime = this.filterEnvOptions.decay;
    filterEnv.sustainLevel = this.filterEnvOptions.sustain;
    filterEnv.releaseTime = this.filterEnvOptions.release;

    console.log("filter freq on: " + filterNode.frequency.value);
    console.log("filter freq gain on: " + filterFreqGainNode.gain.value);
    oscillator.connect(ampGainNode);
    ampGainNode.connect(filterNode);
    filterNode.connect(this.masterGainNode);

    ampEnv.gateOn();
    filterEnv.gateOn();
    oscillator.start();

    const note = {
      oscillator: oscillator,
      ampGainNode: ampGainNode,
      ampEnv: ampEnv,
      filterNode: filterNode,
      filterEnv: filterEnv,
      filterFreqGainNode: filterFreqGainNode
    };
    this.notes[midiNote] = note;
  }

  stopNote(midiNote: number): void {
    const oscillator = this.notes[midiNote].oscillator;
    const ampEnv = this.notes[midiNote].ampEnv;
    const filterEnv = this.notes[midiNote].filterEnv;

    const filterNode = this.notes[midiNote].filterNode;
    const filterFreqGainNode = this.notes[midiNote].filterFreqGainNode;
    console.log("filter freq off: " + filterNode.frequency.value);
    console.log("filter freq gain off: " + filterFreqGainNode.gain.value);

    ampEnv.gateOff();
    filterEnv.gateOff();
    oscillator.stop(this.audioContext.currentTime + ampEnv.releaseTime + 2.0);

    this.notes[midiNote] = null;
  }
}

export { Luna };
