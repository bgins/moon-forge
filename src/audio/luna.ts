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
  oscillatorOptions: IOscillatorOptions;
  ampGainOptions: IGainOptions;
  ampEnvOptions: IEnvelopeOptions;
  filterOptions: IBiquadFilterOptions;
  filterEnvOptions: IEnvelopeOptions;
  masterGainOptions: IGainOptions;
  edo: number;
  baseFrequency: number;
  baseMidiNote: number;

  // give flags a type when the options are stable
  constructor(flags: any) {
    this.oscillatorOptions = {
      type: flags.oscillator,
      detune: 0,
      frequency: 261.625,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.ampGainOptions = {
      gain: 0.05,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.ampEnvOptions = {
      mode: "ADSR",
      attack: flags.ampEnvAttack,
      decay: flags.ampEnvDecay,
      sustain: flags.ampEnvSustain,
      release: flags.ampEnvRelease
    };
    this.filterOptions = {
      type: flags.filter,
      frequency: flags.filterFreq,
      Q: flags.filterQ,
      detune: 0,
      gain: 0,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.filterEnvOptions = {
      mode: "ADSR",
      attack: flags.filterEnvAttack,
      decay: flags.filterEnvDecay,
      sustain: flags.filterEnvSustain,
      release: flags.filterEnvRelease
    };
    this.masterGainOptions = {
      gain: flags.gain,
      channelCount: 2,
      channelCountMode: "max",
      channelInterpretation: "speakers"
    };
    this.edo = +flags.temperamentInput;
    this.baseFrequency = +flags.baseFrequencyInput;
    this.baseMidiNote = +flags.baseMidiNoteInput;

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

    const filterFreqScaler = this.audioContext.createGain();
    filterFreqScaler.gain.setValueAtTime(0, this.audioContext.currentTime);

    const filterFreqMultiplier = this.audioContext.createGain();
    filterFreqMultiplier.gain.setValueAtTime(
      8000,
      this.audioContext.currentTime
    );

    filterFreqScaler.connect(filterFreqMultiplier.gain);
    filterFreqMultiplier.connect(filterNode.frequency);

    const filterEnv = new EnvGen(this.audioContext, filterFreqScaler.gain);
    // const filterEnv = new EnvGen(this.audioContext, filterNode.gain);
    filterEnv.mode = this.filterEnvOptions.mode;
    filterEnv.attackTime = this.filterEnvOptions.attack;
    filterEnv.decayTime = this.filterEnvOptions.decay;
    filterEnv.sustainLevel = this.filterEnvOptions.sustain;
    filterEnv.releaseTime = this.filterEnvOptions.release;

    console.log("filter freq on: " + filterNode.frequency.value);
    console.log("filter freq scaler on: " + filterFreqScaler.gain.value);
    console.log(
      "filter freq multiplier on: " + filterFreqMultiplier.gain.value
    );
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
      filterFreqGainNode: filterFreqMultiplier,
      filterFreqScaler: filterFreqScaler
    };
    this.notes[midiNote] = note;
  }

  stopNote(midiNote: number): void {
    const oscillator = this.notes[midiNote].oscillator;
    const ampEnv = this.notes[midiNote].ampEnv;
    const filterEnv = this.notes[midiNote].filterEnv;

    const filterNode = this.notes[midiNote].filterNode;
    const filterFreqGainNode = this.notes[midiNote].filterFreqGainNode;
    const filterFreqScaler = this.notes[midiNote].filterFreqScaler;
    console.log("filter freq off: " + filterNode.frequency.value);
    console.log("filter freq scaler off: " + filterFreqScaler.gain.value);
    console.log("filter freq multiplier off: " + filterFreqGainNode.gain.value);

    ampEnv.gateOff();
    filterEnv.gateOff();
    oscillator.stop(this.audioContext.currentTime + ampEnv.releaseTime + 2.0);

    this.notes[midiNote] = null;
  }
}

export { Luna };
