import { IAudioContext, IAudioParam } from "standardized-audio-context";

class Envelope {
  settings: IEnvelopeSettings = {
    initialLevel: 0,
    attackTime: 0,
    attackFinalLevel: 1,
    decayTime: 0,
    sustainLevel: 1,
    releaseTime: 0
  };
  audioContext: IAudioContext;
  targetParam: IAudioParam;
  gateOpen: Boolean = false;
  gateOpenAt: number;
  startDecayAt: number;
  startSustainAt: number;
  gateClosedAt: number;
  valueAtGateClose: number;
  endAt: number;

  constructor(audioContext: IAudioContext, settings: IEnvelopeSettings) {
    this.audioContext = audioContext;

    this.settings.attackTime = settings.attackTime;
    this.settings.decayTime = settings.decayTime;
    this.settings.sustainLevel = settings.sustainLevel;
    this.settings.releaseTime = settings.releaseTime;

    if (settings.initialLevel) this.settings.initialLevel = settings.initialLevel;
    if (settings.attackFinalLevel) this.settings.attackFinalLevel = settings.attackFinalLevel;
  }

  connect(targetParam: IAudioParam): void {
    this.targetParam = targetParam;
  }

  openGate(gateOpenAt: number): void {
    this.gateOpenAt = gateOpenAt;
    this.startDecayAt = gateOpenAt + this.settings.attackTime;
    this.startSustainAt = this.startDecayAt + this.settings.decayTime;

    this.targetParam.setValueAtTime(this.settings.initialLevel, gateOpenAt);
    this.targetParam.linearRampToValueAtTime(this.settings.attackFinalLevel, this.startDecayAt);
    this.targetParam.exponentialRampToValueAtTime(this.settings.sustainLevel, this.startSustainAt);

    this.gateOpen = true;
    this.endAt = Infinity;
  }

  closeGate(gateClosedAt: number): void {
    this.gateClosedAt = gateClosedAt;
    this.endAt = gateClosedAt + this.settings.releaseTime;

    if (this.gateOpen) {
      // these values should be calculated a bit into the future to account for the delay before we schedule them
      if (gateClosedAt < this.startDecayAt) {
        this.valueAtGateClose =
          this.settings.initialLevel +
          (this.settings.attackFinalLevel - this.settings.initialLevel) * // use abs value?
            ((gateClosedAt - this.gateOpenAt) / this.settings.attackTime);
      } else if (gateClosedAt >= this.startDecayAt && gateClosedAt < this.startSustainAt) {
        this.valueAtGateClose =
          this.settings.attackFinalLevel *
          Math.pow(
            this.settings.sustainLevel / this.settings.attackFinalLevel,
            (gateClosedAt - this.startDecayAt) / this.settings.decayTime
          );
      } else {
        this.valueAtGateClose = this.settings.sustainLevel;
      }

      console.log("current value: " + this.targetParam.value);
      console.log("vgc: " + this.valueAtGateClose);

      this.targetParam.cancelScheduledValues(gateClosedAt);
      this.targetParam.setValueAtTime(this.valueAtGateClose, gateClosedAt);
      this.targetParam.exponentialRampToValueAtTime(0.0001, this.endAt);
      this.gateOpen = false;
    }
  }

  getEndTime(): number {
    return this.endAt;
  }

  retrigger(retriggerAt: number): void {
    // these values should be calculated a bit into the future to account for the delay before we schedule them
    if (this.gateOpen) {
      if (retriggerAt < this.startDecayAt) {
        console.log("retrigger in attack phase");
      } else if (retriggerAt >= this.startDecayAt && retriggerAt < this.startSustainAt) {
        console.log("retrigger in decay phase");

        const currentValue =
          this.settings.attackFinalLevel *
          Math.pow(
            this.settings.sustainLevel / this.settings.attackFinalLevel,
            (retriggerAt - this.startDecayAt) / this.settings.decayTime
          );

        this.reschedule(retriggerAt, currentValue);
      } else {
        console.log("retrigger in sustain phase");
        this.reschedule(retriggerAt, this.settings.sustainLevel);
      }
    } else {
      if (retriggerAt > this.gateClosedAt && retriggerAt <= this.gateClosedAt + this.settings.releaseTime) {
        console.log("retrigger in release phase");

        const currentValue =
          this.valueAtGateClose *
          Math.pow(0.0001 / this.valueAtGateClose, (retriggerAt - this.gateClosedAt) / this.settings.releaseTime);

        this.reschedule(retriggerAt, currentValue);

        this.gateOpen = true;
        this.endAt = Infinity;
      } else {
        // this case is not likely to be reached
        console.log("retrigger after envelope completed");
        this.openGate(retriggerAt);
      }
    }
  }

  private reschedule(retriggerAt: number, currentValue: number): void {
    console.log("rescheduling");

    // this.targetParam.cancelAndHoldAtTime(retriggerAt);
    this.targetParam.cancelScheduledValues(retriggerAt);
    this.targetParam.setValueAtTime(currentValue, retriggerAt);

    // compute would-have-been start time given current value and attackTime
    const attackWouldHaveStartedAt =
      retriggerAt -
      ((this.settings.attackTime * (currentValue - this.settings.initialLevel)) / this.settings.attackFinalLevel -
        this.settings.initialLevel);

    this.startDecayAt = attackWouldHaveStartedAt + this.settings.attackTime;
    this.startSustainAt = this.startDecayAt + this.settings.decayTime;

    this.targetParam.linearRampToValueAtTime(this.settings.attackFinalLevel, this.startDecayAt);
    this.targetParam.exponentialRampToValueAtTime(this.settings.sustainLevel, this.startSustainAt);

    this.gateOpenAt = attackWouldHaveStartedAt;
  }
}

interface IEnvelopeSettings {
  initialLevel?: number;
  // delayTime: number;
  attackTime: number;
  attackFinalLevel?: number;
  // holdTime: number;
  decayTime: number;
  sustainLevel: number;
  releaseTime: number;
  // attackCurveType?: string;
  // decayCurveType?: string;
  // releaseCurveType?: string;
  // velocityScaling: number;
}

export default Envelope;
// export { Envelope };
