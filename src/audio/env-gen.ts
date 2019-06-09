import { IAudioContext, IAudioParam } from "standardized-audio-context";

class Envelope {
  settings: IEnvelopeSettings = {
    initialLevel: 0,
    attackTime: 0,
    attackFinalLevel: 1,
    decayTime: 0,
    sustainLevel: 1,
    releaseTime: 0,
    endValue: 0.0001
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
    if (settings.endValue) this.settings.endValue = settings.endValue;
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

      // valueAtGateClose is sometimes 0 when many notes come in quickly
      if (this.valueAtGateClose <= 0.0) this.valueAtGateClose = 0.0001;

      this.targetParam.cancelScheduledValues(gateClosedAt);
      this.targetParam.setValueAtTime(this.valueAtGateClose, gateClosedAt);
      this.targetParam.exponentialRampToValueAtTime(this.settings.endValue, this.endAt);
      this.gateOpen = false;
    }
  }

  getEndTime(): number {
    return this.endAt;
  }

  retrigger(retriggerAt: number, newSettings: IEnvelopeSettings): void {
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

        this.reschedule(retriggerAt, currentValue, newSettings);
      } else {
        console.log("retrigger in sustain phase");
        this.reschedule(retriggerAt, this.settings.sustainLevel, newSettings);
      }
    } else {
      if (retriggerAt > this.gateClosedAt && retriggerAt <= this.gateClosedAt + this.settings.releaseTime) {
        console.log("retrigger in release phase");

        // console.log("valueAtGateClose: " + this.valueAtGateClose);
        // console.log("endValue: " + this.settings.endValue);
        // console.log("retriggerAt: " + retriggerAt);
        // console.log("gateClosedAt: " + this.gateClosedAt);
        // console.log("releaseTime: " + this.settings.releaseTime);

        const currentValue =
          this.valueAtGateClose *
          Math.pow(
            this.settings.endValue / this.valueAtGateClose,
            (retriggerAt - this.gateClosedAt) / this.settings.releaseTime
          );

        // console.log("currentValue: " + currentValue);

        this.reschedule(retriggerAt, currentValue, newSettings);

        this.gateOpen = true;
        this.endAt = Infinity;
      } else {
        // this case is not likely to be reached
        console.log("retrigger after envelope completed");
        // this.openGate(retriggerAt);
      }
    }
  }

  private reschedule(retriggerAt: number, currentValue: number, newSettings: IEnvelopeSettings): void {
    console.log("rescheduling");

    // this.targetParam.cancelAndHoldAtTime(retriggerAt);
    this.targetParam.cancelScheduledValues(retriggerAt);
    this.targetParam.setValueAtTime(currentValue, retriggerAt);

    this.settings = newSettings;
    if (!newSettings.initialLevel) this.settings.initialLevel = 0;
    if (!newSettings.attackFinalLevel) this.settings.attackFinalLevel = 1;
    if (!newSettings.endValue) this.settings.endValue = 0.0001;

    // compute would-have-been start time given current value and the new attackTime
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
  endValue?: number;
  // attackCurveType?: string;
  // decayCurveType?: string;
  // releaseCurveType?: string;
  // velocityScaling: number;
}

export { Envelope, IEnvelopeSettings };
